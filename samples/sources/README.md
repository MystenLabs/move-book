# Managing Samples

For every page in the book (under the `src/` directory), there is a `samples/` directory which contains the code samples for that page. The `samples/` directory is organized in the same way as the `src/` directory, with the same directory structure and file names.

## Rules

1. There's one Move file per page in the book.
2. The file name is the same as the page name (or similar for keywords).
3. The file can hold multiple modules.
4. The modules are named after the sub-sections of the page.
5. Anchors should be used to point to the specific code snippets in the Move file.

## Example

For example, the `src/basic-syntax/address.md` page has a corresponding `samples/guides/address.move` file. The file contains the code samples for the page, organized in modules named after the sub-sections of the page.

```bash
samples/
    basic-syntax/
        address.move
```
