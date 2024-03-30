# From Account to Object

While Move was created to manage digital assets, its initial storage model was bulky and not well-suited for many use cases. For instance, if Alice wanted to transfer an asset X to Bob, Bob had to create a new "empty" resource, and then Alice could transfer asset X to Bob. This process was not intuitive and presented implementation challenges, partly due to the restrictive design of Diem. Another drawback of the original design was the lack of built-in support for a "transfer" operation, requiring every module to implement its own storage transfer logic. Additionally, managing heterogeneous collections of assets in a single account was particularly challenging.

Sui addressed these challenges by redesigning the storage model to more closely resemble real-world object interactions. With a native concept of ownership and *transfer*, Alice can directly transfer asset X to Bob. Furthermore, Bob can maintain a collection of different assets without any preparatory steps. These improvements laid the foundation for the Object Model in Sui.

## Summary

- Move's initial storage model was not well-suited for managing digital assets, requiring complex and restrictive transfer operations.
- Sui introduced the Object Model, which provides a native concept of ownership, simplifying asset management and enabling heterogeneous collections.
