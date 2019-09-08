# MATH introduce mutable cells

With `define`, we showed that there is a global memory, where we can associate a
symbol with a value.  That's nice, but it can be handy to separate memory from
naming.  In this section we introduce `make-cell X`, which creates a "cell"
of memory and puts `X` in it.  The cell can be read with `get!`, like
`get! | make-cell X`, or written to with `set!`, like `set! (make-cell-X) Y`.
