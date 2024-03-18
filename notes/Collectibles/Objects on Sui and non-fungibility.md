Sui Object Model and rich asset programmability implies that every object defined on the network has a unique ID and is non fungible. Formally put, every struct that has the `key` ability can be considered an NFT. If an object uses single owner model - we guarantee explicit ownership. If an object is shared (available to everyone), it can easily be patched with access-control.

It puts aside the definition of the technical standard, and allows standard-less development of any objects of any kind, giving developers full freedom and power to choose how assets can be programmed and interacted with.

However, the Object Model does not answer all of the questions. One of the most imporant ones is - what is the metadata standard. Rephrased - how do the ecosystem actors know how to represent an object off-chain. Keeping the technological differences in mind as well as aiming for a universal solution for Sui, we've created the "Sui Object Display", which not only covers the most common use case of Digital Collectibles but also serves to improve the Display-ability of all the objects on chain: be it a "MarketplaceManagerCapability" (an imaginary object that grants a bearer the ability to control a Marketplace) or an in-game item with special properties.

Simply described: any creator / builder on the network can customize Display for their objects, using all on-chain benefits of ownership and programmability. Not only the Display is kept on chain, it also supports versioning and every creator has the right to choose which fields to add to their objects. 

A set of recommended ones is:

- _name_ - a displayable name
- _link_ - a link to an object in an application / external link
- _description_ - a broader displayable description
- _image_url_ - an URL or a blob with an image
- _project_url_ - a link to a website
- _creator_ - mentions the creator 
- _category_ - a category of an object\*

\**caterogies are yet to be defined*
