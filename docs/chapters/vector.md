# Vector

Vector is a built-in (native) complex type for storing collection of values of one type.

## Rules

As usual - let's start with rules.

1. Vector is a native type (just like [primitives](/chapters/primitives.md)) which means you can use it in both modules and scripts;
2. Vector can only contain items of the same type. Which means you cannot store elements of type A and type B in the same vector;
3. Vector can have size from zero to 9,223,372,036,854,775,807 (max size of `u64`), it's called length;
4. Type of stored value is specified in generic: `vector<Element>`;
5. Since it's a native type, to use it you need standard library - usually `0x0::Vector`.

## Usage

As said above you can use it everywhere. In module:

```Move
module Countries {
    struct Country {
        name: vector<u8>
    }

    resource struct CountriesList {
        value: vector<Country>
    }
}

```

And in script!
```Move
script {

    use 0x0::Vector;

    fun vector_example() {
        let collection = Vector::empty<u8>();

        Vector::push_back<u8>(&mut collection, 10);
    }
}
```


In this example we've created an empty vector of `u8` integers and filled it with one value. Please note that vector creation within code is only possible via `0x0::Vector` library since this type is native.

## 0x0::Vector module

To manage collection properly we'd need to be able to get it's length, to access elements of this collection, and to modify its contents. All of this can be done with standard library (and only with standard library).

Here's a short list of methods available:

- Create an empty vector of type \<Element\>
```Move
Vector::empty<T>(): vector<T>;
```
- Get length of a vector
```Move
Vector::length<T>(v: &vector<T>): u64;
```
- Push element to the end of the vector:
```Move
Vector::push_back<T>(v: &mut vector<T>, e: T);
```
- Get mutable reference to element of vector. For immutable borrow use `Vector::borrow()`
```
Vector::borrow_mut<T>(v: &mut vector<T>, i: u64): &T;
```
- Pop an element from the end of vector:
```
Vector::pop_back<T>(v: &mut vector<T>): T;
```

This list is just enough to start working with vector, but to know full potential of vector you must see these standard libraries:

- Libra [libra/libra](https://github.com/libra/libra/blob/master/language/stdlib/modules/vector.move)
- Dfinance [dfinance/dvm](https://github.com/dfinance/dvm/blob/master/lang/stdlib/vector.move)

