---
title: 'Labeled Control Flow | Reference'
description: ''
---

# Labeled Control Flow

Move supports labeled control flow when writing both loops and blocks of code, allowing you
to `break` and `continue` loops and `return` from blocks (which can be particularly helpful in the
presence of macros).

## Loops

Loops allow you to define and transfer control to specific labels in a function. For example, we can
nest two loops and use `break` and `continue` with those labels to precisely specify control flow.
You can prefix any `loop` or `while` form with a `'label:` form to allow breaking or continuing
directly there.

To demonstrate this behavior, consider a function that takes nested vectors of numbers (i.e.,
`vector<vector<u64>>`) to sum against some threshold, which behaves as follows:

- If the sum of all the numbers are under the threshold, return that sum.
- If adding a number to the current sum would surpass the threshold, return the current sum.

We can write this by iterating over the vector of vectors as nested loops and labelling the outer
one. If any addition in the inner loop would push us over the threshold, we can use `break` with the
outer label to escape both loops at once:

```move
fun sum_until_threshold(input: &vector<vector<u64>>, threshold: u64): u64 {
    let mut sum = 0;
    let mut i = 0;
    let input_size = input.length();

    'outer: loop {
        // breaks to outer since it is the closest enclosing loop
        if (i >= input_size) break sum;

        let vec = &input[i];
        let size = vec.length();
        let mut j = 0;

        while (j < size) {
            let v_entry = vec[j];
            if (sum + v_entry < threshold) {
                sum = sum + v_entry;
            } else {
                // the next element we saw would break the threshold,
                // so we return the current sum
                break 'outer sum
            };
            j = j + 1;
        };
        i = i + 1;
    }
}
```

These sorts of labels can also be used with a nested loop form, providing precise control in larger
bodies of code. For example, if we were processing a large table where each entry required iteration
that might see us continuing the inner or outer loop, we could express that code using labels:

```move
let x = 'outer: loop {
    ...
    'inner: while (cond) {
        ...
        if (cond0) { break 'outer value };
        ...
        if (cond1) { continue 'inner }
        else if (cond2) { continue 'outer }
        ...
    }
        ...
};
```

## Labeled Blocks

Labeled blocks allow you to write Move programs that contain intra-function non-local control flow,
including inside of macro lambdas and returning values:

```move
fun named_return(n: u64): vector<u8> {
    let x = 'a: {
        if (n % 2 == 0) {
            return 'a b"even"
        };
        b"odd"
    };
    x
}
```

In this simple example, the program checks if the input `n` is even. If it is, the program leaves
the block labeled `'a:` with the value `b"even"`. If not, the code continues, ending the block
labeled `'a:` with the value `b"odd"`. At the end, we set `x` to the value and then return it.

This control flow feature works across macro bodies as well. For example, suppose we wanted to write
a function to find the first even number in a vector, and that we have some macro `for_ref` that
iterates the vector elements in a loop:

```move
macro fun for_ref<$T>($vs: &vector<$T>, $f: |&$T|) {
    let vs = $vs;
    let mut i = 0;
    let end = vs.length();
    while (i < end) {
        $f(vs.borrow(i));
        i = i + 1;
    }
}
```

Using `for_ref` and a label, we can write a lambda expression to pass `for_ref` that will escape the
loop, returning the first even number it finds:

```move
fun find_first_even(vs: vector<u64>): Option<u64> {
    'result: {
        for_ref!(&vs, |n| if (*n % 2 == 0) { return 'result option::some(*n)});
        option::none()
    }
}
```

This function will iterate `vs` until it finds an even number, and return that (or return
`option::none()` if no even number exists). This makes named labels a powerful tool for interacting
with control flow macros such as `for!`, allowing you to customize iteration behavior in those
contexts.

## Restrictions

To clarify program behavior, you may only use `break` and `continue` with loop labels, while
`return` will only work with block labels. To this end, the following programs produce errors:

```move
fun bad_loop() {
    'name: loop {
        return 'name 5
            // ^^^^^ Invalid usage of 'return' with a loop block label
    }
}

fun bad_block() {
    'name: {
        continue 'name;
              // ^^^^^ Invalid usage of 'break' with a loop block label
        break 'name;
           // ^^^^^ Invalid usage of 'break' with a loop block label
    }
}
```
