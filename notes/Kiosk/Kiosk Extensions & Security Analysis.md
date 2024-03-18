Kiosk in its core is a very simple (yet extendable) tool which provides the guarantee to Creators that their policies will be followed and completed and guarantees the Kiosk Owner protection of their assets. Better description of the principles used in the implementation can be found in the [[Architecture Philosophy]].

## Scenarios
There is a set of market needs which are either impossible or hardly achievable in the current version of the Kiosk. Most of them fall into one of the following buckets:

1. **Place items** into the user Kiosk without immediate concent from the Kiosk Owner; the most popular scenario is AirDrop as well as receiving other objects or rewards from the Marketplace / Game / Application in general.
2. **Immutably Borrow** items from the users' Kiosks - opens up the paid borrowing scenario as well as certain authorization features.
3. **Mutably Borrow** items - a third party is authorized to mutate objects in the user inventory. The game may upgrade a "Hero" to the next level, reset a counter or even take a "Shield" from the Hero inventory.
4. **Take** - only possible for non-locked items - an authorized third party takes the item(s) from the user Kiosk getting the full ownership over them; this mechanic bypasses the TransferPolicy requirement as no trade happens.

Potential scenarios without confirmed use cases:

5. **Delist** - third party can disable an active listing
6. **List** an item - exposes asset for purchase by anyone on the network. No current 
7. **List with a PurchaseCap** - completely locks an item (making it immutable and not withdrawable), a third party receives exclusive right to purchase the item for any price without user concent. 

## Current state
Currently, the only party that is authorized to perform any actions in the Kiosk is the Kiosk Owner (except for purchasing an active listing which is by nature / design available to anyone). The Kiosk Owner is a party (account or an object / system) that controls the `KioskOwnerCap` object for a specific Kiosk.

The main place for extendability in the Kiosk comes from the `list_with_purchase_cap` function. The Kiosk Owner can exclusively list an item and create a `PurchaseCap` for this listing. The item gets locked (cannot be taken / mutated) until the `PurchaseCap` is returned or used to purchase it. This mechanic is very dangerous as it may lead to the item (asset) locked in the Kiosk forever and needs to be handled with care. However it does enable third party trading logic...

### Example: Generic Auction 
Kiosk Owner wants to use a third party Auction module. The typical Auction design consists of a shared object and a logic around it for bidding / closing the Auction. The winning party always gets an object. In a default non-Kiosk scenario a user would lock their asset in the Auction object and lose control over it until the Action is over; in the Kiosk + PurchaseCap scenario, user keeps the ownership of the asset, and the traded object is not the asset itself but a PurchaseCap.

Important notes:
- Giving away the PurchaseCap leads to the asset being locked until the PurchaseCap is returned / used to purchase; the owner can still immutably borrow it and it is shown as owned.
- PurchaseCap is not a requirement to purchase - the winner of the generic auction wins the PurchaseCap but there's no obligation to use it. The price setting of the PurchaseCap might be too high.
- PurchaseCap does not set an explicit price, instead it sets a minimal price. It is possible that the Auction winner will purchase the item at the lowest bar lowering the royalty / creator fee / commission to the minimum value. The seller income is also not guaranteed in this scenario as the amount paid for the item is the seller's profit. Aucton winner can cheat on both - the creator and the seller (depending on how the auction is implemented).

Security implications:
- Asset can get locked forever if PurchaseCap is not used
- Both creator and seller risk getting paid less 
- Third party auction is managed by the third party (an Admin can lock / manipulate an auction)
- Auction module can get an upgrade while the auction is ongoing - absolute power in the hands of the auction publisher

### Example: Auction Extension
An Auction designed specifically for Kiosk (a "Kiosk Extension"), has a number of significant advantages over a generic object auction. An Auction designed specifically for Kiosk would:
- Use the user Kiosk as the central storage for bids / assets
- Store the PurchaseCap in the Kiosk; hence guarantee PurchaseCap safety
- Value the Kiosk Owner giving them power to control the auction
- Use the PurchaseCap directly with the winning bid therefore enforcing the correct amount of Coin passed into the Kiosk
- Be discoverable - it is very likely that at some point users will be able to see that there's an auction happening in this Kiosk (unlike with generic auction - requires separate discovery)

