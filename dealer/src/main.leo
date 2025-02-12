// The 'dealer' program.
import room_manager.aleo;

program dealer.aleo {

    struct HouseDealerState {
        room_id: u32,
        deck: Deck,            // The shuffled deck of 52 cards (public here)
        next_card_index: u8,   // The pointer to the next card to deal (public)
        player_addresses: [address; 4] // The addresses of the players in the game
    }

    struct Card {
        rank: u8,
        suit: u8,
        index: u8
    }

    struct Deck {
        cards1: [Card; 26],
        cards2: [Card; 26],
    }

    // A simple struct for a player's public data 
    // (fields visible to everyone in the network).
    struct Player {
        player_address: address,
        stack: u64,      // The player's chip stack (public)
        contributed: u64, // The player's contribution to the pot
        folded: bool,    // Whether the player has folded
        all_in: bool     // Whether the player is all-in
    }

    struct KeyValue {
        k: u8,
        v: u8
    }
    
    struct Permutation {
        perm1: [u8; 26],
        perm2: [u8; 26],
    }

    struct PermutatedTable {
        perm1: [KeyValue; 26],
        perm2: [KeyValue; 26],
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

    record HouseDealerStateRecord {
        owner: address,
        state: HouseDealerState
    }

    // The GameStateManager will request actions from the players. 
    record PlayerActionRequest {
        owner: address,
        seat_index: u8,
        room_id: u32,
        nonce: u64,                 // identifies the current request, matching GameState.nonce
        stack: u64,
        contributed: u64,
        highest_bet: u64,
        main_pot: u64
    }

    // Private hole cards belong in a record:
    record PlayerHand {
        owner: address,       // Address that owns these hole cards
        hole_cards: [Card; 2] // Exactly two hole cards (private)
    }

    record PlayerProposedShuffle {
        owner: address,
        room_id: u32,
        seat_index: u8,
        seat_owner: address,
        dealer_nonce: u64,
        perm: Permutation,
        player_randomness: scalar // players are incentivized to provide randomness for the permutation check
    }

    record HouseDealerProposedShuffled {
        owner: address,
        perm: Permutation,
        room_id: u32,
        nonce: u64
    }

    record HouseDealerShuffleRequest {
        owner: address,
        room_id: u32,
        seat_index: u8,
    }

    // The main GameState struct holds publicly visible information.
    record GameState {
        owner: address,
        num_players: u8,
        house_dealer_actor: address,


        // Static Per Match
        dealer_seat: u8, // It is the seat of a player
        small_blind_seat: u8, // dealer_seat + 1
        big_blind_seat: u8, // dealer_seat + 2
        small_blind: u64,
        big_blind: u64,
        room_id: u32,

        // Changes Per Round
        current_phase: u8,              // 0=PRE_FLOP, 1=FLOP, etc.
        community_cards: [Card; 5],     // Indices 0-2 for flop, 3 for turn, 4 for river

        // Changing Per Player's decision
        players: [Player; 4],
        nonce: u64, // used to track valid state transitions   
        highest_bet: u64,
        main_pot: u64,
        active_player_turn_index: u8,
        has_acted_this_round: u8, // A bitmask of which players have acted this round
    }

    inline apply_permutation(
        current_perm: Permutation,
        perm_table: PermutatedTable,
        random_alpha: u64,
        random_beta: u64
    ) -> Permutation {
        // Make sure that the permutation values match with their perm_table index.
        for i: u8 in 0u8..26u8 {
            assert(current_perm.perm1[i] == perm_table.perm1[i].k);
            assert(current_perm.perm2[i] == perm_table.perm2[i].k);
        }

        // Verify the grand product over both halves.
        assert(grand_product_permutation_check(random_alpha, random_beta, current_perm, perm_table));

        // Collect the 52 cards into two arrays of 26.
        return  build_permutation(perm_table);
    }

    transition house_dealer_provide_shuffle(
        create_deck_request: room_manager.aleo/HouseDealerCreateDeckRequest,
        perm: Permutation,
        room_id: u32
    ) -> (HouseDealerProposedShuffled, HouseDealerShuffleRequest, HouseDealerShuffleRequest, HouseDealerShuffleRequest, HouseDealerShuffleRequest) {
        let shuffled: HouseDealerProposedShuffled = HouseDealerProposedShuffled {
            owner: self.caller,
            perm: perm,
            room_id: room_id,
            nonce: 0u64
        };

        let request1: HouseDealerShuffleRequest = HouseDealerShuffleRequest {
            owner: create_deck_request.player_addresses[0u8],
            room_id: room_id,
            seat_index: 0u8
        };

        let request2: HouseDealerShuffleRequest = HouseDealerShuffleRequest {
            owner: create_deck_request.player_addresses[1u8],
            room_id: room_id,
            seat_index: 1u8
        };

        let request3: HouseDealerShuffleRequest = HouseDealerShuffleRequest {
            owner: create_deck_request.player_addresses[2u8],
            room_id: room_id,
            seat_index: 2u8
        };

        let request4: HouseDealerShuffleRequest = HouseDealerShuffleRequest {
            owner: create_deck_request.player_addresses[3u8],
            room_id: room_id,
            seat_index: 3u8
        };

        return (shuffled, request1, request2, request3, request4);
    }

    inline build_permutation(permuted_table: PermutatedTable) -> Permutation {
        // Collect the 52 cards into two arrays of 26.
        let new_perm: Permutation = Permutation {
            perm1: [
                permuted_table.perm1[0u32].v,
                permuted_table.perm1[1u32].v,
                permuted_table.perm1[2u32].v,
                permuted_table.perm1[3u32].v,
                permuted_table.perm1[4u32].v,
                permuted_table.perm1[5u32].v,
                permuted_table.perm1[6u32].v,
                permuted_table.perm1[7u32].v,
                permuted_table.perm1[8u32].v,
                permuted_table.perm1[9u32].v,
                permuted_table.perm1[10u32].v,
                permuted_table.perm1[11u32].v,
                permuted_table.perm1[12u32].v,
                permuted_table.perm1[13u32].v,
                permuted_table.perm1[14u32].v,
                permuted_table.perm1[15u32].v,
                permuted_table.perm1[16u32].v,
                permuted_table.perm1[17u32].v,
                permuted_table.perm1[18u32].v,
                permuted_table.perm1[19u32].v,
                permuted_table.perm1[20u32].v,
                permuted_table.perm1[21u32].v,
                permuted_table.perm1[22u32].v,
                permuted_table.perm1[23u32].v,
                permuted_table.perm1[24u32].v,
                permuted_table.perm1[25u32].v,
            ],
            perm2: [
                permuted_table.perm2[0u32].v,
                permuted_table.perm2[1u32].v,
                permuted_table.perm2[2u32].v,
                permuted_table.perm2[3u32].v,
                permuted_table.perm2[4u32].v,
                permuted_table.perm2[5u32].v,
                permuted_table.perm2[6u32].v,
                permuted_table.perm2[7u32].v,
                permuted_table.perm2[8u32].v,
                permuted_table.perm2[9u32].v,
                permuted_table.perm2[10u32].v,
                permuted_table.perm2[11u32].v,
                permuted_table.perm2[12u32].v,
                permuted_table.perm2[13u32].v,
                permuted_table.perm2[14u32].v,
                permuted_table.perm2[15u32].v,
                permuted_table.perm2[16u32].v,
                permuted_table.perm2[17u32].v,
                permuted_table.perm2[18u32].v,
                permuted_table.perm2[19u32].v,
                permuted_table.perm2[20u32].v,
                permuted_table.perm2[21u32].v,
                permuted_table.perm2[22u32].v,
                permuted_table.perm2[23u32].v,
                permuted_table.perm2[24u32].v,
                permuted_table.perm2[25u32].v,
            ]
        };
        return new_perm;
    }

    inline null_community_cards() -> [Card; 5] {
        let null_card: Card = Card { rank: 13u8, suit: 13u8, index: 52u8 };
        return [null_card, null_card, null_card, null_card, null_card];
    }

    transition house_dealer_starts_game(
        hs: HouseDealerProposedShuffled,
        dealer_perm_table: PermutatedTable,
        shf1: PlayerProposedShuffle,
        perm_table1: PermutatedTable,
        shf2: PlayerProposedShuffle,
        perm_table2: PermutatedTable,
        shf3: PlayerProposedShuffle,
        perm_table3: PermutatedTable,
        shf4: PlayerProposedShuffle,
        perm_table4: PermutatedTable,
        final_perm_deck: Deck, // TODO: this needs to be a record
        room_config_request: room_manager.aleo/RoomConfigRequest
    ) -> (
        GameState, 
        HouseDealerStateRecord, 
        PlayerHand, 
        PlayerHand, 
        PlayerHand, 
        PlayerHand,
        PlayerActionRequest
    ) {

        // 1) Apply all permutations to produce the final HouseDealerState.
        // First validate all inputs are for the same room and game
        assert(hs.room_id == shf1.room_id);
        assert(hs.room_id == shf2.room_id);
        assert(hs.room_id == shf3.room_id);
        assert(hs.room_id == shf4.room_id);

        // Verify each shuffle corresponds to the correct seat
        assert(shf1.seat_index == 0u8);
        assert(shf2.seat_index == 1u8);
        assert(shf3.seat_index == 2u8);
        assert(shf4.seat_index == 3u8);

        // Construct random alpha and beta by combining player provided randomness
        let combined_random: field = 
            BHP256::hash_to_field(shf1.player_randomness) + 
            BHP256::hash_to_field(shf2.player_randomness) + 
            BHP256::hash_to_field(shf3.player_randomness) + 
            BHP256::hash_to_field(shf4.player_randomness);

        // Hash combined random value to get alpha
        let random_alpha: u64 = (BHP256::hash_to_field(combined_random) as u64);
        
        // Hash combined random value + 1 to get beta 
        let random_beta: u64 = (BHP256::hash_to_field(combined_random + 1field) as u64);

        // 1) Compose or combine these four permutations off-chain (if desired),
        //    or apply them in sequence. This ensures no single entity can fully
        //    control the final deck order.
        let shuffle_after_dealer: Permutation = apply_permutation(
            hs.perm,
            dealer_perm_table,
            random_alpha,
            random_beta
        );

        let shuffle_after_player1: Permutation = apply_permutation(
            shuffle_after_dealer,
            perm_table1,
            random_alpha,
            random_beta
        );

        let shuffle_after_player2: Permutation = apply_permutation(
            shuffle_after_player1,
            perm_table2,
            random_alpha,
            random_beta
        );

        let shuffle_after_player3: Permutation = apply_permutation(
            shuffle_after_player2,
            perm_table3,
            random_alpha,
            random_beta
        );

        let shuffle_after_player4: Permutation = apply_permutation(
            shuffle_after_player3,
            perm_table4,
            random_alpha,
            random_beta
        );

        for i: u8 in 0u8..26u8 {
            assert(final_perm_deck.cards1[i].index == shuffle_after_player4.perm1[i]);
            assert(final_perm_deck.cards2[i].index == shuffle_after_player4.perm2[i]);
        }

        let final_dealer_state: HouseDealerState = HouseDealerState {
            room_id: hs.room_id,
            deck: final_perm_deck,
            next_card_index: 0u8,
            player_addresses: [
                shf1.seat_owner,
                shf2.seat_owner,
                shf3.seat_owner,
                shf4.seat_owner
            ]
        };

        // 2) Create the new GameState record from the room config.
        // Initialize an array of Players with default values
        let initial_players: [Player; 4] = [
            Player { player_address: room_config_request.room_config.joined_users[0u8].player_address, stack: room_config_request.room_config.joined_users[0u8].bet, contributed: 0u64, folded: false, all_in: false },
            Player { player_address: room_config_request.room_config.joined_users[1u8].player_address, stack: room_config_request.room_config.joined_users[1u8].bet, contributed: 0u64, folded: false, all_in: false },
            Player { player_address: room_config_request.room_config.joined_users[2u8].player_address, stack: room_config_request.room_config.joined_users[2u8].bet, contributed: 0u64, folded: false, all_in: false },
            Player { player_address: room_config_request.room_config.joined_users[3u8].player_address, stack: room_config_request.room_config.joined_users[3u8].bet, contributed: 0u64, folded: false, all_in: false }
        ];

        // Construct and return the new GameState record
        let game_state: GameState = GameState {
            owner: room_config_request.room_config.game_state_manager_address,
            players: initial_players,
            num_players: room_config_request.room_config.num_joined_users,
            house_dealer_actor: self.caller,  
            room_id: room_config_request.room_config.room_id,
            nonce: 0u64,               
            small_blind_seat: room_config_request.room_config.small_blind_seat,
            big_blind_seat: room_config_request.room_config.big_blind_seat,
            small_blind: room_config_request.room_config.small_blind,
            big_blind: room_config_request.room_config.big_blind,
            dealer_seat: room_config_request.room_config.dealer_seat,
            current_phase: 0u8,      
            community_cards: null_community_cards(), 
            highest_bet: 0u64,
            main_pot: 0u64,
            has_acted_this_round: 0u8,
            active_player_turn_index: (room_config_request.room_config.big_blind_seat + 1u8) % room_config_request.room_config.num_joined_users
        };

        // 3) Deal two hole cards to each player, returning an updated HouseDealerState plus 4 PlayerHands.
        let deck: Deck = final_dealer_state.deck;

        // For example, dealing from deck.cards1
        let card0_1: Card = deck.cards1[0u8];
        let card0_2: Card = deck.cards1[1u8];
        let card1_1: Card = deck.cards1[2u8];
        let card1_2: Card = deck.cards1[3u8];
        let card2_1: Card = deck.cards1[4u8];
        let card2_2: Card = deck.cards1[5u8];
        let card3_1: Card = deck.cards1[6u8];
        let card3_2: Card = deck.cards1[7u8];

        // Update the dealer state to point to the next card
        let new_dealer_state: HouseDealerState = HouseDealerState {
            deck: deck,
            room_id: final_dealer_state.room_id,
            next_card_index: 8u8,
            player_addresses: final_dealer_state.player_addresses
        };

        let p0_hand: PlayerHand = PlayerHand {
            owner: final_dealer_state.player_addresses[0u8],
            hole_cards: [card0_1, card0_2]
        };
        let p1_hand: PlayerHand = PlayerHand {
            owner: final_dealer_state.player_addresses[1u8],
            hole_cards: [card1_1, card1_2]
        };
        let p2_hand: PlayerHand = PlayerHand {
            owner: final_dealer_state.player_addresses[2u8],
            hole_cards: [card2_1, card2_2]
        };
        let p3_hand: PlayerHand = PlayerHand {
            owner: final_dealer_state.player_addresses[3u8],
            hole_cards: [card3_1, card3_2]
        };

        // Create a PlayerActionRequest for the seat that is about to act first (after blinds).
        let next_seat: u8 = game_state.active_player_turn_index;
        let next_player: Player = select_player(game_state.players, next_seat);
        
        let first_request: PlayerActionRequest = PlayerActionRequest {
            owner: next_player.player_address,
            seat_index: next_seat,
            room_id: game_state.room_id,
            nonce: game_state.nonce,
            stack: next_player.stack,
            contributed: next_player.contributed,
            highest_bet: game_state.highest_bet,
            main_pot: game_state.main_pot
        };

        let dealer_state_record: HouseDealerStateRecord = HouseDealerStateRecord {
            owner: self.caller,
            state: new_dealer_state
        };

        // Return everything needed to continue: the new GameState, dealer state, each player's hole cards, and the initial PlayerActionRequest.
        return (
            game_state,
            dealer_state_record,
            p0_hand,
            p1_hand,
            p2_hand,
            p3_hand,
            first_request
        );
    }

    // We can apply ALL players' permutations in one go. The RoomManager collects them
    // (or the Dealer accumulates them) and composes a single final permutation.
    // Then we reorder the deck in HouseDealerState.


    transition house_dealer_deal_flop(hs: HouseDealerState, game_state_manager_address: address) -> (HouseDealerState, DealtThreeCommunityCards) {
        // Copy the current deck and the index of the next card
        let deck: Deck = hs.deck;
        let start_index: u8 = hs.next_card_index;

        assert(start_index == 8u8);


        // Burn the first card and pull the next 3 cards from the deck
        let flop_card_1: Card = deck.cards1[9u8];
        let flop_card_2: Card = deck.cards1[10u8];
        let flop_card_3: Card = deck.cards1[11u8];

        // Update the dealer state to point to the next card
        let new_dealer_state: HouseDealerState = HouseDealerState {
            room_id: hs.room_id,
            deck: deck,
            next_card_index: 12u8,
            player_addresses: hs.player_addresses
        };

        // Create the DealtThreeCommunityCards record
        // Using sample/placeholder values for room_id and is_next_phase_turn
        let dealt_three: DealtThreeCommunityCards = DealtThreeCommunityCards {
            owner: game_state_manager_address,
            cards: [flop_card_1, flop_card_2, flop_card_3],
            room_id: hs.room_id,
            is_next_phase_turn: true,
        };

        // Return both the updated dealer state and the record of dealt cards
        return (new_dealer_state, dealt_three);
    }

    transition house_dealer_deal_turn(hs: HouseDealerState, game_state_manager_address: address) -> (HouseDealerState, DealtOneCommunityCard) {
        // Copy the current deck and the index of the next card
        let deck: Deck = hs.deck;
        let start_index: u8 = hs.next_card_index;

        assert(start_index == 12u8);

        // The card to actually deal (turn or river)
        let deal_card: Card = deck.cards1[13u8];

        // Update the dealer state, advancing past the burn card and the dealt card
        let new_dealer_state: HouseDealerState = HouseDealerState {
            room_id: hs.room_id,
            deck: deck,
            next_card_index: 14u8,
            player_addresses: hs.player_addresses
        };

        // Prepare the DealtOneCommunityCard record
        let dealt_one: DealtOneCommunityCard = DealtOneCommunityCard {
            owner: game_state_manager_address,
            card: deal_card,
            is_turn: true,
            room_id: hs.room_id
        };

        return (new_dealer_state, dealt_one);
    }

    transition house_dealer_deal_river(hs: HouseDealerState, game_state_manager_address: address) -> (HouseDealerState, DealtOneCommunityCard) {
        // Copy the current deck and the index of the next card
        let deck: Deck = hs.deck;
        let start_index: u8 = hs.next_card_index;

        // For example, ensure we've just dealt the turn (start_index == 14u8).
        assert(start_index == 14u8);

        // Take the card at index 15 as the river card
        let deal_card: Card = deck.cards1[15u8];

        // Update the dealer state, advancing to index 16
        let new_dealer_state: HouseDealerState = HouseDealerState {
            room_id: hs.room_id,
            deck: deck,
            next_card_index: 16u8,
            player_addresses: hs.player_addresses
        };

        // Prepare the DealtOneCommunityCard record
        let dealt_one: DealtOneCommunityCard = DealtOneCommunityCard {
            owner: game_state_manager_address,
            card: deal_card,
            // Since this is the river, "is_turn" is false
            is_turn: false,
            room_id: hs.room_id
        };

        return (new_dealer_state, dealt_one);
    }

    function grand_product_permutation_check(
        random_alpha: u64,
        random_beta: u64,
        perm: Permutation,
        rearranged_perm: PermutatedTable
    ) -> bool {
        let product: u64 = 1u64;
        let product_sorted: u64 = 1u64;

        // First half (0..26).
        for i: u64 in 0u64..26u64 {
            product *= ((perm.perm1[i] as u64) + i*random_alpha + random_beta);
            product_sorted *= ((rearranged_perm.perm1[i].v as u64) + i*random_alpha + random_beta);
        }

        // Second half (26..52).
        for i: u64 in 0u64..26u64 {
            let j: u64 = i + 26u64;
            product *= ((perm.perm2[i] as u64) + j*random_alpha + random_beta);
            product_sorted *= ((rearranged_perm.perm2[i].v as u64) + j*random_alpha + random_beta);
        }

        return product == product_sorted;
    }

    inline verify_permutation(
        perm: Permutation
    ) -> bool {
        let bitset: u64 = 0u64;
        for i: u8 in 0u8..26u8 {
            bitset |= 1u64 << perm.perm1[i];
            bitset |= 1u64 << perm.perm2[i];
        }
        return bitset == 0u64; // TODO: This is a placeholder
    }

    inline select_player(players: [Player; 4], seat_index: u8) -> Player {
        if seat_index == 0u8 {
            return players[0u8];
        } else if seat_index == 1u8 {
            return players[1u8];
        } else if seat_index == 2u8 {
            return players[2u8];
        } else {
            return players[3u8];
        }
    }

    transition main(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }
}
