// ANCHOR: test
#[test_only]
module hello_world::hello_world_tests;

use std::unit_test::assert_eq;

use hello_world::hello_world;

#[test]
fun test_hello_world() {
    assert_eq!(hello_world::hello_world(), b"Hello, World!".to_string());
}
// ANCHOR_END: test