// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::ticket {
    /// A Ticket for an event or a service. Non-transferable by default and
    /// the usage varies based on the application.
    public struct Ticket<T: store + drop> has key {
        id: UID,
        used: bool,
        metadata: T
    }

    /// Create a new Ticket with the metadata and the context.
    /// No need for a Witness here!
    public fun new<T: store + drop>(metadata: T, ctx: &mut TxContext): Ticket<T> {
        Ticket {
            id: object::new(ctx),
            used: false,
            metadata
        }
    }

    /// Consume the Ticket. Requires a Witness of the metadata type.
    /// May or may not be implemented by the application.
    public fun consume<T: store + drop>(_meta: T, ticket: &mut Ticket<T>) {
        ticket.used = true;
    }

    /// Transfer the Ticket to another user. Requires a Witness of the metadata type.
    /// May or may not be implemented by the application.
    public fun transfer<T: store + drop>(_meta: T, ticket: Ticket<T>, to: address) {
        transfer::transfer(ticket, to)
    }

    /// Get the metadata of the Ticket.
    public fun metadata<T: store + drop>(ticket: &Ticket<T>): &T {
        &ticket.metadata
    }

    /// Check if the Ticket has been used.
    public fun is_used<T: store + drop>(ticket: &Ticket<T>): bool {
        ticket.used
    }
}
