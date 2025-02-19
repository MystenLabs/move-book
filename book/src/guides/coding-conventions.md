# Coding Conventions

## Naming

### Module

1. Module names should be in `snake_case`.
2. Module names should be descriptive and should not be too long.

```move
module book::conventions { /* ... */ }
module book::common_practices { /* ... */ }
```

### Constant

1. Constants should be in `SCREAMING_SNAKE_CASE`.
2. Error constants should be in `EPascalCase`

```move
const MAX_PRICE: u64 = 1000;
const EInvalidInput: u64 = 0;
```

### Function

1. Function names should be in `snake_case`.
2. Function names should be descriptive.

```move
public fun add(a: u64, b: u64): u64 { a + b }
public fun create_if_not_exists() { /* ... */ }
```

### Struct

1. Struct names should be in `PascalCase`.
2. Struct fields should be in `snake_case`.
3. Capabilities should be suffixed with `Cap`.

```move
public struct Hero has key {
    id: UID
    value: u64,
    another_value: u64,
}

public struct AdminCap has key { id: UID }
```

### Struct Method

1. Struct methods should be in `snake_case`.
2. If there's multiple structs with the same method, the method should be prefixed with the struct
   name. In this case, an alias can be added to the method using `use fun`.

```move
public fun value(h: &Hero): u64 { h.value }

public use fun hero_health as Hero.health;
public fun hero_health(h: &Hero): u64 { h.another_value }

public use fun boar_health as Boar.health;
public fun boar_health(b: &Boar): u64 { b.another_value }
```
