# Resource by Example

In this section you'll finally learn how to use resources. We'll go through the process of defining a resource and methods to work with it, and in the end you'll get a full contract which you can then use as a template.

We'll create a Collection contract, which will allow us to:

- start a collection of any item
- add and take items from collection
- destroy collection
- offer collectibles to other users

For better understanding of this chapter I recommend you using Move IDE (which has already been presented in [getting started chapter](/introduction/getting-started.md)) and running all of these modules and scripts in it. It will also highlight possible errors and will automatically sync with standard library to verify that you're using correct methods and addresses.

Directory structure for your project would be:

```
modules/
    Collection.move
scripts/
    use_collection.move
.mvconfig.json
```

And recommended configuration in .mvconfig is:

```json
{
    "sender": "0x1",
    "network": "libra"
}
```
