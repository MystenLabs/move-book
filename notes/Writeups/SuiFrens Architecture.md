This document gives a high-level overview of the SuiFrens architecture.

## Principles

While choosing between different patterns and approaches, we defined the main principles for the solution.

1. Many ways to do the same thing - we're launching with two modules (we call them applications) that can mint new `suifren`'s, but there will be more, and the only thing we know about them is that they will "mint"
2. No centralization of data - there shouldn't be a single shared object in the middle; configurations should be managed separately and stored depending on the needs of application
3. Any module can be turned off at any moment - we expect to have "special events" during which we publish a new application with a unique minting logic; the module should be turned off when event ends; additionally we can discard any other module if we decide so
4. Atomic architecture - summary of the above - each module is an atomic piece without any special permissions; ideally it can be published by any party
5. One authority - admin can authorize and deauthorize applications in the suifrens ecosystem
6. Permissionless extendability - the main type `suifren` must follow every practice that increases usability and extendability; the set of constraints must be relaxed (key + store)

## Architecture: Core

The main goal of the core is to provide the main function of the system - `suifrens::mint<T>` and the authorization scheme. Since there's no object in the middle (P.2), authorization token (configuration) should be carried by each application separately. To achieve that we attach a dynamic field with a custom key - no other module can construct it - hence can't read, modify or delete. The action can only be performed by an admin (P.5)

```move
module suifrens::suifrens {

/// Custom key under which the app cap is attached.
struct AppKey<phantom T> has copy, store, drop {}

/// Attach authorization token to the application's UID
public fun authorize_app<T>(app: &mut UID, _: &AdminCap, /* options */) {
    df::add(app, AppKey<T> {}, AppCap { /* options */ });
}

/// Check authorization and mint a new SuiFren
public fun mint<T>(app: &mut UID, /* options */): SuiFren<T> {
    /* auth + minting logic */
}

/// Revoke AppCap and disallow minting
public fun deathorize_app<T>(app: &mut UID, _: &AdminCap) {
    let _: AppCap<T> = df::remove(app, AppKey {})
}
}
```

## Architecture: Application

Every application starts with an object that holds two configurations: inner parameters (defined as struct fields) and the core configuration (as a dynamic field). The application must keep the UID secure - once authorized, it can be used to call the `mint<T>` function. The only party which must have access to the UID mut is the Admin.

No application should be overly centralized and store the configuration for every friend minted. Instead, it should define custom application-specific configuration as custom keys and attach them to a suifren (for example, an app-specific limit). To make this configuration reusable it should provide mutable or immutable access to other applications so they can build on top of it.

```move
module suifrens::example {

/// The "application" object
struct App has key {
    id: UID,
    /* config */
}

/// Custom property the application uses for SuiFren's
struct AppProp has copy, drop, store {}

/// The main function of the application
public fun do_magic(app: &mut App, /* options */): SuiFren<Capy> {
    // ... custom authorization logic
    let fren = suifrens::mint<Capy>(&mut app.id, /* options */);
    df::add(suifrens::uid_mut(&mut fren, AppProp {}, 1337));
    fren
}

/// Getter for the custom property of a SuiFren (for future use)
public fun read_prop(fren: &SuiFren): u64 {
    *df::borrow(suifren::uid(fren), AppProp {})
}

/// Admin-only access to UID - the main guarantee of security
public fun uid_mut(app: &mut App, _: suifrens::AdminCap): &mut UID {
    &mut app.id
}
}
```

## Architecture: Main type

SuiFren should be as convinient to use as possible. It should be extendable - any application can add app-specific fields to it; it must have `key + store` so it can be wrapped, freely transferred and used as a dynamic field if needed. Any SuiFren can become an "authorized application" in the ecosystem (rather wild example but worth mentioning).

```move
module suifrens::suifrens {

    /// The main type of the system
    struct SuiFren<phantom T> has key, store {
        id: UID,
        /* fields */
    }

    /// Exposing the UID gives developers full freedom on building with a fren
    public fun uid_mut<T>(self: &mut SuiFren<T>): &mut UID {
        &mut self.id
    }
}
```

## Extras

Using `SuiFren<T>` gives flexibility over:
1. Display for `T`
2. Different minting logic implemented on per-app basis
3. Different authorization per `T`
4. Fancy mechanics of mixing `SuiFren<T>` and `SuiFren<K>`
5. TransferPolicy for `T` (in Kiosk)
