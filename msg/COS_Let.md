# SYNTAX define let expressions

Sometimes it is nice to do a lot of assignments at once.
We introduce `let ((k1 v1) (k2 v2)) body` which is equivalent to
`assign k1 v1 | assign k2 v2 | body`.
