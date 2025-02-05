# ZK Poker

## Introduction

ZK Poker is a decentralized poker game built on the Aleo blockchain using the Leo language. By leveraging Aleo's record-based model and the Leo language to construct zero-knowledge proofs, we can enable players to interact in a trustless manner without publishing sensitive information on-chain. In this architecture, different "agents" or "actors" continually listen for new records (events) and react by executing off-chain logic that is provably correct. The result is a dynamic gameplay experience—akin to a traditional poker table—where the underlying state transitions are verifiable and private.

This approach offers several key advantages:

1. Off-chain actions at low cost – By moving betting, shuffling, and hand evaluations off the main chain, we significantly reduce computational overhead. The network only needs to store action records on the Aleo ledger, each backed by a zero-knowledge proof verifying its correctness. This approach maintains security while keeping costs low.
2. Trustless game integrity – Every shuffle, deal, bet, and fold is essentially verified with a zero-knowledge proof, eliminating the possibility of rigged or dishonest behavior.  
3. Privacy of hidden states – While each player retains private information (namely, their hole cards), Aleo's zero-knowledge proof system guarantees that actions taken on those cards are legal without revealing them.
4. Reactive event-driven gameplay – The Aleo network effectively acts as a global mailbox of records. Game actors can "subscribe" to relevant events (e.g., new DeckShuffled record) and automatically process them to advance the game cycle, ensuring a natural, dynamic flow that feels like a live poker table.

By combining Aleo's zero-knowledge capabilities with an actor-based event-driven design, ZK Poker showcases how a serious, real-world game of incomplete information can be faithfully replicated on a decentralized ledger—without compromising security or privacy.

The game supports four players competing against each other. Leveraging the Aleo network's privacy-preserving features, ZK Poker ensures that players can participate without revealing their cards to opponents during gameplay. The game utilizes a HouseDealer component that facilitates play through verifiable random shuffling and encrypted card dealing. Importantly, all dealer operations uses Leo to generate zero-knowledge proofs offchain that can be verified by players to ensure complete fairness and prevent any manipulation. The dealer's actions are fully deterministic and transparent, with proofs generated off-chain using Aleo's powerful proving system to maintain both efficiency and trustlessness. This architecture enables true decentralized poker while maintaining the security and privacy guarantees players expect.

## Importance and Impact

A decentralized poker game built with zero-knowledge proofs on the Aleo network can illustrate the incredible potential of privacy-preserving technology for real-world applications. By leveraging Leo's ability to handle asymmetric information—such as hidden playing cards—this project removes the barriers that traditional blockchains face when implementing games that rely on secret states. The result is a fair, verifiable, and trustless experience without sacrificing each player's privacy.

Importantly, many crypto enthusiasts are drawn to high-risk opportunities, and a privacy-centric poker platform speaks directly to that audience. This impetus not only has the potential to onboard a significant number of new users to the Aleo ecosystem but also positions Aleo as a hub where innovation around privacy and usability converges. In fact, surfacing a truly private, user-friendly card game would highlight the Aleo network's unique capacity to handle both cryptographic proofs and engaging gameplay—which is an area of significant unmet demand in decentralized finance and gaming circles.

Moreover, by showcasing secure shuffling, and verifiable hands, the project paves the way for broader applications that require robust privacy. Developers looking to build complex zero-knowledge dApps would gain a real-life model for employing cryptographic primitives in a seamless, interactive environment, and users would witness firsthand how privacy can enhance trust, transparency, and security. This zkPoker initiative thus aligns perfectly with Aleo's mission to power next-generation ZK solutions, bridging the gap between technical feasibility and engaging user experiences in a manner that promotes meaningful growth for the network

## Texas Holdem Overview

Texas Holdem is the most popular variant of poker, distinguished by each player starting with two private hole cards. The game proceeds through four betting rounds:

1. Pre-flop: After receiving their two private hole cards, players make initial bets based solely on these hidden cards.

2. Flop: Three community cards are revealed face-up on the table. Players bet based on how these cards combine with their hole cards.

3. Turn: A fourth community card is revealed, followed by another round of betting as players reassess their hand strength.

4. River: The fifth and final community card is revealed, leading to the last betting round.

