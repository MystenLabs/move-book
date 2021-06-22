address 0xB00C {    
module Library {
    struct Book {
        author: vector<u8>,
        title: vector<u8>,
        year: u64   
    }

    public fun issue(
        author: vector<u8>, 
        title: vector<u8>,
        year: u64
    ): Book {
        Book {
            author,
            title,
            year
        }
    }
}
}
