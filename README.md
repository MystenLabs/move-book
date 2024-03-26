# The Move Book

This is the repository for [the Move Book](https://move-book.com) and [Move Language Reference](https://move-book.com/reference).

## Structure

- Two books are placed in the `book` and `reference` directories. The `book` directory contains the main book, and the `reference` directory contains the reference book.

- The `theme` directory is linked to both books and contains the theme files, fonts and styles.

- The `packages` directory contains the code samples used in both books.

## Running the Books Locally

To run the books locally, you need to have [mdBook](https://rust-lang.github.io/mdBook/guide/installation.html) installed.

Then it's as simple as running the following commands:

```bash
$ mdbook serve book
$ mdbook serve reference
```

*The book will be available at `http://localhost:3000`.*

## Archive

For the archive of the old version of the book, see the `archive` branch.
