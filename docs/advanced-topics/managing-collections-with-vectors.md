# Managing collections with Vector

You're already familiar with the `struct` type which gives you the ability to create your own types and to store complex data. But sometimes you need something more dynamic, extensible and manageable. And for that Move has Vectors.

Vector is a built-in type for storing *collections* of data. It is a generic solution for collection of any type (but only one). As its functionality is given to you by the VM; the only way to work with it is by using the [Move standard library](https://github.com/diem/move/tree/main/language/move-stdlib/sources) and `native` functions.

```Move
script {
    use 0x1::Vector;

    fun main() {
        // use generics to create an emtpy vector
        let a = Vector::empty<u8>();
        let i = 0;

        // let's fill it with data
        while (i < 10) {
            Vector::push_back(&mut a, i);
            i = i + 1;
        };

        // now print vector length
        let a_len = Vector::length(&a);
        0x1::Debug::print<u64>(&a_len);

        // then remove 2 elements from it
        Vector::pop_back(&mut a);
        Vector::pop_back(&mut a);

        // and print length again
        let a_len = Vector::length(&a);
        0x1::Debug::print<u64>(&a_len);
    }
}
```

Vector can store up to `u64` number of values of a single non-reference type. To see how it helps managing huge storages let's write a module with it.

```Move
module Shelf {

    use 0x1::Vector;

    struct Box<T> {
        value: T
    }

    struct Shelf<T> {
        boxes: vector<Box<T>>
    }

    public fun create_box<T>(value: T): Box<T> {
        Box { value }
    }

    // this method will be inaccessible for non-copyable contents
    public fun value<T: copy>(box: &Box<T>): T {
        *&box.value
    }

    public fun create<T>(): Shelf<T> {
        Shelf {
            boxes: Vector::empty<Box<T>>()
        }
    }

    // box value is moved to the vector
    public fun put<T>(shelf: &mut Shelf<T>, box: Box<T>) {
        Vector::push_back<Box<T>>(&mut shelf.boxes, box);
    }

    public fun remove<T>(shelf: &mut Shelf<T>): Box<T> {
        Vector::pop_back<Box<T>>(&mut shelf.boxes)
    }

    public fun size<T>(shelf: &Shelf<T>): u64 {
        Vector::length<Box<T>>(&shelf.boxes)
    }
}
```

We'll create a shelf, few boxes for it and see how to work with vector in module:

```Move
script {
    use {{sender}}::Shelf;

    fun main() {

        // create shelf and 2 boxes of type u64
        let shelf = Shelf::create<u64>();
        let box_1 = Shelf::create_box<u64>(99);
        let box_2 = Shelf::create_box<u64>(999);

        // put both boxes to shelf
        Shelf::put(&mut shelf, box_1);
        Shelf::put(&mut shelf, box_2);

        // prints size - 2
        0x1::Debug::print<u64>(&Shelf::size<u64>(&shelf));

        // then take one from shelf (last one pushed)
        let take_back = Shelf::remove(&mut shelf);
        let value     = Shelf::value<u64>(&take_back);

        // verify that the box we took back is one with 999
        assert(value == 999, 1);

        // and print size again - 1
        0x1::Debug::print<u64>(&Shelf::size<u64>(&shelf));
    }
}
```

Vectors are very powerful. They allow you to store huge amounts of data (max length is *18446744073709551615*) and to work with it inside indexed storage.

### Hex and Bytestring literal for inline vector definitions

Vector is also *meant* to represent strings. VM supports way of passing `vector<u8>` as argument into `main` function in script.

But you can also use hexadecimal literal do define a `vector<u8>` in your script or a module:

```Move
script {

    use 0x1::Vector;

    // this is the way to accept arguments in main
    fun main(name: vector<u8>) {
        let _ = name;

        // and this is how you use literals
        // this is a "hello world" string!
        let str = x"68656c6c6f20776f726c64";

        // hex literal gives you vector<u8> as well
        Vector::length<u8>(&str);
    }
}
```

Simpler approach is to use bytestring literals:

```Move
script {

    fun main() {
        let _ = b"hello world";
    }
}
```

They are treated as ASCII strings and are also interpreted as `vector<u8>`.

### Vector cheatsheet

Here's a short cheatsheet for Vector methods from standard library:

- Create an empty vector of type `<E>`
```Move
Vector::empty<E>(): vector<E>;
```
- Get length of a vector
```Move
Vector::length<E>(v: &vector<E>): u64;
```
- Push element to the end of the vector:
```Move
Vector::push_back<E>(v: &mut vector<E>, e: E);
```
- Get mutable reference to element of vector. For immutable borrow use `Vector::borrow()`
```
Vector::borrow_mut<E>(v: &mut vector<E>, i: u64): &E;
```
- Pop an element from the end of vector:
```
Vector::pop_back<E>(v: &mut vector<E>): E;
```

Vector module in the Move standard library: [link](https://github.com/diem/move/blob/main/language/move-stdlib/sources/Vector.move)
