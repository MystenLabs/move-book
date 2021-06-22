address 0xA1 {
module Collection {

    use 0x1::Vector;
    use 0x1::Signer;

    struct Item has store, drop {}

    struct Collection has key {
        items: vector<Item>
    }

    public fun start_collection(account: &signer) {
        move_to<Collection>(account, Collection {
            items: Vector::empty<Item>()
        });
    }

    public fun size(account: &signer): u64 acquires Collection {
        let owner = Signer::address_of(account);
        let collection = borrow_global<Collection>(owner);

        Vector::length(&collection.items)
    }

    public fun put_item(account: &signer) acquires Collection {
        let collection = borrow_global_mut<Collection>(Signer::address_of(account));

        Vector::push_back(&mut collection.items, Item {});
    }

    public fun exists_at(at: address): bool {
        exists<Collection>(at)
    }

    public fun destroy(account: &signer) acquires Collection {

        // account no longer has resource attached
        let collection = move_from<Collection>(Signer::address_of(account));

        // now we must use resource value - we'll destructure it
        let Collection { items: _ } = collection;
    }
}
}
