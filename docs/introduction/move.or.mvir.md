# Move or Mvir

If you've tried searching any information on Move language or if you have visited [developers.diem.com](https://developers.diem.com), you may have noticed that there're 2 languages right now: Move - the one from whitepaper and fancy news headlines, and Mvir (Move IR) - most documented and mentioned on libra's developers portal.

Why are there two languages? Do they compile/transpile into each other? Is Move IR a middle step between Move and bytecode? The short answer is no. However long answer will require some explanation - let's start with the facts:

1. There's only one VM (which is also called Move VM);
2. There're two compilers, hence two languages;

From what we've known from Novi (ex Calibra) team, Move IR is a "developer version" of Move which was created to speed up VM development while "the Move language" was being designed. Even though these two languages have different syntax - both compile into bytecode which is supported by Move VM.

You may be asking yourself "what should I choose?", well currently there's no correct answer to that. Move is Rust-like and simpler, Mvir is pretty hardcore when it comes to references and changes of values; both are supported by VM. According to [Diem's blog](https://developers.diem.com/blog/):

1. In December member of Novi team wrote that [Move IR is a prototyping language](https://community.libra.org/t/on-move-and-ir/2260/2), and Move will be the main.
2. New syntax from latest blog posts [looks like Move](https://diem.org/en-US/blog/how-to-use-the-end-to-end-tests-framework-in-move/);
3. [In roadmap #2 retrospective](https://diem.org/en-US/blog/libra-core-roadmap-3/) Diem team marks Move IR as a tooling language and separates Move IR and Move language;
4. Move's standard library [is written in Move](https://github.com/diem/diem/tree/master/language/stdlib/modules) and is rapidly growing and developing;

In this book you will only meet Move as I believe it is going to be the final Move language.
