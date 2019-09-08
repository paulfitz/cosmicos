# MATH introduce pairs

Now we introduce our first data structure.  The expression `cons X Y` stores `X` and `Y`
in a pair.  We can then pull `X` out from the pair with `car (cons X Y)`, and we can
get `Y` out from the pair with `cdr (cons X Y)`.  Apologies for the arcane names,
they are inherited from Lisp (and they'll be encoded as something else in the
message anyway).

We give a definition of `cons` that is a bit funky.  The `cons X Y` expression
constructs a function which takes a single argument, also a function.  That
argument gets called with `X` and `Y`.  That means to pull `X` back out, we
just need to call `cons X Y` with a function like `? a | ? b $a`.  Likewise for
`Y`.  That is exactly what `car` and `cdr` do.

Definitions like that can be a bit hard to think about.  But the great
thing is that you can apply definitions like these without initially
understanding them.  So if the listener wants to try them out, they
can; there's an element of interactivity beyond what a plain text
message could give.
