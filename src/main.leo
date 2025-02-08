// The 'hello' program.
program zkpoker.aleo {
    struct Card {
        val: u32
    }

    struct Deck {
        cards1: [Card; 26],
        cards2: [Card; 26],
    }

    record HouseDealerState {
        owner: address,
        deck: Deck,            // The shuffled deck of 52 cards (public here)
        next_card_index: u8    // The pointer to the next card to deal (public)
    }

    record DealtOneCommunityCard {
        owner: address,
        card: Card,
        is_turn: bool,
        room_id: u32
    }

    record DealtThreeCommunityCards {
        owner: address,
        cards: [Card; 3],
        room_id: u32,
        is_next_phase_turn: bool
    }

    // A simple struct for a player's public data 
    // (fields visible to everyone in the network).
    struct Player {
        stack: u64,      // The player's chip stack (public)
        folded: bool,    // Whether the player has folded
        all_in: bool     // Whether the player is all-in
    }

    record PlayerProposedShuffle {
        owner: address,
        room_id: u32,
        seat_index: u8,
        seat_owner: address,
        perm1: [u8; 26],
        perm2: [u8; 26]
    }

    record HouseDealerCreateDeckRequest {
        owner: address,
        room_id: u32
    }

    // These actions fulfill requests that the game state manager requires to move 
    // the game forward.
    record PlayerActionResponse {
        owner: address,
        seat_index: u8,
        room_id: u32,
        // 0 = Fold, 1 = Call, 2 = Raise, 3 = All-In
        action_type: u8,
        // Use this amount for raise or all-in actions; can be 0 for fold or call
        amount: u64
    }

    // Private hole cards belong in a record:
    record PlayerHand {
        owner: address,       // Address that owns these hole cards
        hole_cards: [Card; 2] // Exactly two hole cards (private)
    }

    // A record to store a player's final hand and score at showdown
    record FinalHand {
        owner: address,        // The address owning this final hand
        did_fold: bool,        // Whether the player folded
        final_score: u32,      // The numerical score of the hand (private or revealed)
        player_hand: [Card; 2] // The player's hole cards (private)
    }

    // The main GameState struct holds publicly visible information.
    record GameState {
        owner: address,
        players: [Player; 4],
        num_players: u8,
        house_dealer_actor: address,
        room_id: u32,
        nonce: u64, // used to track valid state transitions
        small_blind_seat: u8,
        big_blind_seat: u8,
        small_blind: u64,
        big_blind: u64,
        
        current_phase: u8,              // 0=PRE_FLOP, 1=FLOP, etc.
        community_cards: [Card; 5],     // Indices 0-2 for flop, 3 for turn, 4 for river
        contributed: [u64; 4],          // Amount each seat has contributed
        highest_bet: u64,
        main_pot: u64,
        current_turn_index: u8,
        has_acted_this_round: [bool; 4],
    }

    // The GameStateManager will request actions from the players. 
    record PlayerActionRequest {
        owner: address,
        seat_index: u8,
        room_id: u32,
        nonce: u64,                 // identifies the current request, matching GameState.nonce
        stack: u64,
        highest_bet: u64,
        main_pot: u64
    }

    struct PlayerRoomConfig {
        player_address: address,
        bet: u64
    }

    // RoomConfig holds the entire poker game configuration:
    // This is public so anyone can join the game based on the configuration
    // Empty seats have address 0x000...000
    struct RoomConfig {
        big_blind: u64,
        small_blind: u64,
        min_stack: u64,
        seats: u8,
        joined_users: [PlayerRoomConfig; 4], // Address is 0x000...000 for empty seats
        num_joined_users: u8
    }

    // -----------------------------------
    // RoomManager Transitions
    // -----------------------------------

    // Create a public mapping of available rooms

        // Mapping from room_id => RoomConfig
    mapping rooms: u32 => RoomConfig;

    // A single-key mapping (using bool = true) to store the most recently used room_id
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
            num_joined_users: 1u8
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
            small_blind: config.small_blind,
            min_stack: config.min_stack,
            seats: config.seats,
            joined_users: updated_users,
            num_joined_users: config.num_joined_users + 1u8
        };
        
        // Return updated config and future for finalization
        Mapping::set(rooms, room_id, updated_config);
    }

    // async function finalize_update_room(room_id: u32, updated_config: RoomConfig) {
    //     // Update the room configuration in the mapping
    //     Mapping::set(rooms, room_id, updated_config);
    // }

    transition meat(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }
}