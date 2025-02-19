# Object Display

Objects on Sui are explicit in their structure and behavior and can be displayed in an
understandable way. However, to support richer metadata for clients, there's a standard and
efficient way of "describing" them to the client - the `Display` object defined in the
[Sui Framework](./sui-framework.md).

## Background

Historically, there were different attempts to agree on a standard structure of an object so it can
be displayed in a user interface. One of the approaches was to define certain fields in the object
struct which, when present, would be used in the UI. This approach was not flexible enough and
required developers to define the same fields in every object, and sometimes the fields did not make
sense for the object.

```move
{{#include ../../../packages/samples/sources/programmability/display.move:background}}
```

If any of the fields contained static data, it would be duplicated in every object. And, since Move
does not have interfaces, it is not possible to know if an object has a specific field without
"manually" checking the object's type, which makes the client fetching more complex.

## Object Display

To address these issues, Sui introduces a standard way of describing an object for display. Instead
of defining fields in the object struct, the display metadata is stored in a separate object, which
is associated with the type. This way, the display metadata is not duplicated, and it is easy to
extend and maintain.

Another important feature of Sui Display is the ability to define templates and use object fields in
those templates. Not only it allows for a more flexible display, but it also frees the developer
from the need to define the same fields with the same names and types in every object.

> The Object Display is natively supported by the [Sui Full Node](https://docs.sui.io/guides/operator/sui-full-node), and the client can fetch the display
> metadata for any object if the object type has a Display associated with it.

```move
{{#include ../../../packages/samples/sources/programmability/display.move:hero}}
```

## Creator Privilege

While the objects can be owned by accounts and may be a subject to
[True Ownership](./../object/ownership.md#account-owner-or-single-owner), the Display can be owned
by the creator of the object. This way, the creator can update the display metadata and apply the
changes globally without the need to update every object. The creator can also transfer Display to
another account or even build an application around the object with custom functionality to manage
the metadata.

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

> Please, refer to the [Sui Documentation](https://docs.sui.io/standards/display) for the most
> up-to-date list of supported fields.

While there's a standard set of fields, the Display object does not enforce them. The developer can
define any fields they need, and the client can use them as they see fit. Some applications may
require additional fields, and omit other, and the Display is flexible enough to support them.

## Working with Display

The `Display` object is defined in the `sui::display` module. It is a generic struct that takes a
phantom type as a parameter. The phantom type is used to associate the `Display` object with the
type it describes. The `fields` of the `Display` object are a `VecMap` of key-value pairs, where the
key is the field name and the value is the field value. The `version` field is used to version the
display metadata, and is updated on the `update_display` call.

File: sui-framework/sources/display.move

```move
struct Display<phantom T: key> has key, store {
    id: UID,
    /// Contains fields for display. Currently supported
    /// fields are: name, link, image and description.
    fields: VecMap<String, String>,
    /// Version that can only be updated manually by the Publisher.
    version: u16
}
```

The [Publisher](./publisher.md) object is required to a new Display, since it serves as the proof of
ownership of type.

## Template Syntax

Currently, Display supports simple string interpolation and can use struct fields (and paths) in its
templates. The syntax is trivial - `{path}` is replaced with the value of the field at the path. The
path is a dot-separated list of field names, starting from the root object in case of nested fields.

```move
{{#include ../../../packages/samples/sources/programmability/display.move:nested}}
```

The Display for the type `LittlePony` above could be defined as follows:

```json
{
  "name": "Just a pony",
  "image_url": "{image_url}",
  "description": "{metadata.description}"
}
```

## Multiple Display Objects

There's no restriction to how many `Display<T>` objects can be created for a specific `T`. However,
the most recently updated `Display<T>` will be used by the full node.

## Further Reading

- [Sui Object Display](https://docs.sui.io/standards/display) is Sui Documentation
- [Publisher](./publisher.md) - the representation of the creator
