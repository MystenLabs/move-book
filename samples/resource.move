module Collection {

    use 0x1::Vector;
    use 0x1::Signer;

    struct Item {}

    resource struct T {
        items: vector<Item>
    }

    public fun start_collection(account: &signer) {
        move_to<T>(account, T {
            items: Vector::empty<Item>()
        });
    }

    public fun size(account: &signer): u64 acquires T {
        let owner = Signer::address_of(account);
        let collection = borrow_global<T>(owner);

        Vector::length(&collection.items)
    }

    public fun put_item(account: &signer) acquires T {
        let collection = borrow_global_mut<T>(Signer::address_of(account));

        Vector::push_back(&mut collection.items, Item {});
    }

    public fun exists(at: address): bool {
        ::exists<T>(at)
    }

    public fun destroy(account: &signer) acquires T {

        // account no longer has resource attached
        let collection = move_from<T>(Signer::address_of(account));

        // now we must use resource value - we'll destructure it
        let T { items: _ } = collection;
    }
}