During each betting round, players can check (bet nothing), bet, call (match others' bets), raise (increase the bet), or fold (give up their hand). Each player's bet and stack are publically visible for all players. For simplicity, we do not implement any side-pot logic. If a player goes all in and wins, they claim the entire pot. Players must form the best possible five-card hand by combining their private hole cards with any of the five community cards. The game ends with a showdown when multiple players remain, where hands are revealed and the strongest hand wins the pot.

## Securing Poker with Zero-Knowledge Proofs and Leo

Zero-knowledge proofs form the core of zkPoker by ensuring that hidden data (such as hole cards) remains confidential while still allowing every action to be undeniably verified. Ordinarily, poker relies on secret information that only each cardholder knows, yet typical blockchains make all data public by default. In zkPoker, we solve this by having the dealer generate the (1..52) card records through Leo’s transition functions and assigning them to each specific player to be owners of the cards. Only the player who owns these card records can view and decrypt them, guaranteeing privacy while also proving validity. Therefore, asymmetric information is achieved for a player's hand.

To achieve a fair shuffle that no single party can control, both the dealer and all players independently produce a shuffle permutation (a 52-element array describing how to reorder the deck). By having the players submit these permutations, the permutations are then encrypted and the contents are verified to be a 1..52 permutation using Leo’s zero-knowledge circuitry. Consequently, we ensure that the final deck order emerges from multiple honest contributions. Any attempt to discard or alter a shuffle would invalidate the corresponding proof. With this player participation approach of shuffling, no individual participant can predict or manipulate the card distribution.

At the showdown, zkPoker again leverages Leo’s transition functions. Each player, owning their hole cards and copies of the community cards, creates a zero-knowledge proof that they are selecting the strongest possible 5-card combination. Because the ownership of cards and the scoring logic are enforced via zero-knowledge, no one can dispute the authenticity of each hand. To finalize a round, only the resultant scores are revealed, making it clear who wins without exposing private card details. This combination of confidentiality and verifiability is what makes zkPoker’s actions irrefutable to all observers.


## How does it fit into the ecosystem?

Aleo/Leo's ability to handle hidden game states through zero-knowledge proofs makes it a perfect match for an application that relies on asymmetric information. Poker, specifically the Texas Holdem format with its private hole cards and public community cards, is a prime example of a use case that showcases this capability in a clear and illustrative manner. By building a fully functional poker application using Leo, we not only highlight Aleo's unique strength in preserving privacy without compromising transparency but also encourage developers to adopt this new paradigm for other real-world use cases that require similar hidden states or data protection guarantees. In this way, the project aims to position Aleo as the go-to platform for complex zero-knowledge gaming logic, inspiring additional innovation and contributions within the ecosystem.

## Vision of End Result

Ultimately, the goal is to deliver a Leo smart contract for a fully operational zkPoker (Texas Holdem) experience. This will include a comprehensive test suite that rigorously validates the dealing, betting, hand evaluation, and randomization mechanisms required to ensure fairness and transparency. By demonstrating a trusted means of preserving secret information, the project will serve as an essential proof of concept for both current and future builders on Aleo. While this grant focuses on finalizing the poker smart contracts and supporting tests, the long-term ambition is to create a polished frontend which can be pushed to a future grant. This user interface would make the betting, dealing, and reveal flows accessible to anyone, effectively broadening the appeal of the Aleo network and showcasing its advanced capabilities in delivering privacy-preserving, interactive dApps.

## Team Quality

I am a strong candidate to lead this grant, bringing a rich background in zero-knowledge protocols, blockchain engineering, and production-level application development. My experience spans from building the core consensus and networking at Mina Protocol. During my free time, I like to explore advanced cryptography topics and implement variaous cryprtographic protocols such as FRI, Bulletproofs, and a PLONK compiler that converts the simply typed lambda calculus into Plonk circuits (which is similar to how the Leo language works), demonstrating a deep understanding of cryptographic building blocks. This experience has given me the fluency to navigate the quirks of Leo, ensuring that our zkPoker design matches the unique constraints and capabilities of Aleo's zero-knowledge model.

Beyond cryptography and blockchain work, I have proven skills in deploying real-world smart contracts, such as building the decentralized webtoon platform "Sekai," and building "TrueCanvas" which uses the Risc-Zero ZK-VM to help artists attest that the constructed their artwork without using AI. My engineering track record also includes building a bot-evasion platform at Anon, achieving a 95% success rate on major social networks by emulating human browser fingerprints and carefully orchestrating OAuth-style integrations for seamless user handoffs. Prior roles at Apple and Same Day Health honed my attention to front-end quality and user flows, reinforcing an end-to-end mindset that balances cryptographic rigor with usability.

With this combination of advanced crypto knowledge, large-scale product engineering, and hands-on zero-knowledge proof implementation, I am well-positioned to ensure zkPoker delivers on its promise of trustless gameplay and a frictionless user experience. By driving the technical vision and tackling the details—from circuit optimizations to event-driven architecture—this project will serve as a shining example of how Aleo's Leo language enables rich applications without compromising privacy or security.

## Technical Approach 

### Functional Requirements

The main requirement for the game is that it must be a fair and transparent game of poker. The rules can be broken down as the following:

- Support four players playing at the same time
- The game must simulate all poker rounds (pre-flop, flop, turn, river, and showdown)
- Each player has a private hand
- Each player can place bets
- Each player can fold their hand
- Each player can call other players' bets
- Each player can raise the stakes
- Each player can see the community cards as they are revealed in each round
- Each player can see the pot
- Each player must reveal their hole cards at showdown
- During showdown, each player must select their best 5-card hand from their 2 hole cards and 5 community cards
- Each player must calculate their 5-card hand score under a zero-knowledge proof
- Each player can see the other players' final 5-card hands and scores at showdown
- Each player can see the other players' bets
- The dealer must be able to hide the cards for players and shuffle the deck in a fair manner
- The dealer must be able to reveal community cards at appropriate rounds (3 cards at flop, 1 at turn, 1 at river)
- The dealer must be able to deal cards to players in a fair manner and those dealed hole cards must be hidden from other players
- The game state manager must be able to determine and reveal who won the game based on the proven 5-card hand scores

We will now break down and discuss the technical approach for implementing various components of the game.

### Design Patterns - Actor Model / Event-Driven Architecture

In this application, the core pattern for structuring our code and logic is the Actor Model paired with event-driven messaging. Each "Actor" is a distinct, autonomous entity that holds its own state, processes incoming messages, and sends messages to other actors. This model aligns well with how Aleo's record-based (UTXO-like) system handles private state updates, and it helps us keep logic modular and testable.

To elabroate more, under the hood, when a Leo program on Aleo constructs records, these records are associated with a single owner. Each record is posted to the blockchain (acting like a global mailbox), allowing various actors to consume or create new records. In practice, this looks very similar to how actors for concurrency programming (like in Erlang or Elixir) pass around "Message" objects: they produce new events (records) for other actors (owners) to consume, ensuring an immutable yet decentralized flow.

Using an actor-based/event-driven approach offers several advantages:

- Separation of concerns: Each actor focuses on a single role (e.g., dealing cards or managing rooms).  
- Loose coupling: Actors communicate exclusively through messages, reducing the need for shared state.  
- Scalability: You can run multiple instances of an actor type if the system needs to scale, since each actor reacts to its own queue of messages.  
- Alignment with Aleo's record model: In Aleo, state updates happen by creating or consuming records, which seamlessly fits the actor model's notion of passing messages around.  

Some actors in this system—like the Dealer, GameStateManager, and RoomManager-will typically operate in an automated manner from a centralized server or process. Even so, these centralized entities execute Leo transition functions and publish the output records to the Aleo blockchain to verify that each action (shuffle, bet settlement, seat assignment, etc.) followed the rules. This ensures all participants can trust the game's integrity, despite the off-chain automation.

Crucially, these actors "listen" for on-chain events. Whenever a record is published that matches certain criteria—such as a new action request for a player—the relevant actor triggers the correct function in its logic. For instance, if the GameStateManager issues a "request_action" record, a player picks it up, a record that represents the response of the request, which is fold/call/raise/all-in, and publishes that as a new "player_action" record. The GameStateManager then applies the proven action. This combination of off-chain automation and on-chain proof publication provides both convenience and trustlessness, avoiding unnecessary sequential processing of invalid moves.

Below is a high-level overview of the primary actors in this architecture:

1. Player  
   - Represents a single participant in a poker table.  
   - Receives private hole cards (hidden even from the Game) and decides on actions such as fold, call, or raise.  
   - Provides a permutation to shuffle the deck
   - At the showdown stage of the game, the player will select their best 5-card hand from their 2 hole cards and 5 community cards. They would then compute the score of their hand

2. HouseDealer  
   - Ensures fair and trustless card shuffling by combining permutations from all players, preventing any single player (including the dealer) from manipulating the deck.  
   - Maintains and applies the shuffled deck state, with each shuffle operation provable via zero-knowledge proofs for complete auditability.  
   - Deals hole cards to each Player actor and community cards to the Game, with each deal operation generating proofs that cards were dealt according to the shuffled order.  
   - Operates off-chain but reacts to on-chain events (e.g., "need to start new hand") and publishes zero-knowledge proofs for each shuffle or dealing action.

3. GameStateManager
   - Orchestrates the flow of a poker hand (pre-flop, flop, turn, river, showdown). 
   - Publish requests for players to act (fold, call, raise, all-in)
   - Listens for new-onchain records (e.g. action responses) and processes player actions (fold, call, raise, all-in) in FIFO order as they are received and immediately applies valid actions to update the game state with new pot amounts, seat turns, and game phases.  
   - Determines a winner of the game based on reading the final hands of all players

4. RoomManager  
   - Manages a public mapping of all poker rooms created in the game, allowing players to browse and join available tables.  
   - Oversees room creation and user seating.  
   - Validates whether a seat is available and if a user's stack meets the minimum buy-in.  
   - Triggers the creation of a new game state once all required users have joined.  
   - Informs the Dealer when a new room is ready, so the Dealer can initialize a shuffle state and be prepared to deal.  
   - Also runs off-chain, publishing on-chain updates (like "room_created") and reacting to relevant changes in the blockchain.

By separating these responsibilities into dedicated actors (Player, Dealer, GameStateManager, RoomManager), we ensure our application is both easy to reason about and easy to extend. Whenever one component needs to change (e.g., a new shuffle protocol), the rest of the system remains stable as long as we preserve the incoming/outgoing message contracts. This design pattern is especially beneficial when integrating with Aleo's record-based ledger, since the event-driven approach of the Actor Model parallels quite naturally with zero-knowledge-capable blockchain transactions that consume and produce records.

We will now discuss the various game state primitives that we will need to implement.

### Game State

```leo
// A Card is encoded as a u32 bitset with:
//   - bits [0..12]: exactly one bit set for rank (2=0, 3=1, ..., A=12)
//   - bits [13..16]: exactly one bit set for suit (clover=0, diamond=1, heart=2, spade=3)
// Examples:
//   2 Clover = 0b_0000_0001
//   Ace Spade = 0b_1000_0000_0000_1000_0000_0000
type Card = u32;
type Deck = [Card; 52];

// A new struct to hold the dealer's public deck state.
record HouseDealerState {
    deck: Deck,            // The shuffled deck of 52 cards (public here)
    next_card_index: u8    // The pointer to the next card to deal (public)
}


// Dealt one community card for the turn or river. The GameStateManager will publish this record to the onchain mailbox
record DealtOneCommunityCard {
    card: Card,
    is_turn: bool,
    room_id: u32
}

// Dealt three community cards for flop phase. The GameStateManager will publish this record to the onchain mailbox
record DealtThreeCommunityCards {
    cards: [Card; 3],
    room_id: u32,
    is_next_phase_turn: bool
}

// A simple struct for a player's public data 
// (fields visible to everyone in the network).
record Player {
    name: str,       // The player's name (public)
    stack: u64,      // The player's chip stack (public)
    folded: bool,    // Whether the player has folded
    all_in: bool     // Whether the player is all-in
}

record PlayerProposedShuffle {
    room_id: u32,
    seat_index: u8,
    seat_owner: address,
    perm: [u8; 52]
}

record HouseDealerCreateDeckRequest {
    room_id: u32
}

// These actions fulfill requests that the game state manager requires to move the game forward.
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
    final_player_scores: private [u64; 4], // Example: hidden inside a struct is not possible, so consider storing in a record if fully private
    house_dealer_state: HouseDealerState   // Public struct containing deck + pointer
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

// RoomConfig holds the entire poker game configuration:
// This is public so anyone can join the game based on the configuration
// Empty seats have address 0x000...000
record RoomConfig {
    big_blind: u64,
    small_blind: u64,
    min_stack: u64,
    seats: u8,
    joined_users: [address; 4] // Address is 0x000...000 for empty seats
}


```

As illustrated above, public state (like players' stacks, bets, and seat assignments) is visible to all, ensuring transparency regarding who has folded, who is all-in, and how much has been bet. Meanwhile, sensitive information, such as each player's hole cards, is kept private by storing it in a record accessible only to that player's address. This approach provides both the transparency needed for trustless gameplay and the privacy required for concealed hands.

### Game Logic/ Leo Transitions
Below is an example of how each actor's functionality might look in Leo. Namely, we discuss the function signature of each of these transitions and functions and discuss the logic of each of them. It should be noted that all of these computations are done off-chain.

```leo
// -----------------------------------
// HouseDealer Functions and Transitions
// -----------------------------------
// The house dealer receives a request from the room manager to create a new deck and shuffles it with their own permutation.
// Because performing a full shuffle in a SNARK is extremely expensive,
// the dealer generates a random permutation off-chain as (purposely unverifiable) input and provides it as [u8; 52].
// The permutation acts as a mapping where perm[i] = j means card at position i moves to position j.
// We verify it is a valid permutation (contains all numbers 0-51 exactly once), 
// then update HouseDealerState with the shuffled deck.
transition house_dealer_shuffle_random(
    house_dealer_request: HouseDealerCreateDeckRequest, 
    perm: [u8; 52]
) -> HouseDealerState {
    // 1) Validate perm is a valid permutation of [0..51].
    // 2) Reorder the deck in HouseDealerState.
    // 3) Reset next_card_index to 0.
    // HouseDealerCreateDeckRequest can also contain e.g. the 'deck' or 'room_id' if needed.
    ...
}

// We can apply ALL players' permutations in one go. The RoomManager collects them
// (or the Dealer accumulates them) and composes a single final permutation.
// Then we reorder the deck in HouseDealerState.
function house_dealer_apply_player_shuffle(
    hs: HouseDealerState, 
    shf1: PlayerProposedShuffle,
    shf2: PlayerProposedShuffle,
    shf3: PlayerProposedShuffle,
    shf4: PlayerProposedShuffle
) -> HouseDealerState {
    // First validate all inputs are for the same room and game

    // Verify each shuffle corresponds to the correct seat

    // 1) Compose or combine these four permutations off-chain (if desired),
    //    or apply them in sequence. This ensures no single entity can fully
    //    control the final deck order.
    // 2) Reorder hs.deck using the final merged permutation.
    // 3) Return the updated HouseDealerState.
    ...
}

// Deals two hole cards to each player (4 players total) from the current deck.
// Takes the current HouseDealerState and ShuffleState, and returns the updated state
// along with PlayerHand structs for each player containing their two hole cards.
// The cards are dealt in sequence: two cards to seat 0, then seat 1, etc.
// Advances the deck pointer by 8 cards total (2 cards * 4 players).
function house_dealer_deal_player_cards(
    hs: HouseDealerState, 
    shf: ShuffleState
) -> (HouseDealerState, PlayerHand, PlayerHand, PlayerHand, PlayerHand) {
    ...
}


// Deal three community cards (for the flop)
// This function deals the flop (3 community cards) and returns them along with updated dealer state
// The dealt cards record will be passed to the game state manager transition to update the game state
// with the new community cards and advance to the next betting round
transition house_dealer_deal_three_cards(hs: HouseDealerState, is_next_phase_turn: bool) -> (HouseDealerState, DealtThreeCommunityCards) {
    ...
}

// Deal one community card (for turn or river)
// This function deals either the turn or river card and returns it along with updated dealer state
// The dealt card record will be passed to the game state manager transition to update the game state
// with the new community card and advance to the next betting round
// Like in real poker, we "burn" one card before dealing to prevent any possible card marking or tracking
transition house_dealer_deal_one_card(hs: HouseDealerState) -> (HouseDealerState, DealtOneCommunityCard) {
    ...
}

// Creates the initial game state from the room config
function house_dealer_create_game_state(state: RoomConfig) -> GameState {
    ...
}


// This transition represents the start of a new poker hand, where the dealer:
// 1. Applies all players' shuffles to create a fair random deck that no single player can manipulate
// 2. Creates the initial game state with blinds and turn order
// 3. Deals private hole cards to each player
//
// The dealer then distributes the records to their respective owners:
// - GameState record -> GameStateManager to process betting actions and advance phases
// - HouseDealerState record -> Kept by dealer to track deck state for future deals
// - PlayerHand records -> Each player gets their own private hole cards record
//   - Player 0 gets p0_hand containing their hole cards
//   - Player 1 gets p1_hand containing their hole cards
//   - Player 2 gets p2_hand containing their hole cards 
//   - Player 3 gets p3_hand containing their hole cards
//
// This separation of records ensures:
// 1. Only the GameStateManager can process game actions
// 2. Only the dealer knows the full deck state
// 3. Players can only see their own hole cards
// Additionally, we create a PlayerActionRequest so that the dealer seat player (i.e. the first player to act for the first round) can initiate action.
transition house_dealer_starts_game(
    hs: HouseDealerState,
    room_config: RoomConfig,
    shf1: PlayerProposedShuffle,
    shf2: PlayerProposedShuffle,
    shf3: PlayerProposedShuffle,
    shf4: PlayerProposedShuffle,
) -> (
    GameState, 
    HouseDealerState, 
    PlayerHand, 
    PlayerHand, 
    PlayerHand, 
    PlayerHand,
    PlayerActionRequest
) {
    ...
}


// -----------------------------------
// Player Transitions
// -----------------------------------

// 1. Contribute a shuffle permutation
// Each player must contribute their own random permutation to ensure fairness
// By combining multiple independent shuffles, we prevent any single player or
// the dealer from knowing the final card positions. This is critical because:
// - The dealer cannot deal favorable cards to specific players
// - Players cannot collude with the dealer to cheat
// - The final deck order is determined by ALL participants' shuffles combined
// - No party can predict or manipulate the outcome of the dealing
transition player_propose_shuffle(perm: [u8; 52], room_id: u32, seat_index: u8) -> PlayerProposedShuffle {
    ...
}

/// This unified transition allows a player to either fold, call, raise, or go all-in
/// using a single proof-based flow. The player must prove they have sufficient funds
/// for the requested bet action (e.g., raise or all-in). The "action_type" corresponds
/// to: 0 = Fold, 1 = Call, 2 = Raise, 3 = All-In.
transition player_submit_action(
    request: PlayerActionRequest,
    seat: u8,
    action_type: u8,
    amount: u64,
) -> PlayerAction {
    ...
}

// 6. Submit final hand with a score
transition player_submit_final_hand(player_hand: PlayerHand, community_hand: [Card; 5]) -> FinalHand {
}


// -----------------------------------
// GameStateManager Transitions
// -----------------------------------



// Apply players actions to the game state
/// Players would submit their actions to the game state manager and the game state manager would apply the actions to move the game forward.
transition gsm_apply_player_action_to_move_to_next_player(gs: GameState, action: PlayerActionResponse) -> (GameState, PlayerActionRequest) {
    let mut new_gs = gs;
    
    // Apply the player's proven action (call, fold, raise, etc.)
    // existing code...

    // Increment the nonce to move to next action or next player's turn
    new_gs.nonce = new_gs.nonce + 1u64;

    // Create a new PlayerActionRequest for the next player in turn order
    let next_request = PlayerActionRequest {
        owner: <next_player_address>,
        seat_index: <next_seat_index>,
        room_id: new_gs.room_id,
        nonce: new_gs.nonce,
        stack: <player_stack>,
        highest_bet: new_gs.highest_bet,
        main_pot: new_gs.main_pot
    };
    
    return (new_gs, next_request);
}

/// Acvancing to the the next phase
// 3a. Advance phase and update state with three community cards (for flop)
transition gsm_advance_phase_flop(gs: GameState, dealt_cards: DealtThreeCommunityCards, last_player_action: PlayerActionResponse) -> (GameState, PlayerActionRequest) {
    let mut new_gs = gs;

    // Once we switch to the flop phase, increment the nonce
    new_gs.nonce = new_gs.nonce + 1u64;

    // Possibly create a new request for the first player to act in the new phase
    let action_request = PlayerActionRequest {
        owner: <first_player_address>,
        seat_index: <first_seat_index>,
        room_id: new_gs.room_id,
        nonce: new_gs.nonce,
        stack: new_gs.players[first_seat_index as usize].stack,
        highest_bet: 0u64,
        main_pot: new_gs.main_pot
    };
    
    return (new_gs, action_request);
}

// 3b. Advance phase and update state with one community card (for turn/river)
transition gsm_advance_phase_turn_river(gs: GameState, dealt_card: DealtOneCommunityCard, last_player_action: PlayerActionResponse) -> (GameState, PlayerActionRequest) {
    // Update community card and phase for turn or river
    let mut new_gs = gs;
    if dealt_card.is_turn {
        new_gs.community_cards[3] = dealt_card.card;
        new_gs.current_phase = 2u8; // Advance to turn phase
    } else {
        new_gs.community_cards[4] = dealt_card.card;
        new_gs.current_phase = 3u8; // Advance to river phase
    }
    return new_gs
}


// 4. Advance to the showdown phase and provide community cards to all players to make their final hand for scoring
transition gsm_advance_to_showdown(gs: GameState) -> ([Card; 5], [Card; 5], [Card; 5], [Card; 5]) {

}


// 5. Determine winner after getting all the final hands to all the players
transition gsm_determine_winner(final_hand1: FinalHand, final_hand2: FinalHand, final_hand3: FinalHand, final_hand4: FinalHand) -> u8 {
    // Evaluate final_submissions off-chain or in a circuit, then update
    // gs.final_player_scores or declare winners. 
    return gs
}


// -----------------------------------
// RoomManager Transitions
// -----------------------------------

// 1. Create a room
transition rm_create_room(big_blind: u64, small_blind: u64, min_stack: u64, big_blind_seat: u8, small_blind_seat: u8) -> RoomConfig {
    // Publish a new record for the room so that players can join.
    return config
}

// 2. Join a room
// Players read the public mapping of available rooms and join an open seat
// This updates the public mapping of room configurations
transition rm_join_room(room_id: u32) {
    // Read room config from public mapping using room_id
    // If seat is free, store player_addr in config.joined_users[seat]
    // Update public mapping with new room config
}

// 3. Request game creation
// This transition is called when a room is full and ready to start a game
// It transfers ownership of the RoomConfig to the dealer and creates a deck request
// The dealer will use this to initialize and shuffle a new deck
transition rm_request_game_creation(room_id: u32) -> (RoomConfig, HouseDealerCreateDeckRequest) {
    ...
}
```

### Common Workflows/Examples

In this section, we will see how to combine all of these components to construct the common workflows of a poker game. We'll explore how the different actors (RoomManager, GameStateManager, and HouseDealer) coordinate through transitions and records to enable key poker operations like joining games, dealing cards, and determining winners—all while maintaining privacy through Leo's zero-knowledge proof system. We talk about the common workflows in the context of an example game with four players: Alice, Bob, Carol, and David.

#### Initialize a new game and having people join
Suppose we have four players: Alice, Bob, Carol, and David. First, Alice decides to start a new room by calling the RoomManager's "rm_create_room" transition with the following inputs:

• big_blind = 20  
• small_blind = 10  
• min_stack = 500  
• big_blind_seat = 1  
• small_blind_seat = 0  

So the transition call looks like:

```
transition rm_create_room(
    big_blind: u64,
    small_blind: u64, 
    min_stack: u64,
    big_blind_seat: u8,
    small_blind_seat: u8
) -> RoomConfig
```

This publishes a new RoomConfig record on-chain, storing these mandatory bets and specifying that seat 1 posts the big blind while seat 0 posts the small blind. Next, Bob, Carol, and David each call:

```
transition rm_join_room(room_id: u32)
```

They all meet the minimum stack requirement of 500 chips and thus fill the remaining seats in the room. This update is reflected in the public mapping of room IDs to RoomConfig records, letting everyone confirm the room is full. As soon as all four seats are taken, the RoomManager sees a fully occupied table.

Now, the RoomManager initiates the game creation:

```
transition rm_request_game_creation(room_id: u32) -> (RoomConfig, HouseDealerCreateDeckRequest)
```

This transfers ownership of the RoomConfig to the house dealer and creates a deck request. The HouseDealer notes this on-chain event and stands by to shuffle the deck. Each player then proposes a random permutation to ensure a fair shuffle:

```
transition player_propose_shuffle(perm: [u8; 52], room_id: u32, seat_index: u8) -> PlayerProposedShuffle
```

This publishes a PlayerProposedShuffle record on-chain with each player's secret permutation. Because multiple random permutations are combined, no single participant can predetermine the final deck order.

Finally, the HouseDealer starts the game with:

```
transition house_dealer_starts_game(
    hs: HouseDealerState,
    room_config: RoomConfig,
    shf1: PlayerProposedShuffle,
    shf2: PlayerProposedShuffle, 
    shf3: PlayerProposedShuffle,
    shf4: PlayerProposedShuffle
) -> (GameState, HouseDealerState, PlayerHand, PlayerHand, PlayerHand, PlayerHand, PlayerActionRequest)
```

Within this transition:
1. All the shuffles from Alice, Bob, Carol, and David are applied to fairly randomize the deck.  
2. An initial game state is created, establishing Bob as the big blind (seat 1) and Alice as the small blind (seat 0), with Carol (seat 2) set to act first after the blinds.  
3. Each player is privately dealt two hole cards. For example:  
   - Alice (Seat 0): Hole Cards: [2 Clover, 7 Spade]
   - Bob (Seat 1): Hole Cards: [King Heart, King Diamond]
   - Carol (Seat 2): Hole Cards: [4 Clover, Queen Spade]
   - David (Seat 3): Hole Cards: [Ace Diamond, 9 Clover]
4. Records are returned for the updated GameState, including the HouseDealer's public deck state and each player's private hand.
5. Additionally, we create a PlayerActionRequest for Carol to initiate the game.

At this point, the game is live, and everyone is ready to begin the Pre-Flop round.


#### Running a round of poker

Below is a sample run-through of a complete hand of poker involving Alice, Bob, Carol, and David, using the transition functions described in this proposal. We'll assume the following setup:

- Seat 0: Alice (small blind)  
- Seat 1: Bob (big blind)  
- Seat 2: Carol  
- Seat 3: David  

The small blind is 10 chips, and the big blind is 20 chips. Each player starts with 500 chips.



#### 1. PRE-FLOP
---


1) At this point, the house dealer has created the initial GameState with blinds and turn order, dealt private PlayerHand records to each player containing their hole cards, and returned an updated HouseDealerState with next_card_index advanced by 8 (2 cards × 4 players).
   - Each player has 2 hidden cards in a private PlayerHand record:
     - Alice has 2 Clover, 7 Spade
     - Bob has King Heart, King Diamond
     - Carol has 4 Clover, Queen Spade
     - David has Ace Diamond, 9 Clover
   - The pot is 30 (10 from Alice's small blind, 20 from Bob's big blind)  
   - Alice and Bob's stacks are 490 and 480 respectively
   - The highest_bet is 20 (Bob's big blind)
   - Carol will have a PlayerActionRequest to start the game

2) Carol decides to call the big blind (20 chips):
   - Carol receives a PlayerActionRequest from the HouseDealer after they set up the game.
   - Carol calls player_submit_action(seat=2, action_type=1, amount=20).
   - The GameStateManager receives the PlayerActionResponse from Carol and processes it by calling gsm_apply_player_action_to_move_to_next_player(...) to move the game forward.
   - Carol's stack goes from 500 → 480.
   - Carol's contributed goes from 0 → 20.
   - The pot is now 50 (30 + 20).
   - The highest_bet remains 20.


3) David also calls the big blind (20 chips):
   - David receives a PlayerActionRequest from the GameStateManager.
   - David calls player_submit_action(seat=3, action_type=1, amount=20).
   - The GameStateManager receives the PlayerActionResponse from David and processes it by calling gsm_apply_player_action_to_move_to_next_player(...) to move the game forward.
   - David's stack goes from 500 → 480.
   - David's contributed goes from 0 → 20.
   - The pot is now 70 (50 + 20).
   - The highest_bet remains 20.


