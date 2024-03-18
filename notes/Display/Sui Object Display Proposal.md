## Introduction

Sui Object model answers the very common question of Web3 - what is an own-able asset. We don’t need to define a standard on whether to treat data on chain as an asset or just data ([see Evan’s talk on Websummit](https://www.youtube.com/watch?v=lWg66640bYU). However, another question remains - if asset is defined, how do we display it?

Typically in web3, an artist or a creator willing to mint a collection on chain would choose a metadata standard to go with - this decision will affect the code of the smart contract (on-chain code; which, in most of the cases is immutable). Often these standards belong to this or another marketplace therefore forcing the author to pick a side. But what if there wasn’t a need to make this choice and there was a way to define a common, ecosystem-wide way of setting the display of their objects. Even more - if any changes happen; or ecosystem develops, or a new marketplace pops-up, a developer / creator would be able to adapt their assets for a new trend seamlessly?

This proposal addresses the problem of “display” of on-chain assets off-chain in a soft, generic, and efficient way (see [[##Efficiency]]).

## The Problem and Current state

If every object on Sui is already its own thing, why can’t we agree on field names (and types - Move specific feature)? The best answer to this question is an illustration.

Here’s a dummy example of an Object (asset) defined on Sui. A creator of such an object might assume that every Wallet should automatically display their object (since names are very logical from a human standpoint).

```rust
module my_app::sui_buddy {
	/// "NFT" Object defined on Sui
    struct Buddy {
        /// Image URL
        img: Url,
        /// Unique name of the
        name: String,
    }
}
```

So let’s look at another module published by some other imaginary creator. How should this object be displayed in a wallet? Is there a way to have both the `Buddy` from the example above and the `Ticket` from this one being displayed correctly? And what correctly means in this context?

```rust
module haha_labs::ticket {
    /// Object used to sell tickets to events
    struct EventTicket {
        /// Event URL
        url: Url,
        /// QR Code URL to enter the event
        ticket_qr_url: Url,
    }
}
```

Currently, Sui Wallet and Sui Explorer (possibly some other ecosystem products) de-facto have a standard set of requirements to display objects. For example, a field with a name “name” and a type “String” will show as the title / name for the Object. However, a field with a name “url” and a type “Url” has to be an image URL and **can not** be a link that leads to some web page.

Looking at examples above we already see the conflict in interpretations of fields. From the creator perspective, their assets must have a way to be displayed in the Wallet in some unified and pretty way. But as a platform do we want to constrain everyone within a limited set of fields with specific meaning? The answer is no, and here’s another, more technical reason for it.

Let’s modify the Ticket example to make it follow currently required set of fields:

```rust
module haha_labs::ticket {
    struct EventTicket {
        /// Always with the same value: "events.sui ticket"
        name: String,
        /// Now an image URL - the same for all tickets
        /// Example: https://events.sui/ticket_img.png
        url: Url,
        /// Used to be `url` in the previous example
        event_url: Url,
        ticket_qr_url: Url
    }
}
```

Now the Ticket will be displayed nicely in the Wallet and explorer. It has an image URL as a “url” field and a “name” field. Does it solve the display issue? Yes. Does it have side effects? Also yes - the size of every object increases almost 1.5 times, depending on the actual lengths of strings and Urls; module developers need to spend extra time on implementing the functionality to add urls and names + spend extra gas on publishing.

It’s not a problem if we look at a single object. But it becomes one if the application scales 1000 times or a million times. Optimizing for storage and avoiding data repetition is an important aspect of building in Web3.

## Introducing Display

As a part of preparation for this proposal, we landed a very powerful feature, which allows package creators (developers) to create a Publisher object (see [the Pull Request](https://github.com/MystenLabs/sui/pull/7196)). The Publisher object acts as a *Capability* and a *Witness of publishing* making it possible to check whether some action was performed by an *owner (creator) of type*. For example: as a publisher of a game “SuiWarriors” with an asset “Warrior”, I can prove to the marketplace or any other application that I am the publisher of this type; and the third party can then unblock publisher-only functionality.

Applied to the topic of the current proposal: as a publisher of a type T, I (and only I) can create a `Display<T>` object.

So what is a Display object? First of all, it is an object which is created on chain and most likely shared - so it persists and becomes available for publisher-only modifications and free reads. What information does it contain? - a type signature for a *single type T* and set of “name->value” pairs where both names and values are strings. They will define how an object of this type T should be displayed.

Fields inside the Display object can have any names and any values; values support pattern matching with a special syntax (see [[#Display syntax]]). Roughly speaking, the standard is now defined not for the T, but for its Display object.

## Dealing with Metadata

We described a set of problems developers and the ecosystem are facing ([[#The Problem and Current state]]) and we suggested a way of mitigating them by introducing the Display object. However, how do current practices apply to it, and how it is supposed to function? - these questions are still unanswered.

First, we need to identify widely used practices for displaying NFTs in other networks, and the best way to do it is by analyzing most popular metadata standards. Many of them look similar ([OpenSea](https://docs.opensea.io/docs/metadata-standards), [Metaplex](https://docs.metaplex.com/programs/token-metadata/token-standard#the-non-fungible-standard)), having slight differences - for example property “background_url” is present in the OpenSea standard, while “symbol” is only in the Metaplex one.

Overall, most of the fields are common, and in the current state of the Sui Ecosystem, as we already mentioned, there is a similar de-facto existing standard; and it seems logical to finalize it and apply to the Display object that we described above. To be more specific:

| Field | Type | Description |
| --- | --- | --- |
| name | String | Name that is displayed in the Wallet |
| url | Url | A URL for the Image |
| * | Url | A clickable link to a webpage |

> TODO: Add other fields if there are any TODO: Add suggested fields (ie owner, description)

## Target audiences

1. Image NFT creators; most of the consumers should use objects for unique data in their assets - be it IPFS URL or maybe even a blob or an SVG code. This proposal gives them freedom of naming their fields in any way without additional linking or a need to have dynamic fields with metadata or an ID that points to a Collection object. [[###Example_1]]
2. Games and applications with repetitive data; Sui Frens is an examples of this category. If we were to mint many objects with similar properties (eg Capy Accessories or Weapon Skins), there’s no need for unnecessary information which can be automated with pattern matching and substitution. [[###Example_2]]
3. Utility Application and even DeFI. Some objects, such as custom LP tokens, TreasuryCap’s, Capabilities and other various types of objects can also be displayed in a nice and satisfying way. [[###Example_3]]
4. Treasuries, shared Coin solutions. Currently, there’s a very common request for tracking and showing logical ownership of objects if they’re shared. Coincidentally, this proposal can be one of the possible solutions to the problem, if an “owner” property is introduced. [[###Example_4]]
5. …and any other group of users / developers who want to have visuals for their objects

## Display syntax

For the tool to be usable and universal, the pattern syntax should cover 4 most common scenarios:

1. Using a field of an Object (eg “name” in `User { id, name }`)

2. Using a dynamic field and its fields

3. Using a field in a Bag

4. Using a field in a Table

### Syntax Definition

Currently, a syntax structure proposal is the following:

```bash
{ <display> }

-----------------

# term or a recursive path access or a term + recursive
display :=
  term
| display "." ident

term :=
  path
| function_identifier "(" (path ",")* path ")"

path :=
  ident
| path "." ident
```

### Syntax Samples

```
id
name
value.value
foo(value)
foo(value.value)
foo(value).x
foo(x.y).g

dynamic_field(0x00000000000000000000000000000000::my_package::Key { key: "boom }).name
```

## Examples

This section provides examples of Sui Move objects and a matching Display objects described in pseudo-syntax.

### Example_1

```rust
// The object only contains unique data;
struct MonkeyPunky has key, store {
  id: UID,
  // unique hash of the img in the IPFS
  ipfs: String,
  // unique name of the MonkeyPunky NFT
  name: String
}

Display<MonkeyPunky> {
  [ "name", "{name}" ],
  [ "description", "Mix of everything and nothing"],
  [ "img_url", "ipfs://{ipfs}"],
  [ "link", "https://monkey-punky.art/piece/{id}"],
  [ "project_link", "https://monkey-punky.art/about"]
}
```

### Example_2

```rust
/// A common accessory - there can be hundreds or thousands of identical items.
/// URLs for them are constructed in a common way based on their NAME and not
/// an ID or any other unique property.
struct CapyAccessory has key, store {
  id: UID,
  name: String,
  rarity: String,
  item_type: String,
}

Display<CapyAccessory> {
  [ "name", "{rarity} Capy Accessory - {name}" ],
  [ "description", "Worn on {item_type}" ],
  [ "img_url": "https://api.capy.art/item/{name}/svg" ],
  [ "link": "https://capy.art/accessories/{name}" ],
  [ "project_link": "https://capy.art/" ],
}
```

### Example_3

```rust
/// An object marking ownership of a Marketplace in a generic contract (eg
/// someone builds a markeplace platform for others to set up their trading
/// platforms)
struct MarketplaceOwnerCap has key {
  id: UID,
  marketplace_id: ID
}

Display<MarketplaceOwnerCap> {
  [ "name": "MyFancyMarket Admin Capability" ],
  [ "description": "Grants Admin permissions for the market: {marketplace_id} "],
  [ "img_url": "https://img.box/crown.png" ],
  [ "link": "https://sui-market.io/manage/{marketplace_id}" ],
  [ "project_link": "https://t.co/how-to-build-your-marketplace-on-sui" ]
}
```

### Example_4

```rust
/// A shared Coin which has logical (not-explicit) ownership.
struct BankAccount has key {
  id: UID,
  /// Stored Balance of some currency (here USD)
  balance: Balance<USD>,
  /// The account that can access the funds
  owner: address
}

Display<BankAccount> {
  [ "name": "Sui Bank Account" ],
  [ "img_url": "https://banking.sui/golden_coin.png" ],
  [ "description": "Account solution provided by Sui Banking™ "],
  [ "owner": "{owner}" ],
}
```

## DevX Call: Agenda

- Introduction and the idea
- All-in-one package for the ecosystem
- Ways to implement: Full RPC vs Pure FE
- Challenges? Ideas? Problems?

```jsx
sui_getObject(objectId, withDisplay);

sui_getDisplay(objectId)

{
  "name": "Capy Buddy123412412",
  "
}

Object => TypeId
TypeId => DisplayId => { pattern[] }

Object + pattern[]

```
