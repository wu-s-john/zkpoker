// The 'hello' program.
program zkpoker.aleo {
    // -----------------------------------
    // HouseDealer Functions and Transitions
    // -----------------------------------
    struct Card {
        val: u32,
        index: u8
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

    struct KeyValue {
        k: u8,
        v: Card
    }

    transition shuffle_deck(
        house_dealer_state: HouseDealerState,
        perm1: [u8; 26],
        perm2: [u8; 26],
        sorted_deck1: [KeyValue; 26],
        sorted_deck2: [KeyValue; 26]
    ) -> HouseDealerState {
        // Make sure that the permutation values match with their sorted_deck index.
        for i: u8 in 0u8..26u8 {
            assert(perm1[i] == sorted_deck1[i].k);
            assert(perm2[i] == sorted_deck2[i].k);
        }

        // Verify the grand product over both halves.
        assert(grand_product_permutation_check(perm1, perm2, sorted_deck1, sorted_deck2));

        // Collect the 52 cards into two arrays of 26.
        let new_deck: Deck = Deck {
            cards1: [
                sorted_deck1[0u32].v,
                sorted_deck1[1u32].v,
                sorted_deck1[2u32].v,
                sorted_deck1[3u32].v,
                sorted_deck1[4u32].v,
                sorted_deck1[5u32].v,
                sorted_deck1[6u32].v,
                sorted_deck1[7u32].v,
                sorted_deck1[8u32].v,
                sorted_deck1[9u32].v,
                sorted_deck1[10u32].v,
                sorted_deck1[11u32].v,
                sorted_deck1[12u32].v,
                sorted_deck1[13u32].v,
                sorted_deck1[14u32].v,
                sorted_deck1[15u32].v,
                sorted_deck1[16u32].v,
                sorted_deck1[17u32].v,
                sorted_deck1[18u32].v,
                sorted_deck1[19u32].v,
                sorted_deck1[20u32].v,
                sorted_deck1[21u32].v,
                sorted_deck1[22u32].v,
                sorted_deck1[23u32].v,
                sorted_deck1[24u32].v,
                sorted_deck1[25u32].v,
            ],
            cards2: [
                sorted_deck2[0u32].v,
                sorted_deck2[1u32].v,
                sorted_deck2[2u32].v,
                sorted_deck2[3u32].v,
                sorted_deck2[4u32].v,
                sorted_deck2[5u32].v,
                sorted_deck2[6u32].v,
                sorted_deck2[7u32].v,
                sorted_deck2[8u32].v,
                sorted_deck2[9u32].v,
                sorted_deck2[10u32].v,
                sorted_deck2[11u32].v,
                sorted_deck2[12u32].v,
                sorted_deck2[13u32].v,
                sorted_deck2[14u32].v,
                sorted_deck2[15u32].v,
                sorted_deck2[16u32].v,
                sorted_deck2[17u32].v,
                sorted_deck2[18u32].v,
                sorted_deck2[19u32].v,
                sorted_deck2[20u32].v,
                sorted_deck2[21u32].v,
                sorted_deck2[22u32].v,
                sorted_deck2[23u32].v,
                sorted_deck2[24u32].v,
                sorted_deck2[25u32].v,
            ]
        };

        return HouseDealerState {
            owner: house_dealer_state.owner,
            deck: new_deck,
            next_card_index: 0u8
        };
    }

    inline grand_product_permutation_check(
        perm1: [u8; 26],
        perm2: [u8; 26],
        sorted_perm1: [KeyValue; 26],
        sorted_perm2: [KeyValue; 26]
    ) -> bool {
        let product: u64 = 1u64;
        let product_sorted: u64 = 1u64;

        // First half (0..26).
        for i: u8 in 0u8..26u8 {
            product *= ((perm1[i] as u64) + (i as u64)*1u64 + 1u64);
            product_sorted *= ((sorted_perm1[i].v.index as u64) + (i as u64)*1u64 + 1u64);
        }

        // Second half (26..52).
        for i: u8 in 0u8..26u8 {
            let j: u64 = (i as u64) + 26u64;
            product *= ((perm2[i] as u64) + j*1u64 + 1u64);
            product_sorted *= ((sorted_perm2[i].v.index as u64) + j*1u64 + 1u64);
        }

        return product == product_sorted;
    }

    function verify_permutation(
        perm1: [u8; 26],
        perm2: [u8; 26]
    ) -> bool {
        let bitset: u64 = 0u64;
        for i: u8 in 0u8..26u8 {
            bitset |= 1u64 << perm1[i];
            bitset |= 1u64 << perm2[i];
        }
        return bitset == 0u64;
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

    record RoomConfigRequest {
        room_id: u32,
        room_config: RoomConfig,
        owner: address
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

    async transition rm_request_game_creation(room_id: u32, room_config: RoomConfig, dealer_address: address) -> (RoomConfigRequest, HouseDealerCreateDeckRequest, Future) {
        // Get the current room configuration
        
        // Verify room is full
        assert(room_config.num_joined_users == room_config.seats);
        assert(room_config.num_joined_users == 4u8);
        
        // Create deck request with room details
        let deck_request: HouseDealerCreateDeckRequest = HouseDealerCreateDeckRequest {
            room_id: room_id,
            owner: dealer_address,
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