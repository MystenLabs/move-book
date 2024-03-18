// Copyright (c) Damir Shamanaev 2023
// Licensed under the MIT License - https://opensource.org/licenses/MIT

module book::my_module_with_members {
    // import
    use book::my_module;

    // friend declaration
    friend book::constants;

    // a constant
    const CONST: u8 = 0;

    // a struct
    public struct Struct {}

    // method alias
    public use fun function as Struct.struct_fun;

    // function
    fun function(_: &Struct) { /* function body */ }
}
