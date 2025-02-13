import room_manager.aleo;
import dealer.aleo;
program zkpoker_jwu.aleo;

struct PlayerRoomConfig:
    player_address as address;
    bet as u64;

struct RoomConfig:
    big_blind as u64;
    big_blind_seat as u8;
    small_blind as u64;
    small_blind_seat as u8;
    dealer_seat as u8;
    min_stack as u64;
    seats as u8;
    room_id as u32;
    joined_users as [PlayerRoomConfig; 4u32];
    num_joined_users as u8;
    game_state_manager_address as address;

struct Card:
    rank as u8;
    suit as u8;
    index as u8;

struct Deck:
    cards1 as [Card; 26u32];
    cards2 as [Card; 26u32];

struct HouseDealerState:
    room_id as u32;
    deck as Deck;
    next_card_index as u8;
    player_addresses as [address; 4u32];

struct Permutation:
    perm1 as [u8; 26u32];
    perm2 as [u8; 26u32];

struct KeyValue:
    k as u8;
    v as u8;

struct PermutatedTable:
    perm1 as [KeyValue; 26u32];
    perm2 as [KeyValue; 26u32];

function main:
    input r0 as u32.public;
    input r1 as u32.private;
    add r0 r1 into r2;
    output r2 as u32.private;
