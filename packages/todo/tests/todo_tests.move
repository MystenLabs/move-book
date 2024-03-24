#[test_only]
module todo::todo_tests {
    // uncomment this line to import the module
    use todo::todo;

    #[test]
    fun test_todo() {
        let ctx = &mut tx_context::dummy();
        let (mut list, cap) = todo::new(ctx);

        cap.add(&mut list, b"Clean the apartment".to_string());
        cap.add(&mut list, b"Buy groceries".to_string());

        assert!(list.length() == 2, 0);
        assert!(cap.remove(&mut list, 0) == b"Clean the apartment".to_string(), 0);
        assert!(list.length() == 1, 0);

        let guest = cap.invite(&list, ctx);

        guest.add(&mut list, b"Walk the dog".to_string());

        assert!(cap.remove(&mut list, 0) == b"Buy groceries".to_string(), 1);
        assert!(guest.remove(&mut list, 0) == b"Walk the dog".to_string(), 2);

        assert!(list.length() == 0, 3);

        guest.leave();
        list.delete(cap);
    }

    // #[test, expected_failure(abort_code = todo::todo_tests::ENotImplemented)]
    // fun test_todo_fail() {
    //     abort ENotImplemented
    // }
}
