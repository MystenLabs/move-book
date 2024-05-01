<!--

Stashing unused content and ideas for guides / pattern pages

-->

## Keeping the UID

The `UID` does not need to be deleted immediately after the object struct is unpacked. Sometimes it
may carry [Dynamic Fields](./../programmability/dynamic-fields.md) or objects transferred to it via
[Transfer To Object](./transfer-to-object.md). In such cases, the UID may be kept and stored in a
separate object.

## Proof of Deletion

The ability to return the UID of an object may be utilized in pattern called _proof of deletion_. It
is a rarely used technique, but it may be useful in some cases, for example, the creator or an
application may incentivize the deletion of an object by exchanging the deleted IDs for some reward.

In framework development this method could be used to ignore / bypass certain restrictions on
"taking" the object. If there's a container that enforces certain logic on transfers, like Kiosk
does, there could be a special scenario of skipping the checks by providing a proof of deletion.

_Tip: This is one of the open topics for exploration and research, and it may be used in various
ways!_

## ID Pointer Pattern

A very common scenario for [Capabilities](./../programmability/capability.md) is to store the `ID`
of the object that the capability is managing. This is called the _ID Pointer Pattern_. The pattern
is used to uniquely identify which object the capability is managing, and to ensure that the
capability is not reused for another object. Additionally, it serves a discovery purpose, as the
account can query the owned capabilities and find the managed object.

Typically, an implementation of this pattern will create both the managed object and the capability
in the same function, and link the UID of the managed object to the capability.

```move
{{#include ../../../packages/samples/sources/storage/uid-and-id.move:pointer_pattern}}
```
