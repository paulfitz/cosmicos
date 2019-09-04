# MATH show conditionals

Now that we spent some time looking at `true` and `false`, let's show
a way to build conditional expressions.  We start with an `if` expression,
of the form `if CONDITION E1 E2`, which evaluates to `E1` if the `CONDITION`
is `true`, otherwise `E2`.

If the listener is trying to map the language we are describing onto
their own system of computation, it is pretty important that `if` be
"lazy," and completely skip evaluating the branch not taken.  That
should become clear fairly soon if they were to try an "eager" `if`.
