# Pattern: Builder

The builder pattern is used to construct complex objects with many parameters in a flexible and
readable way. Instead of requiring all parameters upfront, a builder accumulates configuration
through method calls and produces the final object when `build()` is called. This pattern is
especially useful in testing, where you often need to create objects with slight variations while
keeping most fields at sensible defaults.

> In published code, builder pattern may introduce additional gas costs due to intermediate structs
> and multiple function calls. This pattern is best suited for tests where gas considerations are
> not a concern, and readability and maintainability are required.

## Defining a Builder

A builder struct mirrors the target object's fields but wraps them in `Option` types. This allows
each field to remain unset until explicitly configured. A typical builder provides:

- A `new()` function that creates an empty builder
- Setter methods that configure individual fields and return the builder for chaining
- A `build()` function that constructs the final object using defaults for unset fields

```move file=packages/samples/sources/testing/builder_pattern.move anchor=user

```

The corresponding builder:

```move file=packages/samples/sources/testing/builder_pattern_builder.move anchor=user_builder

```

Here, the `new()` function initializes all fields to `option::none()`, representing an
"unconfigured" state. Each setter method wraps the provided value in `option::some()` and stores it
in the corresponding field. The key to the pattern is the `build()` function, which uses the
`destroy_or!` macro to unwrap each `Option`: if a field was configured, its value is used;
otherwise, the macro returns the default value provided as the second argument. This approach lets
tests specify only the fields they care about while ensuring the final object is always fully
initialized.

## Example Usage

Without a builder, every test must specify all fields, even when only one field is relevant to the
test:

```move file=packages/samples/sources/testing/builder_pattern_builder.move anchor=test_without_builder

```

With a builder, tests become focused and self-documenting:

```move file=packages/samples/sources/testing/builder_pattern_builder.move anchor=test_with_builder

```

Each test clearly shows which field matters. Adding new fields to `User` only requires updating the
builder's `build()` function with a default - existing tests remain unchanged.

## Method Chaining

The key to fluent builder syntax is method chaining. Each setter method takes `mut self` by value,
modifies it, and returns the modified builder. Here's a very common example:

```move
public fun is_active(mut self: UserBuilder, is_active: bool): UserBuilder {
    self.is_active = option::some(is_active);
    self
}
```

Because the method takes ownership of `self` and returns `UserBuilder`, you can chain multiple calls
together:

```move
let user = user_builder::new()
    .name("Alice")
    .balance(1000)
    .is_active(true)
    .build();
```

Each method in the chain consumes the previous builder and returns a new one. The final `build()`
call consumes the builder and produces the target object.

## Usage in system packages

The Sui Framework and Sui System packages use builders extensively for testing. The most notable
examples are:

### ValidatorBuilder in Sui System

The [`ValidatorBuilder`][validator-builder] in the `sui-system` package demonstrates a comprehensive
builder for a complex type with many fields - cryptographic keys, network addresses, and economic
parameters:

```move
use sui_system::validator_builder;

#[test]
fun test_validator_operations() {
    let validator = validator_builder::preset()
        .name("My Validator")
        .gas_price(1000)
        .commission_rate(500) // 5%
        .initial_stake(100_000_000)
        .build(ctx);

    // test validator operations...
}
```

The `preset()` function returns a builder pre-filled with valid test defaults, so tests only
override the fields they care about.

### TxContextBuilder in Sui Framework

The [`TxContextBuilder`][tx-context-builder] allows customizing transaction context for specific
test scenarios:

```move
use sui::test_scenario as ts;

#[test]
fun test_epoch_dependent_logic() {
    let mut test = ts::begin(@0x1);
    let ctx = test
        .ctx_builder()
        .set_epoch(100)
        .set_epoch_timestamp(1000000)
        .build();

    // test logic that depends on epoch...

    test.end();
}
```

## Summary

- A builder accumulates configuration through setter methods and produces the final object via
  `build()`.
- Use `Option` fields to make configuration optional, with sensible defaults in `build()`.
- Method chaining (`fun method(mut self, ...): Self`) creates a fluent API.
- Builders reduce test boilerplate and isolate tests from changes to the target struct.
- Reserve this pattern for test utilities where readability matters more than gas costs.

[validator-builder]:
  https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-system/tests/builders/validator_builder.move
[tx-context-builder]:
  https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/test/test_scenario.move
