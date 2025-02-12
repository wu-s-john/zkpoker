program room_manager.aleo;

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

record RoomConfigRequest:
    owner as address.private;
    room_id as u32.private;
    room_config as RoomConfig.private;

record HouseDealerCreateDeckRequest:
    owner as address.private;
    room_id as u32.private;
    player_addresses as [address; 4u32].private;

mapping rooms:
    key as u32.public;
    value as RoomConfig.public;

mapping next_room_id:
    key as boolean.public;
    value as u32.public;

function rm_create_room:
    input r0 as u64.private;
    input r1 as u64.private;
    input r2 as u64.private;
    input r3 as u8.private;
    input r4 as u64.private;
    cast 0group into r5 as address;
    cast r5 0u64 into r6 as PlayerRoomConfig;
    cast self.caller r4 into r7 as PlayerRoomConfig;
    cast  r7 r6 r6 r6 into r8 as [PlayerRoomConfig; 4u32];
    cast 0group into r9 as address;
    cast r0 0u8 r1 0u8 0u8 r2 r3 0u32 r8 1u8 r9 into r10 as RoomConfig;
    async rm_create_room r10 into r11;
    output r10 as RoomConfig.private;
    output r11 as room_manager.aleo/rm_create_room.future;

finalize rm_create_room:
    input r0 as RoomConfig.public;
    get.or_use next_room_id[true] 0u32 into r1;
    add r1 1u32 into r2;
    set r0 into rooms[r2];
    set r2 into next_room_id[true];

function rm_join_room:
    input r0 as u32.private;
    input r1 as u64.private;
    async rm_join_room r0 self.caller r1 into r2;
    output r2 as room_manager.aleo/rm_join_room.future;

finalize rm_join_room:
    input r0 as u32.public;
    input r1 as address.public;
    input r2 as u64.public;
    get rooms[r0] into r3;
    lt r3.num_joined_users r3.seats into r4;
    assert.eq r4 true;
    cast r1 r2 into r5 as PlayerRoomConfig;
    is.eq r3.num_joined_users 0u8 into r6;
    ternary r6 r5.player_address r3.joined_users[0u32].player_address into r7;
    ternary r6 r5.bet r3.joined_users[0u32].bet into r8;
    cast r7 r8 into r9 as PlayerRoomConfig;
    is.eq r3.num_joined_users 1u8 into r10;
    ternary r10 r5.player_address r3.joined_users[1u32].player_address into r11;
    ternary r10 r5.bet r3.joined_users[1u32].bet into r12;
    cast r11 r12 into r13 as PlayerRoomConfig;
    is.eq r3.num_joined_users 2u8 into r14;
    ternary r14 r5.player_address r3.joined_users[2u32].player_address into r15;
    ternary r14 r5.bet r3.joined_users[2u32].bet into r16;
    cast r15 r16 into r17 as PlayerRoomConfig;
    is.eq r3.num_joined_users 3u8 into r18;
    ternary r18 r5.player_address r3.joined_users[3u32].player_address into r19;
    ternary r18 r5.bet r3.joined_users[3u32].bet into r20;
    cast r19 r20 into r21 as PlayerRoomConfig;
    cast  r9 r13 r17 r21 into r22 as [PlayerRoomConfig; 4u32];
    add r3.num_joined_users 1u8 into r23;
    cast r3.big_blind r3.big_blind_seat r3.small_blind r3.small_blind_seat r3.dealer_seat r3.min_stack r3.seats r3.room_id r22 r23 r3.game_state_manager_address into r24 as RoomConfig;
    set r24 into rooms[r0];

function rm_request_game_creation:
    input r0 as u32.private;
    input r1 as RoomConfig.private;
    input r2 as address.private;
    is.eq r1.num_joined_users r1.seats into r3;
    assert.eq r3 true;
    is.eq r1.num_joined_users 4u8 into r4;
    assert.eq r4 true;
    cast  r1.joined_users[0u32].player_address r1.joined_users[1u32].player_address r1.joined_users[2u32].player_address r1.joined_users[3u32].player_address into r5 as [address; 4u32];
    cast r2 r0 r5 into r6 as HouseDealerCreateDeckRequest.record;
    cast r2 r0 r1 into r7 as RoomConfigRequest.record;
    async rm_request_game_creation r0 r1 into r8;
    output r7 as RoomConfigRequest.record;
    output r6 as HouseDealerCreateDeckRequest.record;
    output r8 as room_manager.aleo/rm_request_game_creation.future;

finalize rm_request_game_creation:
    input r0 as u32.public;
    input r1 as RoomConfig.public;
    get rooms[r0] into r2;
    is.eq r2.big_blind r1.big_blind into r3;
    assert.eq r3 true;
    is.eq r2.small_blind r1.small_blind into r4;
    assert.eq r4 true;
    is.eq r2.min_stack r1.min_stack into r5;
    assert.eq r5 true;
    is.eq r2.seats r1.seats into r6;
    assert.eq r6 true;
    is.eq r2.num_joined_users r1.num_joined_users into r7;
    assert.eq r7 true;
    is.eq r2.joined_users[0u32] r1.joined_users[0u32] into r8;
    assert.eq r8 true;
    is.eq r2.joined_users[1u32] r1.joined_users[1u32] into r9;
    assert.eq r9 true;
    is.eq r2.joined_users[2u32] r1.joined_users[2u32] into r10;
    assert.eq r10 true;
    is.eq r2.joined_users[3u32] r1.joined_users[3u32] into r11;
    assert.eq r11 true;
