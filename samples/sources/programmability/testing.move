// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::testing {
    use std::string::String;

    use fun std::string::utf8 as vector.to_string;


    public struct Whoa {
        name: String
    }

    #[test]
    fun test_pack_unpack() {
        let Whoa { name: _ } = Whoa { name: b"hello".to_string() };
    }

}
