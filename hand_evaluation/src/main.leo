// The 'hand_evaluation' program.

import game_state_manager.aleo;

program hand_evaluation.aleo {

    struct Card {
        rank: u8,
        suit: u8,
        index: u8
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

    record PlayerFinalHandRequest {
        owner: address,
        room_id: u32,
        seat_index: u8,
        did_fold: bool
    }

    // We need an individual player to show their winning hand 
    // This transition will have a player choose their winning hand and they will demonstrate who will will win
    // Sine the hand is sorted, we can easily verify the hand corresponds to a certain combo
    transition player_show_winning_hand(
        player_final_hand_request: PlayerFinalHandRequest,
        player_hand: [Card; 2], // TODO: This needs to be a record
        community_hand: [Card; 5], // TODO: This needs to be a record. use CommunityCards
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

    // Determine winner after getting all the final hands to all the players
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
