# Derived UIDs

Sui offers a way to create predictable UIDs

## Limitations

- UID can be generated only once (dynamic field in the derivation root prevents duplicate creation),
  even if UID is deleted, there is no way to reclaim it. Understanding this property is crucial in
  application design: if application provides a way to "delete" an account, it may be a better
  option to _mark_ account as "deleted" instead of actually deleting.

## Application Examples

Derived UIDs is a large area with different (and not yet discovered!) use cases, however, the
general principles of application design include:

- Allowing transfers to accounts that have not yet been created. For example, a mailbox or an
  account. "Sign up to receive your gift" kind of applications.
- Simplifying discoverability of user accounts in applications. Where previously shared objects
  required extra map source (eg address) -> object, with derived addresses this link is as easy as
  derive(source) -> object.
- Derived UIDs don't need to be used in objects, they can be used as "managed accounts" for an
  application, since created UID can be used to _receive_ even without an object. However, due to
  _ID leak verifier_, "unused" UID can not be used in object instantiation later.
