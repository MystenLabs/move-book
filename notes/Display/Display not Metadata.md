In this document we go over a few different kinds of objects trying to evaluate their requirements for metadata and generalize each case to find a potential for optimization or automation.

## The Problem

Given the Sui Object Model, typical Ethereum-style approach for metadata (storing it in IPFS, assigning to every token_id) is hardly applicable - there's no centralized control over an asset that is already owned, and the rich on-chain programmability implies dynamic object creation. Not to mention, following this approach would be a limiting and nonoptimal practice.

To illustrate that, we will go through 4 different groups of objects. Capys have three of them and perfectly match as the live example, and for the fourth one we use a "devnet NFT" - dummy example of an NFT-like object on Sui.

#### Utility objects
Objects that serve authorization purpose - the main authorization pattern used in Sui Move. Almost all of the modules have features guarded by a Capability, and generic modules allow for a Capability per Application (eg Marketplace). Some Capabilities mark ownership of a shared object on chain or an access to another account's shared data.

With Capabilities it is extremely imporant from the UX perspective to have a meaningful description as these objects may look similar and an accidental transfer of a wrong Capability might lead to significant loss. Not to mention basic "what is it" answer when someone sees a "Cap" in their wallet.

```rust
module capy::utility {
    /// A Capability which grants Capy Manager permission to add
    /// new genes and manage the Capy Market
    struct CapyManagerCap has key, store {
        id: UID
    }
}
```

#### Typical objects with data duplication
Common case with in-game items - a lot of similar objects grouped by some criteria. With objects like these it is important to find a way to optimize their size and minting / updating costs. Usually there's only one image or URL per group or criteria, and storing it inside every object is not the best practice.

Another case is that some of the in-game items are minted by user when a game allows them or they make a purchase, and for that to happen; some IPFS/Arweave metadata should be pre-created and stored somewhere which requires additional logic usually not related to the in-game properties of the item.

```rust
module capy::capy_items {
    /// A wearable Capy Item. For some items there can be an
    /// unlimited supply. And items with the same name are identical
    struct CapyItem has key, store {
        id: UID,
        name: String
    }
}
```

#### Unique objects with dynamic representation*
Sui Capys use dynamic image generation - when a Capy is born, it gets its attributes which define how Capy looks; when an item is put on a Capy, the visuals change, when multiple items are put, there's a chance of a bonus for a combination of items.

To achieve that, Capys have their API service to re-render the image on an user-triggered change. And the URL for a Capy is a template with the `capy.id`. Storing full URL as well as other fields in the Capy object given their diverse population also leads to excessive amounts of storage and gas paid by players.

```rust
module capy::capy {
    /// A Capy - very diverse object with different combination
    /// of genes. Created dynamically + for images a dynamic SVG
    /// generation is used.
    struct Capy has key, store {
        id: UID,
        genes: vector<u8>
    }
}
```
_*Capys are not guaranteed to be absolutely unique visually, but a chance of having two absolutely identical Capys is rather small given the internal 32-byte gene sequence and a chance of random mutation on each gene_

#### Objects with unique static content
The simplest scenario of all - an object representing everything itself. It is very easy to apply a metadata standard to an object of this kind especially if the object stays immutable forever. However, if the metadata standard evolves, and some ecosystem projects add new features for some properties, this object will always stay in its original form also pulling back and requiring backward-compatible changes.

```rust
module sui::devnet_nft {
    /// A Collectible with a static data. URL, name, description are
    /// set only once on a mint event
    struct DevNetNFT has key, store {
        id: UID,
        name: String,
        description: String,
        url: Url,
    }
}
```

## The Solution

Already proposed and partially implemented "Sui Object Display" solution addresses the cases listed above in an upgradable, flexible and highly customizable way. A `Display<T>` object can be created by the publisher of a collection or an application (general term - package) and set once for all instances of a type `T`.

This object contains a "map-like" structure (which can be easily represented in JSON), where keys are names of the display properties and values are programmable templates supporting string interpolation, object data reference, nested paths and dynamic fields in the future upgrades.

`Display`  is versioned, meaning that once a set of properties is defined and the templates are set, a version is published and forever stored on-chain making it possible to incrementally upgrade as well as discover and use previous versions.

#### Details

The basic set of properties that we suggest to use is:
- _name_ - a displayable name
- _description_ - a broader displayable description
- _link_ - a link to an object in an application / external link
- _image_url_ - an URL or a blob with an image
- _project_url_ - a link to the website
- _creator_ - mentions the creator

