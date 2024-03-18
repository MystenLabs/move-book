// Copyright (c) Damir Shamanaev 2023
// Licensed under the MIT License - https://opensource.org/licenses/MIT

#[allow(unused_function, unused_variable)]
module book::comments_line_2 {
    // let's add a note to everything!
    fun some_function_with_numbers() {
        let a = 10;
        // let b = 10 this line is commented and won't be executed
        let b = 5; // here comment is placed after code
        a + b; // result is 15, not 10!
    }
}