4) Alice posted 10 earlier but needs to match Bob's 20 to stay in. Alice calls an additional 10:
   - Alice receives a PlayerActionRequest from the GameStateManager.
   - Alice calls player_submit_action(seat=0, action_type=1, amount=10).
   - The GameStateManager receives the PlayerActionResponse from Alice and processes it by calling gsm_apply_player_action_to_move_to_next_player(...) to move the game forward.
   - Alice's stack goes from 490 → 480.
   - Alice's contributed is now 20 total.
   - The pot is now 80 (70 + 10).
   - The highest_bet remains 20.

5) Since Bob already posted the big blind (20), he checks:
   - Bob receives a PlayerActionRequest from the GameStateManager.
   - Bob responds by calling player_submit_action(seat=1, action_type=1, amount=0).
   - The GameStateManager notices that all players have called and moves the game forward by calling gsm_advance_phase_pre_flop(..) to advance the phase.
   - Bob's stack remains 480 (no extra chips needed).
   - Bob's contributed remains 20.
   - The pot remains 80.
   - The highest_bet remains 20.


End of Pre-Flop Table → (Seat = 0: Alice, 1: Bob, 2: Carol, 3: David)

| Player | Stack | Contributed | Folded? | All-In? | Hand      | Total Pot = 80 |
|--------|-------|------------|---------|---------|-----------|----------------|
| Alice  | 480   | 20         | false   | false   | 2 Clover, 7 Spade    | 80             |
| Bob    | 480   | 20         | false   | false   | King Heart, King Diamond    | 80             |
| Carol  | 480   | 20         | false   | false   | 4 Clover, Queen Spade    | 80             |
| David  | 480   | 20         | false   | false   | Ace Diamond, 9 Clover    | 80             |


