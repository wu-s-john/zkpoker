// The 'card' program.
program card.aleo {

    struct Card {
        rank: u8,
        suit: u8,
        index:u8
    }

    struct Deck {
        cards1: [Card; 26],
        cards2: [Card; 26],
    }

    transition main(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }
}
