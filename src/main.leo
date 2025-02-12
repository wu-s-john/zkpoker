import dealer.aleo;
import room_manager.aleo;

// The 'hello' program.
program zkpoker.aleo {
    // -----------------------------------
    // HouseDealer Functions and Transitions
    // -----------------------------------

    transition main(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }
}