Enabling `PurchaseCap` functionality in the Kiosk has unblocked Kiosk interoperability with any trading modules on Sui, but the outcome is not ideal - the winner / the buyer of a third party Orderbook / Auction does not get an asset right away but receives the option to "buy it" or "lock it forever". This also leads to cheating on price setting in the Kiosk - which then affects the TransferRequest's `paid` field and the fee calculation in the TransferPolicy's "Rule"s.

To achieve the best outcome: guarantees for security and fairness of the trading, Kiosk trading modules should be designed **specifically for Kiosk**.

## Kiosk Extensions API
To address the growing needs of the ecosystem while retaining the security properties of the Kiosk, we propose the "Kiosk Extension API" or, simply put, the "Kiosk+" functionality.

The Extensions API is a set of features that extends the Kiosk itself (not the creator interface - the TransferPolicy), allowing for richer programmability around trading and accessing the stored assets.

### Requirements
While designing the Kiosk Extensions API we followed the security and ownership principles stated in the [[Architecture Philosophy]] as well as the following:
1. Any extended functionality of the Kiosk must be directly authorized by the Kiosk owner.
2. No extension can take the control from the Kiosk owner.
3. Extension is self contained and has access only to itself and its contents.
4. Every extension can be disabled instantly by the Kiosk owner.
5. Extensions API does not introduce new functionality to the Kiosk, and reuses existing.

### Implementation Details
Extension is an application authorized by the Kiosk Owner to perform certain actions. As such, it should have a different authorization scheme than the default one (based on the KioskOwnerCap) and have a set of methods accessible to the extension while it is authorized.

Extensions should reuse the Kiosk object as the storage base for metadata and they should not have access to the first level (base object's UID) to store dynamic fields. This is intended to protect the base object from storing too many keys - making the dynamic field queries simpler - while also encapsulating the extension storage in one place.

Extensions can be enabled only for specific types (eg. I allow an extension to borrow my "Capy" but I don't allow it to borrow my "GamePass").

While there's a requirement to disable an extension at any moment, the removal (uninstall) procedure should be secured and provided by the extension to prevent accidental asset loss. The extension storage must use one of the Sui Framework's dynamic field primitives which protect from dangling reference such as Table or Bag.

To be discoverable, the extension (with its configuration and storage) should be attached as a dynamic field to the base UID of the Kiosk.

Extensions API should follow the best implementation practices to be upgradable and "extendable". One example would be that instead of using direct permission fields in the configuration (for example `can_place: bool`) there can be a bitmask for different permissions - `001` = `can_place`. See [[Extension Permissions]] for details.

### Installing & Disabling
To install an extension, the Kiosk Owner must explicitly call `add_extension` function. First we make the function `entry` to prevent it from being called in a third party code. The method should take the Extension type as the type parameter as well as configuration options allowed for the extension. By default, when extension is added it is also enabled. 


### Allowed Actions



## Appendix 1: Glossary
- Item / Asset / Object - used interchangeably - Kiosk operates solely on structs with `key + store` abilities, which makes them freely transferable and ownable.

## Appendix 2: Kiosk functions list (sorted by security risk):
1. `delist` (safe, extra inconvenience)
2. `place` / `lock` (safe, no loss, potential for spam, abuse when `lock` is used instead of `place`)
3. `borrow` (assets secure / 3rd party authorization compromised)
4. `borrow_mut` / `borrow_val` (assets loss for dynamic fields / implicit loss)
5. `list` (asset loss / can be prevented with `delist`)
6. `list_with_purchase_cap` (asset is locked forever / asset loss)
7. `take` (asset loss if an asset is not locked)
