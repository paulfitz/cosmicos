# MATH introduce true and false

Now that we have functions, we could introduce some clever definitions of true, false,
and conditionals, where:

 * `if` is `? x | ? y | ? z | x $y $z;`
 * `true` is `? y | ? z | y;`
 * `false` is `? y | ? z | z;`
 
This is a neat implementation, but maybe a bit confusing.  So let's
not actually commit to a type for truth values in the message yet,
but just equate them with the results of equality `=`.

Once we have truth values, we can introduce conditionals and build up to fun stuff.

One slightly sneaky thing we do is to code `true` and `false` as `$1`
and `$0`.  This could be helpful, or confusing, I'm not sure.  Nothing
else in the message depends on this so it can be adjusted to taste.
