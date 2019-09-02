# MATH introduce non-unary representation of numbers

Switch from unary numbers to another representation.  The best representation
will depend on the details of how the message is being transmitted, and the
rest of the message doesn't depend on that choice for correctness (though the
choice will have implications for how easy the message will be to interpret).
As a base-line, imagine we use a binary representation.

It isn't important for the listener to understand, but it might be worth explaining
at this point how the unary representation worked.  In fact there's no special
syntax used, just three objects:

 * The number `0`.
 * The number `1`.
 * A function (called `unary` in English) that takes a value and:
   - If passed `0`, the function returns `0`
   - If passed `1`, the function returns another function, just like itself,
     except with any ultimate return value increased by `1`.

Using syntax defined later in the message, `unary` could be defined as:

```
@ unary-v | ? v | ? x | if (= $x 0) $v (unary-v | + $v 1);
@ unary | unary-v 0;
```

If you know Lisp/Scheme/etc, just read `@` as `define`, `?` as
`lambda`, and `|` as opening a parenthesis that gets closed at the end
of the statement.

Anyway, all of this is a digression, but it is worth knowing that as much as possible
the message is built from itself, so that in the end everything dovetails nicely.

