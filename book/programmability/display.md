---
description: "Object Display in Sui: define metadata templates for your objects with the Display Registry, and migrate Display from V1 to V2."
---

# Object Display

Objects on Sui are explicit in their structure and behavior and can be displayed in an
understandable way. However, to support richer metadata for clients, there's a standard and
efficient way of "describing" them to the client - the `Display` object, registered in the system
_Display Registry_ defined in the [Sui Framework](./sui-framework).

## Background

Historically, there were different attempts to agree on a standard structure of an object so it can
be displayed in a user interface. One of the approaches was to define certain fields in the object
struct which, when present, would be used in the UI. This approach was not flexible enough and
required developers to define the same fields in every object, and sometimes the fields did not make
sense for the object.

```move file=packages/samples/sources/programmability/display.move anchor=background

```

If any of the fields contained static data, it would be duplicated in every object. And, since Move
does not have interfaces, it is not possible to know if an object has a specific field without
"manually" checking the object's type, which makes the client fetching more complex.

## Object Display

To address these issues, Sui introduces a standard way of describing an object for display. Instead
of defining fields in the object struct, the display metadata is stored in a separate object -
`Display<T>` - which is associated with the type `T`. This way, the display metadata is not
duplicated, and it is easy to extend and maintain.

Another important feature of Sui Display is the ability to define templates and use object fields in
those templates. Not only does it allow for a more flexible display, but it also frees the developer
from the need to define the same fields with the same names and types in every object.

