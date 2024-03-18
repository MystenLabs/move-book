Display is a template engine with on-chain configuration allowing creators to describe their objects through a set of simple template strings which allow for object value, nested paths + dynamic fields substitution.

```
"name": "Capy Name is: {name}",
"description": "Capys are cute and fun, join us!"
```

When a Wallet or an App queries an object, they can specify a flag to get the Display (processed template) for a specific object:

```
objectId: 0x.....
display: {
  "name": "Capy Name is Bob",
  "description": "....stays the same..."
}

```

We have a set of recommended keys which ecosystem products would support: “name”, “description”, “img_url” etc But no one is stopping developers from adding any keys including custom ones which make use of the template engine + FN’s quick access to objects to prepare data for their applications better.The most complicated scenario in SDKs is fetching dynamic fields of an object - one has to query dynamic fields of an object separately and if these  fields use custom type keys (which will be the case in 90% of apps), the query not only requires additional HTTP request but also complicated key construction eg `get_field(0x……::custom::Key<0x0::type::Param> { id: 0x…. })`

But since FN has access to objects’ data and their dynamic fields, adding a DynField access to the template seems like a very reasonable hack + app developers always know what they need and control the Display for their types.