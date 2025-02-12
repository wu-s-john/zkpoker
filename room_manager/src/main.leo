// The 'room_manager' program.
program room_manager.aleo {
    struct PlayerRoomConfig {
        player_address: address,
        bet: u64
    }

    // RoomConfig holds the entire poker game configuration:
    // This is public so anyone can join the game based on the configuration
    // Empty seats have address 0x000...000
    struct RoomConfig {
        big_blind: u64,
        big_blind_seat: u8,
        small_blind: u64,
        small_blind_seat: u8,
        dealer_seat: u8,
        min_stack: u64,
        seats: u8,
        room_id: u32,
        joined_users: [PlayerRoomConfig; 4], // Address is 0x000...000 for empty seats
        num_joined_users: u8,
        game_state_manager_address: address
    }

    record RoomConfigRequest {
        room_id: u32,
        room_config: RoomConfig,
        owner: address
    }

    record HouseDealerCreateDeckRequest {
        owner: address,
        room_id: u32,
        player_addresses: [address; 4]
    }

    // -----------------------------------
    // RoomManager Transitions
    // -----------------------------------

    // Create a public mapping of available rooms

    // Mapping from room_id => RoomConfig
    mapping rooms: u32 => RoomConfig;

    // A single-k mapping (using bool = true) to store the most recently used room_id
    // We store an integer counter here that is incremented each time.
    mapping next_room_id: bool => u32;

    // Transition to create a new room.
    // Returns (u32, RoomConfig) so you know which room_id was assigned and what config was stored.
    async transition rm_create_room(
        big_blind: u64,
        small_blind: u64,
        min_stack: u64,
        seats: u8,
        host_player_bet: u64
    ) -> (RoomConfig, Future) {
        let null_player: PlayerRoomConfig = PlayerRoomConfig {
            player_address: 0group as address,
            bet: 0u64
        };
        
        let host_player: PlayerRoomConfig = PlayerRoomConfig {
            player_address: self.caller,
            bet: host_player_bet
        };

        let joined_users: [PlayerRoomConfig; 4] = [
            host_player, null_player, null_player, null_player
        ];
        
        let config : RoomConfig = RoomConfig {
            big_blind,
            small_blind,
            min_stack,
            seats,
            joined_users,
            num_joined_users: 1u8,
            big_blind_seat: 0u8,
            small_blind_seat: 0u8,
            dealer_seat: 0u8,
            room_id: 0u32,
            game_state_manager_address: 0group as address
        };

        let f: Future = finalize_create_room(config);
        return (config, f);
    }

    // This would do all the room operations
    async function finalize_create_room(
        config: RoomConfig
    ) {
        // 1) Load the current value of next_room_id (default to 0 if it doesn't exist yet)
        let current_id: u32 = Mapping::get_or_use(next_room_id, true, 0u32);

        // 2) Calculate the new room_id 
        let new_id: u32 = current_id + 1u32;

        // 4) Store the new config in the rooms mapping
        Mapping::set(rooms, new_id, config);

        // 5) Update the next_room_id mapping
        Mapping::set(next_room_id, true, new_id);
    }

    async transition rm_join_room(room_id: u32, player_bet: u64) -> Future {
        let f: Future = finalize_join_room(room_id, self.caller, player_bet);
        return f;
    }

    // Players read the public mapping of available rooms and join an open seat
    async function finalize_join_room(room_id: u32, player_address: address, player_bet: u64) {
        // Get the current room configuration
        let config: RoomConfig = Mapping::get(rooms, room_id);
        
        // Verify room exists and has space
        assert(config.num_joined_users < config.seats);
        
        // Create player config for the joining player
        let joining_player: PlayerRoomConfig = PlayerRoomConfig {
            player_address: player_address,
            bet: player_bet
        };

        // Create a new array by conditionally copying elements
        let updated_users: [PlayerRoomConfig; 4] = [
            // First position: If it's the first join, use joining_player, else use original
            config.num_joined_users == 0u8 ? joining_player : config.joined_users[0u8],
            // Second position: If it's the second join, use joining_player, else use original
            config.num_joined_users == 1u8 ? joining_player : config.joined_users[1u8],
            // Third position: If it's the third join, use joining_player, else use original
            config.num_joined_users == 2u8 ? joining_player : config.joined_users[2u8],
            // Fourth position: If it's the fourth join, use joining_player, else use original
            config.num_joined_users == 3u8 ? joining_player : config.joined_users[3u8]
        ];
        
        let updated_config: RoomConfig = RoomConfig {
            big_blind: config.big_blind,
            big_blind_seat: config.big_blind_seat,
            small_blind: config.small_blind,
            small_blind_seat: config.small_blind_seat,
            dealer_seat: config.dealer_seat,
            min_stack: config.min_stack,
            seats: config.seats,
            joined_users: updated_users,
            num_joined_users: config.num_joined_users + 1u8,
            room_id: config.room_id,
            game_state_manager_address: config.game_state_manager_address
        };
        
        // Return updated config and future for finalization
        Mapping::set(rooms, room_id, updated_config);
    }

    async transition rm_request_game_creation(room_id: u32, room_config: RoomConfig, dealer_address: address) -> (RoomConfigRequest, HouseDealerCreateDeckRequest, Future) {
        // Get the current room configuration
        
        // Verify room is full
        assert(room_config.num_joined_users == room_config.seats);
        assert(room_config.num_joined_users == 4u8);
        
        // Create deck request with room details
        let deck_request: HouseDealerCreateDeckRequest = HouseDealerCreateDeckRequest {
            room_id: room_id,
            owner: dealer_address,
            player_addresses: [
                room_config.joined_users[0u8].player_address,
                room_config.joined_users[1u8].player_address,
                room_config.joined_users[2u8].player_address,
                room_config.joined_users[3u8].player_address
            ]
        };

        let room_config_request: RoomConfigRequest = RoomConfigRequest {
            room_id: room_id,
            room_config: room_config,
            owner: dealer_address
        };

        // Create finalize future to see if the game config is valid
        let f: Future = finalize_request_game_creation(room_id, room_config);
        
        return (room_config_request, deck_request, f);
    }

    async function finalize_request_game_creation(room_id: u32, room_config: RoomConfig) {
        // Remove the room from available rooms since game is starting
        let queried_config: RoomConfig = Mapping::get(rooms, room_id);

    assert(queried_config.big_blind == room_config.big_blind);
    assert(queried_config.small_blind == room_config.small_blind);
    assert(queried_config.min_stack == room_config.min_stack);
    assert(queried_config.seats == room_config.seats);
    assert(queried_config.num_joined_users == room_config.num_joined_users);

    assert(queried_config.joined_users[0u8] == room_config.joined_users[0u8]);
    assert(queried_config.joined_users[1u8] == room_config.joined_users[1u8]);
    assert(queried_config.joined_users[2u8] == room_config.joined_users[2u8]);
    assert(queried_config.joined_users[3u8] == room_config.joined_users[3u8]);
    }
}