> The Object Display is natively supported by the
> [Sui Full Node](https://docs.sui.io/operators/full-node/sui-full-node), and the client can fetch
> the display metadata for any object if the object type has a Display associated with it.

## Display Registry

For every type `T` there is exactly one `Display<T>`, and it lives at a predictable address. Both
properties come from the _Display Registry_ - a system shared object located at the reserved address
`0xd` (see [Reserved Addresses](./../appendix/reserved-addresses)). When a display is created, its
object ID is
[derived](https://docs.sui.io/references/framework/sui_sui/derived_object) from the registry's `UID`
and the type `T`. As a result, anyone - including RPCs and other clients - can compute the ID of
`Display<T>` offline and fetch it directly, without scanning events or querying historical data.

```move
module sui::display_registry;

/// The root of display, to enable derivation of addresses.
/// The address is system-generated at `0xd`.
public struct DisplayRegistry has key { id: UID }

/// Holds the display values for the type `T`.
public struct Display<phantom T> has key {
    id: UID,
    /// All the (key,value) entries for a given display object.
    fields: VecMap<String, String>,
    /// ID of the `DisplayCap` managing this display. `None` for
    /// migrated V1 displays until the capability is claimed.
    cap_id: Option<ID>,
}

/// The capability object that is used to manage the display.
public struct DisplayCap<phantom T> has key, store { id: UID }
```

The `Display<T>` object itself is _shared_, and the authority over it is represented by a separate
owned object - the `DisplayCap<T>` [capability](./capability). The holder of the capability can
`set`, `unset`, or `clear` the display fields at any time, and the changes apply globally without
the need to update every object. The capability can be transferred to another account, or built into
an application with custom metadata-management functionality.

## Creating a Display

A new `Display` is created with one of two functions, both taking a mutable reference to the
`DisplayRegistry` and returning the `Display<T>` together with its `DisplayCap<T>`:

- `display_registry::new<T>` - takes an [Internal Permit](./../move-basics/internal-permit), and
  hence can only be called from the module that defines `T`;
- `display_registry::new_with_publisher<T>` - takes the [Publisher](./publisher) object, for cases
  when the display is created outside of the defining module.

Because the registry is a shared object, it cannot be accessed in the
[module initializer](./module-initializer) - the display is created by a separate, one-time call
right after the package is published:

```move file=packages/samples/sources/programmability/display.move anchor=hero

```

The `set` calls define the template fields, and `share` finalizes the creation by sharing the
`Display` object; the `DisplayCap` is then transferred to the publisher, who keeps it to update the
fields later. Note that the function is defined as `entry` rather than `public`: a one-time setup
function is best kept out of the package's public API, so that a later upgrade can remove it -
[upgrade compatibility rules](https://docs.sui.io/develop/publish-upgrade-packages/upgrade)
freeze `public` function signatures, but not `entry` ones.

## Standard Fields

The fields that are supported most widely are:

- `name` - A name for the object. The name is displayed when users view the object.
- `description` - A description for the object. The description is displayed when users view the
  object.
- `link` - A link to the object to use in an application.
- `image_url` - A URL or a blob with the image for the object.
- `thumbnail_url` - A URL to a smaller image to use in wallets, explorers, and other products as a
  preview.
- `project_url` - A link to a website associated with the object or creator.
- `creator` - A string that indicates the object creator.

> Please refer to the [Sui Documentation](https://docs.sui.io/develop/objects/display) for the most
> up-to-date list of supported fields.

While there's a standard set of fields, the Display object does not enforce them. The developer can
define any fields they need, and the client can use them as they see fit. Some applications may
require additional fields and omit others, and the Display is flexible enough to support them.

## Template Syntax

Every value in a Display is a _format string_ - a mix of literal text and expressions delimited by
`{` and `}`. The simplest expression is a field path: `{path}` is replaced with the value of the
field at that path, where the path is a dot-separated list of field names starting from the object
being displayed. To output a literal brace, double it - `{{` becomes `{`.

```move file=packages/samples/sources/programmability/display.move anchor=nested

```

The Display for the type `LittlePony` above could be defined as follows:

```json
{
  "name": "Just a pony",
  "image_url": "{image_url}",
  "description": "{metadata.description}"
}
```

A field path is only the most basic expression. The full form of an expression has three parts - a
_chain_ that navigates into the data, an optional list of _fallbacks_ separated by `|`, and an
optional _transform_ prefixed with `:` that controls how the value is rendered:

```text
{ chain | fallback | ... : transform }
```

The following sections walk through the parts of this syntax that come up most often. For the
complete grammar - literals, struct and enum values, derived-object access, and the exhaustive
transform list - see the
[Object Display Syntax](https://docs.sui.io/references/object-display-syntax) reference.

### Vector and Map Indexing

A chain can index into a `vector` or a `VecMap` with square brackets. Numeric indices always carry a
type suffix - `0u64`, not `0` - and another field's value can be used as the index:

```text
{items[0u64]}           first element of the `items` vector
{items[idx]}            use the `idx` field's value as the index
{scores[6u32]}          look up the key `6u32` in a VecMap, returns its value
```

### Dynamic Field Access

Templates can reach beyond the object's own fields and load
[dynamic fields](./dynamic-fields) from storage. The `->` operator loads a dynamic field, `=>` loads
a [dynamic object field](./dynamic-object-fields), and the key goes in brackets:

```text
{parent->['color']}     dynamic field with the string key 'color'
{parent->['color'].x}   read field `x` on the loaded value
{parent=>['hat']}       dynamic object field (the value is a full object)
```

Because each load reads from storage, they are budgeted: a template may perform at most 8 object
loads by default, with `->` costing one and `=>` costing two.

### Transforms

By default a value is rendered as a human-readable string. A transform after `:` changes that -
useful for values that are not plain text, such as byte vectors or timestamps:

| Transform         | Effect                                                            |
| ----------------- | ---------------------------------------------------------------- |
| `str` _(default)_ | Human-readable string; UTF-8 for `String` and `vector<u8>`.      |
| `hex`             | Lowercase, zero-padded hexadecimal.                              |
| `base64`          | Base64-encoded bytes; accepts `url` and `nopad` modifiers.       |
| `bcs`             | BCS-serialized value, then Base64-encoded - for aggregate types. |
| `json`            | Structured JSON value; only when it is the whole format string.  |
| `timestamp` (`ts`)| A numeric value read as Unix milliseconds, formatted ISO 8601.   |
| `url`             | Like `str`, but percent-encodes reserved URL characters.         |

```text
{amount:hex}                    render `amount` as hex
{created_at:ts}                 "2023-04-12T17:00:00Z"
{metadata:json}                 emit the whole struct as JSON
```

### Fallbacks

If a chain evaluates to null - a missing field, an out-of-bounds index, or a `None`
[Option](./../move-basics/option) - the next chain after `|` is tried. A string literal in single
quotes makes a convenient default:

```text
{display_name | name | 'Anonymous'}
```

If every alternative is null, the whole format string evaluates to null and the field is omitted from
the result.

## Migrating from V1 to V2

The registry-backed Display described on this page is the second version of the standard - _Display
V2_. The original one - V1, implemented in the `sui::display` module - predates the registry: V1
`Display<T>` objects were owned rather than shared, could only be created with the `Publisher`
object, and were discovered through events. Any number of V1 displays could exist for the same type,
and full nodes used the most recently updated one. V2 replaces event-based discovery with derivation
from the registry, and reduces "any number of displays" to exactly one per type.

Existing V1 displays were migrated to V2 automatically by a system migration: for every type with a
V1 display, there is already a shared `Display<T>` with the same fields and with `cap_id` set to
`none`. To manage such a display, the creator claims its `DisplayCap` in one of two ways:

- `claim` - consumes the legacy V1 `Display` object as the proof of authority over the type,
  destroying it in the process;
- `claim_with_publisher` - uses the [Publisher](./publisher) object instead; the leftover V1 object
  can then be destroyed with `delete_legacy`.

```move file=packages/samples/sources/programmability/display.move anchor=migrate

```

For a V1 display that was created after the system migration took place, the
`display_registry::migrate_v1_to_v2` function performs the migration directly: it creates the V2
`Display`, copies the fields from the legacy object, destroys it, and returns the new display
together with its capability.

## Further Reading

- [Object Display](https://docs.sui.io/develop/objects/display) in the Sui Documentation
- [Object Display Syntax](https://docs.sui.io/references/object-display-syntax) - the full template
  language reference
- [Publisher](./publisher) - the representation of the creator
- [Internal Permit](./../move-basics/internal-permit) - the authorization used to create a display
