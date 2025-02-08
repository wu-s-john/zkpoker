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

    transition house_dealer_shuffle_random(
        house_dealer_state: HouseDealerState, 
        perm1: [u8; 26],
        perm2: [u8; 26],
    ) -> HouseDealerState {
        // Validate permutations first...
        // ... (validation code stays the same)
        assert(verify_permutation(perm1, perm2));

        // Create the new deck with all calculated positions
        let new_deck: Deck = apply_card_permutation(house_dealer_state.deck, perm1, perm2);

        return HouseDealerState {
            owner: house_dealer_state.owner,
            deck: new_deck,
            next_card_index: 0u8
        };
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

    inline apply_card_permutation(
        deck: Deck,
        perm1: [u8; 26],
        perm2: [u8; 26]
    ) -> Deck {
        let card0: Card = get_card(deck.cards1, deck.cards2, perm1[0u8]);
        let card1: Card = get_card(deck.cards1, deck.cards2, perm1[1u8]);
        let card2: Card = get_card(deck.cards1, deck.cards2, perm1[2u8]);
        let card3: Card = get_card(deck.cards1, deck.cards2, perm1[3u8]);
        let card4: Card = get_card(deck.cards1, deck.cards2, perm1[4u8]);
        let card5: Card = get_card(deck.cards1, deck.cards2, perm1[5u8]);
        let card6: Card = get_card(deck.cards1, deck.cards2, perm1[6u8]);
        let card7: Card = get_card(deck.cards1, deck.cards2, perm1[7u8]);
        let card8: Card = get_card(deck.cards1, deck.cards2, perm1[8u8]);
        let card9: Card = get_card(deck.cards1, deck.cards2, perm1[9u8]);
        let card10: Card = get_card(deck.cards1, deck.cards2, perm1[10u8]);
        let card11: Card = get_card(deck.cards1, deck.cards2, perm1[11u8]);
        let card12: Card = get_card(deck.cards1, deck.cards2, perm1[12u8]);
        let card13: Card = get_card(deck.cards1, deck.cards2, perm1[13u8]);
        let card14: Card = get_card(deck.cards1, deck.cards2, perm1[14u8]);
        let card15: Card = get_card(deck.cards1, deck.cards2, perm1[15u8]);
        let card16: Card = get_card(deck.cards1, deck.cards2, perm1[16u8]);
        let card17: Card = get_card(deck.cards1, deck.cards2, perm1[17u8]);
        let card18: Card = get_card(deck.cards1, deck.cards2, perm1[18u8]);
        let card19: Card = get_card(deck.cards1, deck.cards2, perm1[19u8]);
        let card20: Card = get_card(deck.cards1, deck.cards2, perm1[20u8]);
        let card21: Card = get_card(deck.cards1, deck.cards2, perm1[21u8]);
        let card22: Card = get_card(deck.cards1, deck.cards2, perm1[22u8]);
        let card23: Card = get_card(deck.cards1, deck.cards2, perm1[23u8]);
        let card24: Card = get_card(deck.cards1, deck.cards2, perm1[24u8]);
        let card25: Card = get_card(deck.cards1, deck.cards2, perm1[25u8]);
        let card26: Card = get_card(deck.cards1, deck.cards2, perm2[0u8]);
        let card27: Card = get_card(deck.cards1, deck.cards2, perm2[1u8]);
        let card28: Card = get_card(deck.cards1, deck.cards2, perm2[2u8]);
        let card29: Card = get_card(deck.cards1, deck.cards2, perm2[3u8]);
        let card30: Card = get_card(deck.cards1, deck.cards2, perm2[4u8]);
        let card31: Card = get_card(deck.cards1, deck.cards2, perm2[5u8]);
        let card32: Card = get_card(deck.cards1, deck.cards2, perm2[6u8]);
        let card33: Card = get_card(deck.cards1, deck.cards2, perm2[7u8]);
        let card34: Card = get_card(deck.cards1, deck.cards2, perm2[8u8]);
        let card35: Card = get_card(deck.cards1, deck.cards2, perm2[9u8]);
        let card36: Card = get_card(deck.cards1, deck.cards2, perm2[10u8]);
        let card37: Card = get_card(deck.cards1, deck.cards2, perm2[11u8]);
        let card38: Card = get_card(deck.cards1, deck.cards2, perm2[12u8]);
        let card39: Card = get_card(deck.cards1, deck.cards2, perm2[13u8]);
        let card40: Card = get_card(deck.cards1, deck.cards2, perm2[14u8]);
        let card41: Card = get_card(deck.cards1, deck.cards2, perm2[15u8]);
        let card42: Card = get_card(deck.cards1, deck.cards2, perm2[16u8]);
        let card43: Card = get_card(deck.cards1, deck.cards2, perm2[17u8]);
        let card44: Card = get_card(deck.cards1, deck.cards2, perm2[18u8]);
        let card45: Card = get_card(deck.cards1, deck.cards2, perm2[19u8]);
        let card46: Card = get_card(deck.cards1, deck.cards2, perm2[20u8]);
        let card47: Card = get_card(deck.cards1, deck.cards2, perm2[21u8]);
        let card48: Card = get_card(deck.cards1, deck.cards2, perm2[22u8]);
        let card49: Card = get_card(deck.cards1, deck.cards2, perm2[23u8]);
        let card50: Card = get_card(deck.cards1, deck.cards2, perm2[24u8]);
        let card51: Card = get_card(deck.cards1, deck.cards2, perm2[25u8]);


        // Create the new deck with all calculated positions
        let new_deck: Deck = Deck {
            cards1: [
                card0, card1, card2, card3, card4, card5, 
                card6, card7, card8, card9, card10, card11, 
                card12, card13, card14, card15, card16, card17, 
                card18, card19, card20, card21, card22, card23, 
                card24, card25
            ],
            cards2: [
                card26, card27, card28, card29, card30, card31,
                card32, card33, card34, card35, card36, card37,
                card38, card39, card40, card41, card42, card43,
                card44, card45, card46, card47, card48, card49,
                card50, card51
            ]
        };

        return new_deck;
    }

    

    function get_card(
        deck1: [Card; 26],
        deck2: [Card; 26],
        index: u8 // the index value can go from 0 to 51
    ) -> Card {
        if index == 0u8      { return deck1[0u8]; }
        else if index == 1u8 { return deck1[1u8]; }
        else if index == 2u8 { return deck1[2u8]; }
        else if index == 3u8 { return deck1[3u8]; }
        else if index == 4u8 { return deck1[4u8]; }
        else if index == 5u8 { return deck1[5u8]; }
        else if index == 6u8 { return deck1[6u8]; }
        else if index == 7u8 { return deck1[7u8]; }
        else if index == 8u8 { return deck1[8u8]; }
        else if index == 9u8 { return deck1[9u8]; }
        else if index == 10u8 { return deck1[10u8]; }
        else if index == 11u8 { return deck1[11u8]; }
        else if index == 12u8 { return deck1[12u8]; }
        else if index == 13u8 { return deck1[13u8]; }
        else if index == 14u8 { return deck1[14u8]; }
        else if index == 15u8 { return deck1[15u8]; }
        else if index == 16u8 { return deck1[16u8]; }
        else if index == 17u8 { return deck1[17u8]; }
        else if index == 18u8 { return deck1[18u8]; }
        else if index == 19u8 { return deck1[19u8]; }
        else if index == 20u8 { return deck1[20u8]; }
        else if index == 21u8 { return deck1[21u8]; }
        else if index == 22u8 { return deck1[22u8]; }
        else if index == 23u8 { return deck1[23u8]; }
        else if index == 24u8 { return deck1[24u8]; }
        else if index == 25u8 { return deck1[25u8]; }
        else if index == 26u8 { return deck2[0u8]; }
        else if index == 27u8 { return deck2[1u8]; }
        else if index == 28u8 { return deck2[2u8]; }
        else if index == 29u8 { return deck2[3u8]; }
        else if index == 30u8 { return deck2[4u8]; }
        else if index == 31u8 { return deck2[5u8]; }
        else if index == 32u8 { return deck2[6u8]; }
        else if index == 33u8 { return deck2[7u8]; }
        else if index == 34u8 { return deck2[8u8]; }
        else if index == 35u8 { return deck2[9u8]; }
        else if index == 36u8 { return deck2[10u8]; }
        else if index == 37u8 { return deck2[11u8]; }
        else if index == 38u8 { return deck2[12u8]; }
        else if index == 39u8 { return deck2[13u8]; }
        else if index == 40u8 { return deck2[14u8]; }
        else if index == 41u8 { return deck2[15u8]; }
        else if index == 42u8 { return deck2[16u8]; }
        else if index == 43u8 { return deck2[17u8]; }
        else if index == 44u8 { return deck2[18u8]; }
        else if index == 45u8 { return deck2[19u8]; }
        else if index == 46u8 { return deck2[20u8]; }
        else if index == 47u8 { return deck2[21u8]; }
        else if index == 48u8 { return deck2[22u8]; }
        else if index == 49u8 { return deck2[23u8]; }
        else if index == 50u8 { return deck2[24u8]; }
        else if index == 51u8 { return deck2[25u8]; }
        return deck2[0u8];
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