#### 2. FLOP
---

1) The HouseDealer deals three community cards (7 Spade, J Clover, A Diamond):
   house_dealer_deal_community_cards() → DealtThreeCommunityCards

   The GameStateManager advances the phase:
   gsm_advance_phase_flop() → GameState
   Alice receives a PlayerActionRequest from the GameStateManager and needs to submit an action.

2) Alice bets 20:
   - Alice receives a PlayerActionRequest from the GameStateManager.
   - Alice responds by calling player_submit_action(seat=0, action_type=2, amount=20).
   - The GameStateManager receives the PlayerActionResponse from Alice and processes it by calling gsm_apply_player_action_to_move_to_next_player(...) to move the game forward.
   - Alice's stack goes from 480 → 460
   - Alice's contributed goes from 20 → 40
   - The pot is now 100 (80 + 20)
   - The highest_bet is set to 20 for this round

3) Bob calls the 20:
   - The GameStateManager then sends a PlayerActionRequest to Bob (seat=1).
   - Bob calls player_submit_action(seat=1, action_type=1, amount=20).
   - The GameStateManager processes it via gsm_apply_player_action_to_move_to_next_player(...).
   - Bob's stack goes from 480 → 460
   - Bob's contributed goes from 20 → 40
   - The pot is 120
   - The highest_bet remains 20

