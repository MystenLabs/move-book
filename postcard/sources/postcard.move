// ANCHOR: all
// ANCHOR: module
module postcard::postcard {
// ANCHOR_END: module
    // ANCHOR: imports
    use std::string::String;
    use sui::object::UID;
    use sui::transfer;
    use sui::tx_context::TxContext;
    // ANCHOR_END: imports

    use fun sui::object::new as TxContext.new;

    // ANCHOR: struct
    /// The Postcard object.
    public struct Postcard has key {
        /// The unique identifier of the Object.
        /// Created using the `object::new()` function.
        id: UID,
        /// The message to be printed on the gift card.
        message: String,
    }
    // ANCHOR_END: struct

    // ANCHOR: new
    /// Create a new Postcard with a message.
    public fun new(message: String, ctx: &mut TxContext): Postcard {
        Postcard {
            id: ctx.new(),
            message,
        }
    }
    // ANCHOR_END: new

    // ANCHOR: send_to
    /// Send the Postcard to the specified address.
    public fun send_to(card: Postcard, to: address) {
        transfer::transfer(card, to)
    }
    // ANCHOR_END: send_to

    // ANCHOR: keep
    /// Keep the Postcard for yourself.
    public fun keep(card: Postcard, ctx: &TxContext) {
        transfer::transfer(card, ctx.sender())
    }
    // ANCHOR_END: keep

    // ANCHOR: update
    /// Update the message on the Postcard.
    public fun update(card: &mut Postcard, message: String) {
        card.message = message
    }
    // ANCHOR_END: update
}
// ANCHOR_END: all
