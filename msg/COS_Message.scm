
# SELF a mechanism for referring to parts of the message

# Many choices for how to do this.
# Could do it without special machinery by using the
# standard A-B trick for giving e.g. a Turing machine
# access to its own description.
# Instead, will simply introduce a "primer" function
# that gives access to every statement made so far
# (question: should future statements be included?
# tentatively assume YES: will simplify
# discussion of creating modified copies of the
# complete message).

# For now, assume primer is a list of statements,
# with each statement being a list in the same
# form as "translate" functions expect.
# This means that there is, for now, no
# distinction between unary or binary,
# and the "|" structure is expanded.

(intro primer);

# this line is referred to later - change/move carefully
(equal (list-ref $primer 0) | vector intro unary);
(equal (list-ref $primer 1) | vector intro is);
(equal (list-ref $primer 2) | vector intro int);
(equal (list-ref $primer 3) | vector is int | vector unary 0);
(equal (list-ref $primer 4) | vector is int | vector unary 1 0);
(assign idx (list:find $primer | vector intro primer) |
  equal (list-ref $primer | + $idx 1) |
    quote @@ | equal (list-ref $primer 0) | vector intro unary);

# Now, we could return to the MUD, simulate an agent A
# transferring a copy of the primer to another agent B,
# and then show B making a modified copy of that primer
# and passing it back to A.

# We could also show agents experimenting with the
# primer in various ways.