4) Carol folds:
   - Next, the GameStateManager sends a PlayerActionRequest to Carol (seat=2).
   - Carol decides to fold by calling player_submit_action(seat=2, action_type=3, amount=0).
   - The GameStateManager processes it via gsm_apply_player_action_to_move_to_next_player(...).
   - Carol's stack remains 480
   - Carol's contributed remains 20
   - The pot is still 120
   - Carol is out of this round

5) David calls the 20:
   - Finally, the GameStateManager sends a PlayerActionRequest to David (seat=3).
   - David responds by calling player_submit_action(seat=3, action_type=1, amount=20).
   - The GameStateManager processes the response and notices that have either called or folded. So, it calls gsm_advance_phase_turn_river(...) to advance the phase.
   - David's stack goes from 480 → 460
   - David's contributed goes from 20 → 40
   - The pot is now 140 (120 + 20)
   - The highest_bet remains 20

End of Flop Table → (Seat = 0: Alice, 1: Bob, 2: Carol, 3: David)

Community Cards: 7 Spade, J Clover, A Diamond

| Player | Stack | Contributed | Folded? | All-In? | Hand      | Total Pot = 140 |
|--------|-------|------------|---------|---------|-----------|-----------------|
| Alice  | 460   | 40         | false   | false   | 2 Clover, 7 Spade    | 140             |
| Bob    | 460   | 40         | false   | false   | King Heart, King Diamond    | 140             |
| Carol  | 480   | 20         | true    | false   | 4 Clover, Queen Spade    | 140             |
| David  | 460   | 40         | false   | false   | Ace Diamond, 9 Clover    | 140             |