Experimental (work in progress):
- _owns_ - an ID of the object which this object grants ownership for
- _owner_ - address of the owner (for a shared object)
- _category_ - a category of an object

## Examples

In this section we apply Display to each of the cases from the first part of this document and give real life examples of display configuration.

### Unique static content

Since every object of this type is expected to store unique content, Display can directly reference these properties forming the correct view template for the object.
```rust
struct DevNetNFT has key, store {
    id: UID,
    name: String,
    description: String,
    url: Url,
}
```

Definition: `Display<sui::devnet_nft::DevNetNFT>`
```json
{
    "name": "{name}",
    "description": "{description}",
    "link": "https://explorer.sui.io/objects/{id}?network=devnet",
    "image_url": "{url}",
    "project_url": "https://github.com/MystenLabs/sui",
}
```

In case when IPFS (or any other storage provider) is used to upload assets, templates simplify URL generation, giving an option to store only unique parts of the data.
```json
{
    "image_url": "ipfs://{url}"
}
```


#### Utility

Utility objects get a way to be displayed just like any other object without overloading the package and the type definition with unnecessary fields. Single definition of Display covers all of the objects, and Capabilities usually serve one purpose and can be described statically.
```rust
struct CapyManagerCap has key, store { id: UID }
```

Definition: `Display<capy::capy::CapyManagerCap>`
```JSON
{
    "name": "Manager Capybility",
    "description": "Grants access to admin features of the Capy Marketplace \nas well as permission to mint new Capys",
    "image_url": "https://capy.art/magic_wand.png",
    "project_url": "https://capy.art/",
}
```

#### Data Duplication

For repetitive data objects the parameters can be used to create a variation of a name / url or other properties depending on what is stored in the object.
```rust
struct CapyItem has key, store {
    id: UID,
    name: String
}
```

Definition: `Display<capy::capy_items::CapyItem>`
```json
{
    "name": "{name} - a cute Capy acessory",
    "description": "A wearable Capy Item",
    "link": "https://capy.art/collection/items/{id}",
    "image_url": "https://api.capy.art/items/{name}/svg",
    "project_url": "https://capy.art/",
    "creator": "Anonimous Capy Artist"
}
```

###  Unique objects with dynamic representation

Similar to the above, Capy definition consists only of an ID, and the genes are not usable for display.
```rust
struct Capy has key, store {
    id: UID,
    genes: vector<u8>
}
```

Definition: `Display<capy::capy::Capy>`
```json
{
    "name": "Capy - one of many",
    "description": "Join our Capy adventure",
    "link": "https://capy.art/capy/{id}",
    "image_url": "https://api.capy.art/capys/{id}/svg",
    "project_url": "https://capy.art/",
    "creator": "Capy God"
}
```

## Special cases

There's a set of special cases which are pretty common on Sui and require extra attention: aquiring a `Display<T>`  for a wrapper - eg. `Display<Collectible<T>>` and a generic case of overriding the inner T by the wrapper display.

> Solutions described in this section are still in progess and can not be considered final.

### Creating a `Display<T>`  for a `Wrapper<T>`

When building a wrapper type, it is the responsibility of the wrapper module to provide access to inner Display's. An example of a module that does that and provides the Display for the container with a type parameter is our [`sui::collectible`](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/sources/collectible.move) module.

It is enough for the wrapper module to use their `Publisher` object to create `Display` for any type parameter `T` in their `Wrapper<T>`.

### Addressing the generic case

It is possible that the Wrapper type does not provide an interface for inner Displays. And due to the strict requirement for type signatures, there's no default way to define common case of `Wrapper<T>` for all of the T's at once. Solution to this is the introduction of two special types in the Display:

```rust
struct Placeholder has copy, drop, store {}
struct ObjectPlaceholder has key, store {}
```

If a `Display<Wrapper<ObjectPlaceholder>>` is defined and published, it will be a default fall-back template. There are two structs to cover all possible limitations on abilities set for the type parameter in the `Wrapper<T>`. Depending on the case, any or both of the placeholder types can be used by the wrapper module developers to provide default display for any `T`.

### Inheritance

Some modules provide a "thin" wrapper with some functionality on top while keeping the most of the data in the wrapped object. And in some cases inheriting display for the inner `T` might be the way to do. For that we're considering adding an `"inherit()"` function to the template engine to allow reusing the property of the `T` instead of overriding it or forcing creators or `T` create a separate Display for the `Wrapper<T>`. One of the goals of the Display system is minimizing effort of a publisher, allowing third party extensions to adapt to the original type.
