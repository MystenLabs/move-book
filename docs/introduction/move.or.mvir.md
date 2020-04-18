# Move or Mvir

If you've tried searching any information on Move language or if you have visited [developers.libra.org](https://developers.libra.org), you may have noticed that there're 2 languages right now: Move - the one from whitepaper and fancy news headlines, and Mvir (Move IR) - most documented and mentioned on libra's developers portal.

Why are there two languages? Do they compile/transpile into each other? Is Move IR a middle step between Move and bytecode? The short answer is no. However long answer will require some explanation - let's start with the facts:

1. There's only one VM (which is also called Move VM);
2. There're two compilers, hence two languages;

From what we've known from calibra team, Move IR is a "developer version" of Move which was created to speed up VM development while "the Move language" was being designed. Even though these two languages have different syntax - both compile into bytecode which is supported by Move VM.

You may be asking yourself "what should I choose?", well currently there's no correct answer to that. Move is Rust-like and simpler, Mvir is pretty hardcore when it comes to references and changes of values; both are supported by VM. According to [Libra's blog](https://developers.libra.org/blog/):

1. New syntax from latest blog posts [looks like Move](https://libra.org/en-US/blog/how-to-use-the-end-to-end-tests-framework-in-move/);
2. [In roadmap #2 retrospective](https://libra.org/en-US/blog/libra-core-roadmap-3/) Libra team marks Move IR as a tooling language and separates Move IR and Move language;

We can only suggest using Move as primary as in long perspective it's propably going to be "the Move". Though, as we've already mentioned, nobody can be sure at this point.

In this book you will only meet Move (with some remarks on Mvir and their difference), as I believe it is going to be the final Move language.