#### 3. TURN
---

1) The HouseDealer deals the turn card (J Clover):
   - The dealer calls house_dealer_deal_one_card(hs), which returns (HouseDealerState, DealtOneCommunityCard).
   - The GameStateManager then calls gsm_advance_phase_turn_river(gs, dealt_card, last_player_action) → (updated_gs, next_request) to advance the phase and create a PlayerActionRequest for the next player to act (in this scenario, Alice).

2) Alice checks:
   - Alice receives a PlayerActionRequest from the GameStateManager (seat=0).
   - She responds by calling player_submit_action(seat=0, action_type=1, amount=0).
   - The GameStateManager processes her PlayerActionResponse by calling gsm_apply_player_action_to_move_to_next_player(updated_gs, response) → (updated_gs, next_request).
   - Outcome: No change to stack or pot; the highest_bet is set to 0 for this round.

3) Bob bets 40:
   - Bob receives the next PlayerActionRequest from the GameStateManager (seat=1).
   - He responds with player_submit_action(seat=1, action_type=2, amount=40).
   - The GameStateManager processes it via gsm_apply_player_action_to_move_to_next_player(...).
   - Bob's stack goes from 460 → 420; contributed goes from 40 → 80; the pot becomes 180 (140 + 40); highest_bet is now 40.

