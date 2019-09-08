# MATH introduce lists

Lists are a handy data structure to have.  We'd like to get to the point
in the message where we can make lists like this: `vector 1 4 5`,
`vector 77 $undefined (vector 1 2 3) 14`, etc.  But
`vector` can't be a function in the language we've described up to now,
it just can't work syntactically.
What we can do is make lists like this: `(list 3) 1 4 5`,
`(list 4) 77 $undefined ((list 3) 1 2 3) 14`, where we manually
specify how many values are in the list.
And then we can introduce a way to transform the syntax of the language,
so that `vector 1 4 5` gets rewritten to `(list 3) 1 4 5` prior to being
evaluated.

An alternative would be just to introduce some special new syntax for
lists, and give examples.  If the listener finds our transformation approach
confusing, they can simply ignore it and pick the message up again once
`vector` is in place.  But by giving the transformation, we offer a second
way to understand and experiment with the concepts being introduced.
