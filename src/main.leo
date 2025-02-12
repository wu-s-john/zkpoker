import dealer.aleo;
import room_manager.aleo;

// The 'hello' program.
program zkpoker.aleo {
    // -----------------------------------
    // HouseDealer Functions and Transitions
    // -----------------------------------
    struct Card {
        rank: u8,
        suit: u8,
        index: u8
    }

    struct Deck {
        cards1: [Card; 26],
        cards2: [Card; 26],
    }

    struct HouseDealerState {
        room_id: u32,
        deck: Deck,            // The shuffled deck of 52 cards (public here)
        next_card_index: u8,   // The pointer to the next card to deal (public)
        player_addresses: [address; 4] // The addresses of the players in the game
    }

    record CommunityCards {
        owner: address,
        cards: [Card; 5],
        room_id: u32
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

    record PlayerProposedShuffle {
        owner: address,
        room_id: u32,
        seat_index: u8,
        seat_owner: address,
        dealer_nonce: u64,
        perm: Permutation,
        player_randomness: scalar // players are incentivized to provide randomness for the permutation check
    }

    // These actions fulfill requests that the game state manager requires to move 
    // the game forward.
    record PlayerActionResponse {
        owner: address,
        seat_index: u8,
        room_id: u32,
        stack: u64,
        nonce: u64,
        contributed: u64,
        // 0 = Fold, 1 = Call, 2 = Raise, 3 = All-In
        action_type: u8,
        // Use this amount for raise or all-in actions; can be 0 for fold or call
        amount: u64
    }

    record PlayerFinalHandRequest {
        owner: address,
        room_id: u32,
        seat_index: u8,
        did_fold: bool
    }

    // Private hole cards belong in a record:
    record PlayerHand {
        owner: address,       // Address that owns these hole cards
        hole_cards: [Card; 2] // Exactly two hole cards (private)
    }

    // A record to store a player's final hand and score at showdown
    record FinalHand {
        owner: address,        // The address owning this final hand
        seat_index: u8,
        did_fold: bool,        // Whether the player folded
        final_score: u32,      // The numerical score of the hand (private or revealed)
        // The final_score is computed as a single 32-bit value that encodes both the hand category and card ranks
        // Format: (category << 24) + (c1 << 20) + (c2 << 16) + (c3 << 12) + (c4 << 8) + (c5 << 4)
        // Where:
        // - category is the hand type (1-10):
        //   1 = High Card, 2 = Pair, 3 = Two Pair, 4 = Three of Kind, 5 = Straight,
        //   6 = Flush, 7 = Full House, 8 = Four of Kind, 9 = Straight Flush, 10 = Royal Flush
        // - c1..c5 are the relevant card ranks (2-14) in descending order based on hand type
        // - Each rank uses 4 bits since max rank is 14 (Ace)
        // This encoding ensures proper ordering when comparing hands as single integers
        player_hand: [Card; 2] // The player's hole cards (private)
    }

    transition player_propose_shuffle(
        perm: Permutation, 
        hs_shuffle_request: HouseDealerShuffleRequest
    ) -> PlayerProposedShuffle {
        // Optional: Ensure that only the request owner can propose the shuffle.
        // Depending on your desired security model, you could also check that
        // self.caller is indeed the seat owner for hs_shuffle_request.seat_index.
        assert(hs_shuffle_request.owner == self.caller);

        assert(verify_permutation(perm));

        // Create and return the PlayerProposedShuffle record.
        // In a real flow, you might set dealer_nonce or player_randomness from
        // user input, off-chain randomness, etc. Here we'll use placeholders.
        let proposed_shuffle: PlayerProposedShuffle = PlayerProposedShuffle {
            owner: self.caller,
            room_id: hs_shuffle_request.room_id,
            seat_index: hs_shuffle_request.seat_index,
            seat_owner: self.caller,
            dealer_nonce: 0u64,              // placeholder
            perm: perm,
            player_randomness: 0scalar      // placeholder
        };

        return proposed_shuffle;
    }

    transition player_submit_action(
        request: dealer.aleo/PlayerActionRequest,
        action_type: u8,
        amount: u64
    ) -> PlayerActionResponse {

        // Use if-else statements to handle the action_type.
        if action_type == 0u8 {
            // Fold
            // Typically, a fold has amount = 0
            assert(amount == 0u64);
        } else if action_type == 1u8 {
            // Call
            // The "amount" for call should be the difference between the highest bet and the contributed amount.
            let call_amount: u64 = request.highest_bet - request.contributed;
            assert(amount == call_amount && amount <= request.stack);
        } else if action_type == 2u8 {
            // Raise
            // For a raise, "amount" is the total bet the player wants to make, which should be greater than the highest bet.
            assert(amount + request.contributed > request.highest_bet && amount <= request.stack);
        } else if action_type == 3u8 {
            // All-In
            // The player puts all chips into the pot. "amount" should be <= stack.
            assert(0u64 < amount && amount == request.stack);
        } else {
            // Invalid action_type
            assert(false);
        }
        // Build and return the validated player action record.
        return PlayerActionResponse {
            owner: self.caller,
            nonce: request.nonce,
            seat_index: request.seat_index,
            room_id: request.room_id,
            stack: request.stack - amount,
            contributed: request.contributed + amount,
            action_type,
            amount
        };
    }

    // // They manage who will be the next player to act
    transition gsm_process_action_next_betting(
        gs: GameState, 
        action: PlayerActionResponse
    ) -> (GameState, PlayerActionRequest) {
        // 1) Basic checks
        //   - The room id and seat index must be valid
        //   - The nonce must match the game state's nonce
        //   - We need to make sure if there will be a betting phase afterwards。 Otherwise, abort.
        assert(gs.room_id == action.room_id);
        assert(action.seat_index < gs.num_players);
        assert(gs.nonce == action.nonce);
        let next_nonce: u64 = gs.nonce + 1u64;

        // 2) Check that we are still in the betting phase after the user's contribution
        let next_active_player_turn_index: u8 = get_next_player_turn_index(gs.has_acted_this_round, action.seat_index, action.action_type);
        assert(next_active_player_turn_index < 4u8); // The only legal values are 0-3. Otherwise, if it's not in those values, then we are not in the betting phase
        let next_has_acted_this_round: u8 = gs.has_acted_this_round;
        next_has_acted_this_round |= 1u8 << action.seat_index;

        // 3) Updated Players
        let next_players: [Player; 4] = update_players(gs.players, action.action_type, action.seat_index, action.amount, action.stack, action.contributed);

        // 4) Update main pot and highest bet
        let next_main_pot: u64 = gs.main_pot + action.amount;
        let next_highest_bet: u64 = max_u64(gs.highest_bet, action.amount + action.stack);

        let next_player: Player = select_player(gs.players, next_active_player_turn_index);


        let new_state: GameState = GameState {
            owner: gs.owner,
            num_players: gs.num_players,
            house_dealer_actor: gs.house_dealer_actor,
            dealer_seat: gs.dealer_seat,
            small_blind_seat: gs.small_blind_seat,
            big_blind_seat: gs.big_blind_seat,
            small_blind: gs.small_blind,
            big_blind: gs.big_blind,
            room_id: gs.room_id,
            current_phase: gs.current_phase,
            community_cards: gs.community_cards,
            players: next_players,
            nonce: next_nonce,
            highest_bet: next_highest_bet,
            main_pot: next_main_pot,
            active_player_turn_index: next_active_player_turn_index,
            has_acted_this_round: next_has_acted_this_round
        };

        let next_request: PlayerActionRequest = PlayerActionRequest {
            owner: next_player.player_address,
            seat_index: next_active_player_turn_index,
            room_id: gs.room_id,
            nonce: next_nonce,
            stack: next_player.stack,
            contributed: next_player.contributed,
            highest_bet: next_highest_bet,
            main_pot: next_main_pot
        };

        return (new_state, next_request);
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

    inline get_next_player_turn_index(
        has_acted_mask: u8,
        current_seat_index: u8,
        action_type: u8
    ) -> u8 {
        // A simple example that loops around up to 4 seats, returning the first seat that hasn't acted.
        // If none is found, return 4u8 (which can be handled to indicate betting is complete).
        let candidate_seat: u8 = (current_seat_index + 1u8) % 4u8;

        for i: u8 in 0u8..4u8 {
            // TODO: see if if statements are updated

            // Check if this seat has already acted in this round (bit test).
            let mask_bit: u8 = (has_acted_mask >> candidate_seat) & 1u8;

            // For demonstration, if the candidate seat hasn't acted (mask_bit == 0u8)
            // we return it. You could add additional checks (folded/all-in) if you track them.
            if mask_bit == 0u8 {
                return candidate_seat;
            }

            // Otherwise, move to the next seat.
            candidate_seat = (candidate_seat + 1u8) % 4u8;
        }

        // If all seats have acted, return a sentinel (4u8).
        return 4u8;
    }

    inline update_players(
        players: [Player; 4],
        action_type: u8,
        seat_index: u8,
        amount: u64,
        new_stack: u64,
        new_contributed: u64
    ) -> [Player; 4] {
        return [
            seat_index == 0u8 ? update_player(players[0u8], action_type, amount, new_stack, new_contributed) : players[0u8],
            seat_index == 1u8 ? update_player(players[1u8], action_type, amount, new_stack, new_contributed) : players[1u8],
            seat_index == 2u8 ? update_player(players[2u8], action_type, amount, new_stack, new_contributed) : players[2u8],
            seat_index == 3u8 ? update_player(players[3u8], action_type, amount, new_stack, new_contributed) : players[3u8]
        ];
    }

    inline update_player(
        player: Player,
        action_type: u8,
        amount: u64,
        new_stack: u64,
        new_contributed: u64
    ) -> Player {
        let is_all_in: bool = action_type == 3u8;
        let is_folded: bool = action_type == 0u8;
        
        // Optional sanity check:
        // Uncomment the line below to ensure that the updated total contribution matches the expected sum.
        // assert(new_contributed == player.contributed + amount);
        
        return Player {
            player_address: player.player_address,
            stack: new_stack,
            contributed: new_contributed,
            folded: is_folded,
            all_in: is_all_in
        };
    }


    inline max_u64(a: u64, b: u64) -> u64 {
        if a >= b {
            return a;
        } else {
            return b;
        }
    }

    transition gsm_advance_phase_flop(
        gs: GameState, 
        dealt_cards: DealtThreeCommunityCards, 
        last_player_action: PlayerActionResponse
    ) -> (GameState, PlayerActionRequest) {

        // -------------------------------------------------------------------------
        // 1. Ensure we are still in the PRE_FLOP phase (assume 0u8 == PRE_FLOP)
        // -------------------------------------------------------------------------
        assert(gs.current_phase == 0u8);

        // -------------------------------------------------------------------------
        // 2. Ensure all players have already betted. For instance, if your 
        //    'get_next_player' helper returns 4 when no seats need to bet, 
        //    we check that here.
        // -------------------------------------------------------------------------
        let next_player_index: u8 = get_next_player_turn_index(gs.has_acted_this_round, last_player_action.seat_index, last_player_action.action_type);
        assert(next_player_index == 4u8);

        // -------------------------------------------------------------------------
        // 3. Reveal the FLOP by populating community_cards indices [0..2]
        // -------------------------------------------------------------------------
        let updated_community_cards: [Card; 5] = [
            dealt_cards.cards[0u8],
            dealt_cards.cards[1u8],
            dealt_cards.cards[2u8],
            gs.community_cards[3u8],
            gs.community_cards[4u8]
        ];

        // Move from PRE-FLOP (0) to FLOP (1).
        

        // -------------------------------------------------------------------------
        // 4. Bump the nonce (general safeguard for state transitions)
        // -------------------------------------------------------------------------
        let new_nonce: u64 = gs.nonce + 1u64;


        // -------------------------------------------------------------------------
        // 5. Create a new PlayerActionRequest for the next betting round
        //    (You can customize seat selection logic below as needed)
        // -------------------------------------------------------------------------

        // Determine the next active player after the big blind seat
        let next_potential_seats: [u8; 4] = [
            gs.big_blind_seat, 
            (gs.big_blind_seat + 1u8) % gs.num_players, 
            (gs.big_blind_seat + 2u8) % gs.num_players, 
            (gs.big_blind_seat + 3u8) % gs.num_players
        ];
        let active_players_mask: u8 = 0u8;
        for i: u8 in 0u8..4u8 {
            if next_potential_seats[i] != 0u8 {
                active_players_mask |= 1u8 << next_potential_seats[i];
            }
        }

        let next_seat: u8 = find_next_active_player(active_players_mask, gs.dealer_seat);

        let new_gs: GameState = GameState {
            owner: gs.owner,
            num_players: gs.num_players,
            house_dealer_actor: gs.house_dealer_actor,
            dealer_seat: gs.dealer_seat,
            small_blind_seat: gs.small_blind_seat,
            big_blind_seat: gs.big_blind_seat,
            small_blind: gs.small_blind,
            big_blind: gs.big_blind,
            room_id: gs.room_id,

            current_phase: 1u8,
            community_cards: updated_community_cards,
            players: gs.players,
            nonce: new_nonce,
            highest_bet: gs.highest_bet,
            main_pot: gs.main_pot,
            active_player_turn_index: next_seat,
            has_acted_this_round: active_players_mask ^ 15u8
        };

        let next_player: Player = select_player(new_gs.players, next_seat);

        let action_request: PlayerActionRequest = PlayerActionRequest {
            owner: next_player.player_address,
            seat_index: next_seat,
            room_id: new_gs.room_id,
            nonce: new_nonce,
            stack: next_player.stack,
            contributed: next_player.contributed,
            highest_bet: new_gs.highest_bet,
            main_pot: new_gs.main_pot
        };

        // Return the updated game state and the new action request
        return (new_gs, action_request);
    }

    transition gsm_advance_phase_turn_river(
        gs: GameState, 
        dealt_card: DealtOneCommunityCard, 
        last_player_action: PlayerActionResponse,
        is_turn: bool
    ) -> (GameState, PlayerActionRequest) {

        // -------------------------------------------------------------------------
        // 1. Ensure we are still in the PRE_FLOP phase (assume 0u8 == PRE_FLOP)
        // -------------------------------------------------------------------------
        assert(is_turn ? gs.current_phase == 1u8 : gs.current_phase == 2u8);

        // -------------------------------------------------------------------------
        // 2. Ensure all players have already betted. For instance, if your 
        //    'get_next_player' helper returns 4 when no seats need to bet, 
        //    we check that here.
        // -------------------------------------------------------------------------
        let next_player_index: u8 = get_next_player_turn_index(gs.has_acted_this_round, last_player_action.seat_index, last_player_action.action_type);
        assert(next_player_index == 4u8);

        // -------------------------------------------------------------------------
        // 3. Reveal the FLOP by populating community_cards indices [0..2]
        // -------------------------------------------------------------------------
        let updated_community_cards: [Card; 5] = [
            gs.community_cards[0u8],
            gs.community_cards[1u8],
            gs.community_cards[2u8],
            dealt_card.card,
            gs.community_cards[4u8]
        ];

        // Move from PRE-FLOP (0) to FLOP (1).
        

        // -------------------------------------------------------------------------
        // 4. Bump the nonce (general safeguard for state transitions)
        // -------------------------------------------------------------------------
        let new_nonce: u64 = gs.nonce + 1u64;


        // -------------------------------------------------------------------------
        // 5. Create a new PlayerActionRequest for the next betting round
        //    (You can customize seat selection logic below as needed)
        // -------------------------------------------------------------------------

        // Determine the next active player after the big blind seat
        let next_potential_seats: [u8; 4] = [
            gs.big_blind_seat, 
            (gs.big_blind_seat + 1u8) % gs.num_players, 
            (gs.big_blind_seat + 2u8) % gs.num_players, 
            (gs.big_blind_seat + 3u8) % gs.num_players
        ];
        let active_players_mask: u8 = 0u8;
        for i: u8 in 0u8..4u8 {
            if next_potential_seats[i] != 0u8 {
                active_players_mask |= 1u8 << next_potential_seats[i];
            }
        }

        let next_seat: u8 = find_next_active_player(active_players_mask, gs.dealer_seat); // TODO: FIX. Also handle the case where the next seats are all folded or all in

        let new_gs: GameState = GameState {
            owner: gs.owner,
            num_players: gs.num_players,
            house_dealer_actor: gs.house_dealer_actor,
            dealer_seat: gs.dealer_seat,
            small_blind_seat: gs.small_blind_seat,
            big_blind_seat: gs.big_blind_seat,
            small_blind: gs.small_blind,
            big_blind: gs.big_blind,
            room_id: gs.room_id,

            current_phase: gs.current_phase + 1u8,
            community_cards: updated_community_cards,
            players: gs.players,
            nonce: new_nonce,
            highest_bet: gs.highest_bet,
            main_pot: gs.main_pot,
            active_player_turn_index: next_seat,
            has_acted_this_round: active_players_mask
        };

        let next_player: Player = select_player(new_gs.players, next_seat);

        let action_request: PlayerActionRequest = PlayerActionRequest {
            owner: next_player.player_address,
            seat_index: next_seat,
            room_id: new_gs.room_id,
            nonce: new_nonce,
            stack: next_player.stack,
            contributed: next_player.contributed,
            highest_bet: new_gs.highest_bet,
            main_pot: new_gs.main_pot
        };

        // Return the updated game state and the new action request
        return (new_gs, action_request);
    }


    inline find_next_active_player(active_players_mask: u8, dealer_seat: u8) -> u8 {
        // Create a mask for bits after the dealer (but only up to 4 bits total)
        let higher_bits_mask: u8 = (((1u8 << 4u8) - 1u8) << dealer_seat) & 15u8; // 15u8 is 0b1111
        
        // Get only the active players after the dealer
        let higher_active_players: u8 = active_players_mask & higher_bits_mask;
        
        // If there are active players after the dealer, find the rightmost one
        if higher_active_players != 0u8 {
            return find_rightmost_set_bit(higher_active_players);
        }
        
        // If no active players after dealer, look at players before dealer
        let lower_bits_mask: u8 = ((1u8 << dealer_seat) - 1u8) & 15u8;
        let lower_active_players: u8 = active_players_mask & lower_bits_mask;
        
        // Return the rightmost set bit in the lower active players
        return find_rightmost_set_bit(lower_active_players);
    }

    inline find_rightmost_set_bit(mask: u8) -> u8 {
        // Only need to check 4 bits
        if (mask & 1u8) != 0u8 { return 0u8; }
        if (mask & 2u8) != 0u8 { return 1u8; }
        if (mask & 4u8) != 0u8 { return 2u8; }
        if (mask & 8u8) != 0u8 { return 3u8; }
        return 0u8; // Should never reach here if mask != 0
    }


    // We need an individual player to show their winning hand 
    // This transition will have a player choose their winning hand and they will demonstrate who will will win
    // Sine the hand is sorted, we can easily verify the hand corresponds to a certain combo
    transition player_show_winning_hand(
        player_final_hand_request: PlayerFinalHandRequest,
        player_hand: [Card; 2],
        community_hand: [Card; 5],
        sorted_hand: [Card; 7],
        combo_indicator: u8
    ) -> FinalHand {
        if player_final_hand_request.did_fold {
            return FinalHand {
                owner: player_final_hand_request.owner,
                seat_index: player_final_hand_request.seat_index,
                did_fold: true,
                final_score: 0u32,
                player_hand: player_hand
            };
        }

        // Verify that the sorted_hand corresponds to the combo_indicator
        assert(combo_indicator <= 9u8);

        if combo_indicator == 9u8 {
            // Royal Flush
            assert(sorted_hand[0u8].rank == 14u8);
            assert(sorted_hand[1u8].rank == 13u8);
            assert(sorted_hand[2u8].rank == 12u8);
            assert(sorted_hand[3u8].rank == 11u8);
            assert(sorted_hand[4u8].rank == 10u8);
        } else if combo_indicator == 8u8 {
            // Straight Flush
            let initial_value: u8 = sorted_hand[0u8].rank;
            assert(
                initial_value + 1u8 == sorted_hand[1u8].rank ||
                initial_value + 2u8 == sorted_hand[1u8].rank ||
                initial_value + 3u8 == sorted_hand[1u8].rank ||
                initial_value + 4u8 == sorted_hand[1u8].rank
            );
        } else if combo_indicator == 7u8 {
            // Four of a Kind
            let rank_of_four: u8 = sorted_hand[0u8].rank;
            assert(rank_of_four == sorted_hand[1u8].rank);
            assert(rank_of_four == sorted_hand[2u8].rank);
            assert(rank_of_four == sorted_hand[3u8].rank);
        } else if combo_indicator == 6u8 {
            // Full House
            // Verified that the first 3 cards are the same rank
            assert(sorted_hand[0u8].rank == sorted_hand[1u8].rank);
            assert(sorted_hand[0u8].rank == sorted_hand[2u8].rank);

            // Verified that the last 2 cards are the same rank
            assert(sorted_hand[3u8].rank == sorted_hand[4u8].rank);
        } else if combo_indicator == 5u8 {
            // Flush
            let suit: u8 = sorted_hand[0u8].suit;
            assert(sorted_hand[1u8].suit == suit);
            assert(sorted_hand[2u8].suit == suit);
            assert(sorted_hand[3u8].suit == suit);
            assert(sorted_hand[4u8].suit == suit);
        } else if combo_indicator == 4u8 {
            // Straight
            let initial_value: u8 = sorted_hand[0u8].rank;
            assert(sorted_hand[1u8].rank == initial_value - 1u8);
            assert(sorted_hand[2u8].rank == initial_value - 2u8);
            assert(sorted_hand[3u8].rank == initial_value - 3u8);
            assert(sorted_hand[4u8].rank == initial_value - 4u8);
        } else if combo_indicator == 3u8 {
            // Three of a Kind
            let rank_of_three: u8 = sorted_hand[0u8].rank;
            assert(sorted_hand[1u8].rank == rank_of_three);
            assert(sorted_hand[2u8].rank == rank_of_three);
        } else if combo_indicator == 2u8 {
            // Two Pair
            let first_pair: u8 = sorted_hand[0u8].rank;
            let second_pair: u8 = sorted_hand[2u8].rank;
            assert(sorted_hand[1u8].rank == first_pair);
            assert(sorted_hand[3u8].rank == second_pair);
        } else if combo_indicator == 1u8 {
            // One Pair
            let pair_rank: u8 = sorted_hand[0u8].rank;
            assert(sorted_hand[1u8].rank == pair_rank);
        }

        let c1: u8 = sorted_hand[0u8].rank;
        let c2: u8 = sorted_hand[1u8].rank;
        let c3: u8 = sorted_hand[2u8].rank;
        let c4: u8 = sorted_hand[3u8].rank;
        let c5: u8 = sorted_hand[4u8].rank;

        let final_score: u32 = ((combo_indicator as u32) << 20u32)
            + ((c1 as u32) << 16u32)
            + ((c2 as u32) << 12u32)
            + ((c3 as u32) << 8u32)
            + ((c4 as u32) << 4u32)
            + ((c5 as u32) << 0u32);

        return FinalHand {
            owner: self.caller,
            seat_index: player_final_hand_request.seat_index,
            did_fold: false,
            final_score: final_score,
            player_hand: player_hand
        };
    }

    // 5. Determine winner after getting all the final hands to all the players
    transition gsm_determine_winner(
        final_hand1: FinalHand, 
        final_hand2: FinalHand, 
        final_hand3: FinalHand, 
        final_hand4: FinalHand,
        ) -> [u8; 4] {
        let score1: u32 = final_hand1.final_score;
        let score2: u32 = final_hand2.final_score;
        let score3: u32 = final_hand3.final_score;
        let score4: u32 = final_hand4.final_score;

        assert(score1 >= score2);
        assert(score2 >= score3);
        assert(score3 >= score4);

        // Check that the seat_index is valid and are all unique
        assert(final_hand1.seat_index < 4u8);
        assert(final_hand2.seat_index < 4u8);
        assert(final_hand3.seat_index < 4u8);
        assert(final_hand4.seat_index < 4u8);
        let seat_mask: u8 = 0u8;
        let seat_indices: [u8; 4] = [
            final_hand1.seat_index,
            final_hand2.seat_index,
            final_hand3.seat_index,
            final_hand4.seat_index
        ];
        for i: u8 in 0u8..4u8 {
            let seat_bit: u8 = 1u8 << seat_indices[i];
            assert((seat_mask & seat_bit) == 0u8);
            seat_mask |= seat_bit;
        }

        // Now we need to check that the seat_mask is 0b1111
        assert(seat_mask == 15u8);

        return [
            final_hand1.seat_index,
            final_hand2.final_score == score1 ? final_hand2.seat_index : 4u8,
            final_hand3.final_score == score1 ? final_hand3.seat_index : 4u8,
            final_hand4.final_score == score1 ? final_hand4.seat_index : 4u8
        ];
    }

}