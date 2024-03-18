# Generating Documentation

<!--

- Generating Docs
    - why docs are important
    - copy-paste the example
    - describe doc comments and what can be commented
    - show the output of the doc command
    - give a hint on how to set up the CIs
    - running --doc in `sui move test`


 -->

Move CLI has a built-in tool for generating documentation for Move modules. The tool is included into the binary and available out of the box. In this section we will learn how to generate documentation for our `hello_world` module.

## Adding documentation comments

To generate documentation for a module, we need to add documentation comments to the module and its functions. Documentation comments are written in Markdown and start with `///` (three slashes). For example, let's add a documentation comment to the `hello_world` module:

```Move
{{#include ../../samples/sources/your-first-move/hello_world_docs.move:4:4}}
{{#include ../../samples/sources/your-first-move/hello_world.move:4:4}}
```

Doc comments placed above the module are linked to the module itself, while doc comments placed above the function are linked to the function.

```Move
{{#include ../../samples/sources/your-first-move/hello_world_docs.move:8:11}}
```

If a documented member has an attribute, such as `#[test]` in the example below, the doc comment must be placed *after* the attribute:

> While it is possible to document `#[test]` functions, doc comments for tests will not be included in the generated documentation.

```Move
{{#include ../../samples/sources/your-first-move/hello_world_docs.move:13:20}}
```

## Generating documentation

To generate documentation for a module, we need to run the `sui move build` command with a `--doc` flag. Let's run the command:

```bash
$ sui move build --doc
...
...
BUILDING Book Samples
```

> Alternatively, you can use `move test --doc` - this can be useful if you want to test and generate documentation at the same time. For example, as a part of your CI/CD pipeline.

Once the build is complete, the documentation will be available in the `build/docs` directory. Each modile will have its own `.md` file. The documentation for the `hello_world` module will be available in the `build/docs/hello_world.md` file.

<details>
<summary><a style="cursor: pointer">Click to see an example of the `hello_world.md` contents</a></summary>

```move
<a name="0x0_hello_world"></a>

# Module `0x0::hello_world`
This module contains a function that returns a string "Hello, World!".
-  [Function `hello_world`](#0x0_hello_world_hello_world)
<pre><code><b>use</b> <a href="">0x1::debug</a>;
<b>use</b> <a href="">0x1::string</a>;
</code></pre>
<a name="0x0_hello_world_hello_world"></a>

## Function `hello_world`
As the name says: returns a string "Hello, World!".
<pre><code><b>fun</b> <a href="hello_world.md#0x0_hello_world">hello_world</a>(): <a href="_String">string::String</a>
</code></pre>
<details>
<summary>Implementation</summary>
<pre><code><b>fun</b> <a href="hello_world.md#0x0_hello_world">hello_world</a>(): String {
    <b>let</b> result = <a href="_utf8">string::utf8</a>(b"Hello, World!");
    <a href="_print">debug::print</a>(&result);
    result
}
</code></pre>
</details>
```
</details>
