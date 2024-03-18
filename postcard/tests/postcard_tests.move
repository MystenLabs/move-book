/*
#[test_only]
module postcard::hello_sui_tests {
    // uncomment this line to import the module
    // use hello_sui::hello_sui;

    const ENotImplemented: u64 = 0;

    #[test]
    fun test_hello_sui() {
        // pass
    }

    #[test, expected_failure(abort_code = hello_sui::hello_sui_tests::ENotImplemented)]
    fun test_hello_sui_fail() {
        abort ENotImplemented
    }
}
*/

module postcard::postcard_tests {
    use postcard::postcard;

    use fun std::string::utf8 as vector.to_string;

    #[test]
    /// A silly test - create a new PostCard and keep it.
    /// Then create another and send it to `sui` address.
    fun create_and_send() {
        let ctx = &mut tx_context::dummy();
        let card = postcard::new(b"Hello, Me!".to_string(), ctx);

        card.keep(ctx);

        let card = postcard::new(b"Hello, Sui!".to_string(), ctx);

        card.send_to(@0xa11ce);
    }
}
