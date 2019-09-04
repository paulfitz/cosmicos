# MATH demonstrate existence of memory

We've set up a way to name a value within an expression.  Now let's go beyond that,
and introduce a way to name a value in one sentence and use it in a later sentence.
In other words, a message-level memory.  After this, we'll be able to define new
symbols from existing ones, with less need for large numbers of examples.

We introduce a `define` symbol that works just like `assign`, except that it applies
to the rest of the message rather than the rest of the sentence.

A sentence of the form `define X Y` means that `$X` will evaluate to `Y` from that
point on (unless `X` is changed by another `define`).

The `meaning-of-life-universe-everything` symbol here is entirely arbitrary, and
won't be encoded as anything particularly meaningful in the message.
