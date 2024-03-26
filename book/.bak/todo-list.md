# Building a TODO List
In this section, we will build a simple TODO list application. It's a common example used in programming tutorials, and what we love about this example, is that it's simple enough to understand, yet it has a lot of features to implement and to learn from. For starters, we will build a simple application that create new lists and manage them. The user story is simple:

User can create a new list
User can add an item to the list
User can remove an item from the list
User can delete the list
Only the owner of the list can manage it
Initialize a Project
Let's start by creating a new package for the TODO list application. We will call it todo_list.

$ sui move new todo_list
Now, the structure will be identical to the hello_world package, but with a different name. In this case it's todo_list.

todo_list
├── Move.toml
├── sources
│   └── todo_list.move
└── tests
    └── todo_list_tests.move
Create a Module
To cut some corners, let's replace the contents of the sources/todo_list.move with the following:

/// Module: todo_list
module todo_list::todo_list {
    use std::string::String;

    use fun sui::object::uid_to_inner as UID.to_inner;

    /// Error code for when the caller is not the owner of the list.
    const ENotOwner: u64 = 0;

    /// The Capability to manage lists of todos.
    public struct ListOwnerCap has key, store {
        id: UID,
        list: ID
    }

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

    /// Check if the caller is the owner of the list.
    public fun is_owner(list: &TodoList, cap: &ListOwnerCap): bool {
        list.id.to_inner() == cap.list
    }

    /// Get the number of items in the list.
    public fun length(list: &TodoList): u64 {
        list.items.length()
    }
}
While the contents may seem a bit overwhelming, we will break it down into smaller parts and explain each of them in detail in the next sections.

Build the Package
To make sure that everything is working as expected, we can run the sui move build command. If there are any errors, the compiler will let you know.

$ sui move build
The output should look like this and contain no errors:

$ sui move build
UPDATING GIT DEPENDENCY https://github.com/MystenLabs/sui.git
INCLUDING DEPENDENCY Sui
INCLUDING DEPENDENCY MoveStdlib
BUILDING todo_list
