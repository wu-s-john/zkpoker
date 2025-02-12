program card.aleo;

struct Card:
    rank as u8;
    suit as u8;
    index as u8;

function main:
    input r0 as u32.public;
    input r1 as u32.private;
    add r0 r1 into r2;
    output r2 as u32.private;
