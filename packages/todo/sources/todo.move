/// Module: todo
module todo::todo {
    use std::string::String;

    use fun sui::object::uid_to_inner as UID.to_inner;

    /// Error code for when the caller is not the owner of the list.
    const ENotOwner: u64 = 0;
    /// Error code for when the caller is not a guest of the list.
    const ENotGuest: u64 = 1;

    /// The Capability to manage lists of todos.
    public struct ListOwnerCap has key, store { id: UID, lists: ID }

    /// List of todos. Can be managed by the owner and shared with others.
    public struct TodoList has key, store {
        id: UID,
        items: vector<String>
    }

    /// Create a new todo list.
    public fun new(ctx: &mut TxContext): (TodoList, ListOwnerCap) {
        let list = TodoList {
            id: object::new(ctx),
            items: vector[]
        };

        let cap = ListOwnerCap {
            id: object::new(ctx),
            list: object::id(&list)
        };

        (list, cap)
    }

    /// Add a new todo item to the list.
    public fun add(cap: &ListOwnerCap, list: &mut TodoList, item: String) {
        assert!(is_owner(list, cap), ENotOwner);
        list.items.push_back(item);
    }

    /// Remove a todo item from the list by index.
    public fun remove(cap: &ListOwnerCap, list: &mut TodoList, index: u64): String {
        assert!(is_owner(list, cap), ENotOwner);
        list.items.remove(index)
    }

    /// Delete the list and the capability to manage it.
    public fun delete(list: TodoList, cap: ListOwnerCap) {
        assert!(is_owner(&list, &cap), ENotOwner);

        let TodoList { id, items: _ } = list;
        let ListOwnerCap { id: cap_id, list: _ } = cap;

        cap_id.delete();
        id.delete();
    }

    public fun invite(cap: &ListOwnerCap, list: &TodoList, ctx: &mut TxContext): GuestCap {
        assert!(is_owner(list, cap), ENotOwner);
        GuestCap {
            id: object::new(ctx),
            list: object::id(list)
        }
    }

    public use fun guest_add as GuestCap.add;
    public use fun guest_remove as GuestCap.remove;
    public use fun guest_leave as GuestCap.leave;

    /// Adds a new todo item to the list as a guest.
    public fun guest_add(cap: &GuestCap, list: &mut TodoList, item: String) {
        assert!(is_guest(list, cap), ENotGuest);
        list.items.push_back(item);
    }

    /// Remove a todo item from the list by index as a guest.
    public fun guest_remove(cap: &GuestCap, list: &mut TodoList, index: u64): String {
        assert!(is_guest(list, cap), ENotGuest);
        list.items.remove(index)
    }

    /// Guests can remove themselves from the list.
    public fun guest_leave(cap: GuestCap) {
        let GuestCap { id, list: _ } = cap;
        id.delete();
    }

    /// Check if the caller is the owner of the list.
    public fun is_owner(list: &TodoList, cap: &ListOwnerCap): bool {
        list.id.to_inner() == cap.list
    }

    /// Check if the caller is a guest of the list.
    public fun is_guest(list: &TodoList, cap: &GuestCap): bool {
        list.id.to_inner() == cap.list
    }

    /// Get the number of items in the list.
    public fun length(list: &TodoList): u64 {
        list.items.length()
    }
}