4) David calls the 40:
   - David receives a PlayerActionRequest from the GameStateManager (seat=3).
   - He calls player_submit_action(seat=3, action_type=1, amount=40).
   - The GameStateManager processes the response and notices that have either called or folded. So, it calls gsm_advance_phase_turn_river(...) to advance the phase.
   - David's stack goes from 460 → 420; contributed goes from 40 → 80; the pot is now 220 (180 + 40); highest_bet remains 40.

5) Alice raises 80 more:
   - Alice receives another PlayerActionRequest from the GameStateManager (seat=0).
   - She responds by calling player_submit_action(seat=0, action_type=2, amount=80).
   - The GameStateManager processes Alice's response via gsm_apply_player_action_to_move_to_next_player(...).
   - Alice's stack goes from 460 → 380; contributed goes from 40 → 120; the pot becomes 300 (220 + 80); highest_bet is now 80.

6) Bob calls the additional 40:
   - Bob receives the next PlayerActionRequest (seat=1).
   - He calls player_submit_action(seat=1, action_type=1, amount=40).
   - The GameStateManager updates the game via gsm_apply_player_action_to_move_to_next_player(...).
   - Bob's stack goes from 420 → 380; contributed goes from 80 → 120; the pot is 340 (300 + 40); highest_bet remains 80.

7) David calls the additional 40:
   - David receives a PlayerActionRequest (seat=3).
   - He calls player_submit_action(seat=3, action_type=1, amount=40).
   - The GameStateManager notices that all active players have called to match the highest_bet, 80. So, it calls gsm_advance_phase_turn_river(...) to advance the phase.
   - David's stack goes from 420 → 380; contributed goes from 80 → 120; the pot is 380; highest_bet remains 80.

End of Turn Table → (Seat = 0: Alice, 1: Bob, 2: Carol, 3: David)

Community Cards: 7 Heart, J Spade, A Clover, J Clover

| Player | Stack | Contributed | Folded? | All-In? | Hand      | Total Pot = 380 |
|--------|-------|------------|---------|---------|-----------|-----------------|
| Alice  | 380   | 120        | false   | false   | 2 Clover, 7 Spade    | 380             |
| Bob    | 380   | 120        | false   | false   | King Heart, King Diamond    | 380             |
| Carol  | 480   | 20         | true    | false   | 4 Clover, Queen Spade    | 380             |
| David  | 380   | 120        | false   | false   | Ace Diamond, 9 Clover    | 380             |


#### 4. RIVER
---

1) The HouseDealer deals the final community card:  
   - The dealer calls `house_dealer_deal_one_card(hs)`, which returns `(HouseDealerState, DealtOneCommunityCard)` for the 5 Heart.  
   - The `GameStateManager` then calls `gsm_advance_phase_turn_river(gs, dealt_card, last_player_action) -> (updated_gs, next_request)` to advance to the river phase and issue a `PlayerActionRequest`.

2) Alice bets 100:  
   - Alice receives the `PlayerActionRequest (seat=0)`.  
   - She responds by calling player_submit_action(seat=0, action_type=2, amount=100).
   - The `GameStateManager` processes it and updates Alice's contributed to 220 total for the round.  
   - The pot increases to 480 (the prior 380 + 100).  
   - The highest_bet is now 100, and a follow-up `PlayerActionRequest` is issued.

3) Bob calls 100:  
   - Bob receives the next `PlayerActionRequest (seat=1)`.  
   - He responds by calling player_submit_action(seat=1, action_type=1, amount=100).
   - Bob's contributed increases to 220, the pot rises to 580, and the `GameStateManager` updates the turn.  
   - A new `PlayerActionRequest` goes to seat 3 (David).

4) David goes All-In for his remaining 380:  
   - David receives a PlayerActionRequest from the GameStateManager (seat=3).
   - He responds by going all-in for his remaining calling player_submit_action(seat=3, action_type=3, amount=380).
   - This raises the bet from 100 to 380, leaving each other player to decide if they will call the extra 280 or fold and the `GameStateManager` updates the turn and extends it to the next round by calling `gsm_apply_player_action_to_move_to_next_player`

5) Alice folds:  
   - Alice receives a PlayerActionRequest from the GameStateManager (seat=0).
   - She responds by folding by calling player_submit_action(seat=0, action_type=3, amount=0).
   - The GameStateManager processes her response and updates the game by calling gsm_apply_player_action_to_move_to_next_player(...)
   - Alice's stack remains 280 and her contributed remains 220.

6) Bob calls:  
   - Bob receives a PlayerActionRequest from the GameStateManager (seat=1).
   - He responds by calling player_submit_action(seat=1, action_type=1, amount=280).
   - The GameStateManager processes his response and then realizes that all players have called or folded. So, it calls `gsm_advance_phase_turn_river(...)` to advance the phase and create a `PlayerActionRequest` for the next round.
   - Bob's stack goes from 280 → 0 and his contributed goes from 220 → 500.
   - The pot grows to 860 (580 + 280).

End of River Table → (Seat = 0: Alice, 1: Bob, 2: Carol, 3: David)

Community Cards: 7 Heart, J  Spade, A Clover, J Clover, 5 Heart

| Player | Stack | Contributed | Folded? | All-In? | Hand      | Total Pot = 860 |
|--------|-------|------------|---------|---------|-----------|-----------------|
| Alice  | 280   | 220        | **true**| false   | 2 Clover, 7  Spade    | 860             |
| Bob    | 0     | 500        | false   | true    | K Heart, K Diamond    | 860             |
| Carol  | 480   | 20         | true    | false   | 4 Clover, Q  Spade    | 860             |
| David  | 0     | 500        | false   | true    | A Diamond, 9 Clover    | 860             |


#### Determining the winner

At the end of the River round, the game enters the Showdown phase. By this point, the HouseDealer has revealed five community cards (7 Heart, J  Spade, A Clover, J Clover, 5 Heart), and each active player still in the hand shows their hole cards to form the best five-card combination. Let's consider the final scenario given our table:

**Community Cards Recap**

- Flop: [7 Heart, J  Spade, A Clover]  
- Turn: [J Clover]  
- River: [5 Heart]

**Player Hole Cards**

- Alice (Seat 0):
  Hole Cards: (Seat 1, folded earlier, does not show cards)
- Bob (Seat 1):
  Hole Cards: [K Heart, K Diamond]
- Carol (Seat 2, folded earlier, does not show cards)
- David (Seat 3):
  Hole Cards: [A Diamond, 9 Clover]

#### Final 5-Card Hands
---

- Alice's is out of the running since she folded.
- Bob's Best 5: [J  Spade, J Clover, K Heart, K Diamond, A Clover]
  → He has Two Pair, Kings and Jacks, with an Ace kicker.
- David's Best 5: [J  Spade, J Clover, A Clover, A Diamond, 9 Clover]
  → He finishes with Two Pair, Aces and Jacks, featuring a 9 kicker.
- Carol is out of the running since she folded and does not go to showdown.

1) Each active player submits their final hand using:
   ```leo
   transition player_submit_final_hand(
       player_hand: PlayerHand, 
       community_hand: [Card; 5]
   ) -> FinalHand {
       // Verify the player owns these hole cards
       // Calculate final hand score using hole cards + community cards
       // Return FinalHand record with score
   }
   ```

2) The GameStateManager then processes these submissions through:
   ```leo
   transition gsm_determine_winner(
       gs: GameState,
       final_hand1: FinalHand, 
       final_hand2: FinalHand, 
       final_hand3: FinalHand, 
       final_hand4: FinalHand
   ) -> u8 {
       // Compare final hand scores
       // Handle folded players
       // Return winning seat index
   }
   ```

   The transition evaluates each hand's final_score and determines the winner. In our scenario:

   • Alice: Folded, ineligible.
   • Bob: Two Pair, Kings + Jacks.  
   • David: Two Pair, Aces + Jacks.  
   • Carol: Folded, ineligible.  

`gsm_determine_winner(...)` returns `1` for Bob, indicating he wins the pot. The end result is:

- **Bob** is now fully at 0, having lost his all-in.  
- **Alice** folded before calling the all-in; she retains **280** chips.  
- **Carol** had folded earlier and still has **480**.
- **David** starts the showdown with 0 (all-in), then wins the final pot of 860, bringing him up to **860 total**.  

| Player | Final Stack |
|--------|------------|
| Alice  | 280        |
| Bob    | 0          |
| Carol  | 480        |
| David  | 860        |


#### Conclusion of the Hand
---

By combining player_submit_final_hand and gsm_determine_winner (and ensuring each submission has a valid zero-knowledge proof), the system effectively resolves the showdown. All participants see verified results to the game without ever forcibly revealing all private hole cards—only the final claimed 5-card combination and an associated proof of correctness. This maintains each player's privacy while guaranteeing honest outcomes.

In the common workflow, whenever a player calls player_submit_final_hand, they cryptographically demonstrate that:
(1) The five cards they selected are indeed comprised of their own hole cards (of which they have ownership) plus any of the community cards visible to all. 
(2) They have used the logic from the "Evaluating the Player's 5-Card Hand" section to compute a final hand score deterministically.
This proof cannot be refuted, as all claims about card ownership, selection, and resulting hand strength are validated via zero-knowledge proofs. Therefore, no player can falsely claim a hand strength that doesn't match their hole cards or the shared community pool.

## Performance & Practical Considerations

One of the major benefits of our actor-based architecture is that multiple games (or "rooms") can run concurrently. Each room effectively has its own Dealer, GameState, and set of Players, all exchanging messages relevant only to that table. Since no single centralized server or actor instance is mandated for all games, this design is highly scalable. Different operators can host separate RoomManager and Dealer services, thus supporting multiple poker rooms simultaneously without overloading any single process.

However, generating the zero-knowledge proofs with the Leo Language can introduce latency. While the published proofs on-chain are succinct, the off-chain generation step involves cryptographic computations that can be slow—particularly when producing proofs for deck shuffling, card dealing, or verifying hand combinations. This means a small but important delay in real-time interaction, as players, dealers, and game managers must wait for proof generation (and potentially block confirmations on-chain) before proceeding. 

Additionally, there is a communication overhead for the actors to locate and decode the relevant records in each newly produced block. Especially in high-throughput scenarios, an off-chain actor must scan potential block data for matching records (e.g., "player_joined_room" or "player_submitted_action"), which can be time-consuming. Our approach optimizes by limiting the total number of on-chain records, posting only those essential to game progression—other logic and computations happen off-chain to maintain responsiveness.

Overall, the architecture remains very scalable because:  
• Multiple concurrent rooms/games can operate in parallel, each with its own off-chain Dealer and GameStateManager.  
• Proof generation, while still a bottleneck, is offloaded to each participating actor's environment (e.g., each player or each room's Dealer).  
• No single entity is required to coordinate all games. Instead, each room or game runs autonomously.  

By splitting heavy computations (deck permutations, hand evaluations, proof generation) off-chain and placing only the final proofs and essential state transitions on-chain, we achieve a practical balance of performance, privacy, and trustlessness. This structure ensures the system can scale well beyond a single table or small number of users, ultimately supporting many active rooms with minimal interference among them.

## Conclusion

ZK Poker stands as more than just a fun application; it serves as a groundbreaking demonstration of Aleo's zero-knowledge tech stack in action. By enabling fully private, trustless, and event-driven gameplay, this project shows exactly how to leverage Aleo's record model and Leo language to build next-generation decentralized applications. The result is a practical, engaging use case that caters to an established audience (poker players) while advancing the frontier of cryptography and on-chain privacy.

Importantly, this initiative has the potential to attract new users to the Aleo ecosystem, showcasing an accessible application that blends entertainment with cutting-edge cryptographic techniques. Developers, in turn, gain a powerful reference implementation for how zero-knowledge proofs can keep sensitive state hidden, automate off-chain events, and maintain full transparency of rules and outcomes. ZK Poker proves that complex, real-time multi-player games—often deemed "too private" or "too stateful" for blockchains—are not only possible but can thrive with Aleo's architecture.

By funding this project, the Aleo community invests in a high-impact case study that promotes Leo programming best practices, fosters innovation around zero-knowledge proofs, and enhances Aleo's profile as a hub for advanced decentralized gaming logic. This synergy between technical depth, user appeal, and ecosystem growth underscores why ZK Poker is uniquely poised to push Aleo's capabilities forward, making a strong case for grant support.
