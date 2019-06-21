CosmicOS: a next-generation Contact message
===========================================

Communicating programs and simulations into deep space.  http://cosmicos.github.io/

[![Build Status](https://travis-ci.org/paulfitz/cosmicos.svg?branch=master)](https://travis-ci.org/paulfitz/cosmicos)

Communication through theater
-----------------------------

It's a familiar problem. You've finally managed to contact that alien 
civilization. Things are going great. You feel like your world will 
never be the same, that whole new realms of possibilities are opening up 
before your eyes. Then, inevitably, a hint of strain starts to creep into 
your relationship. You find that you don't really have all that much in 
common. Heck, sometimes it feels like you're not even in the same 
galaxy. It's as if there is this vast gulf between you, making communication 
almost impossible. You're not even sure you'd understand each other no matter 
how physically close you became. What do you do?

You design a language for cosmic intercourse. Hans Freudenthal made a start at 
one in his book, Lincos, published in 1960.

![Lincos](https://user-images.githubusercontent.com/118367/44816347-ff8f2d80-abaf-11e8-8066-4535e43f8b79.jpg)

One of the most interesting ideas in Lincos is to bootstrap up from
mathematics and logic to *conversations about* mathematics and logic
between imaginary characters __Ha__ and __Hb__, and from there to
statements about behavior of those characters.  That's a pretty rich universe
of shared ideas already.

In CosmicOS, we develop this idea of communicating through theater by
introducing a new topic of conversation: programs and simulations.
For example, if discussing logic circuits, we transmit a program for
simulating the circuits, so the listener isn't restricted to the
examples we show.  If discussing movement through space, we transmit a
simulation of a small adventure game, and show navigation from room to
room.  And so on.

Putting on a show
-----------------

Here's the idea behind CosmicOS:

 * Communicate the usual math and logic basics ...
 * ... then use that to show how to run programs ...
 * ... then send interesting programs that demonstrate behaviors and interactions ...
 * and start communicating ideas through theater and theater commentary.

This is inspired by Freudenthal's idea of staging written conversations between his imaginary characters __Ha__ and __Hb__.

What the message looks like
---------------------------

What would you like it to look like?  A string of numbers?

<pre>
20321001113223321001113023210101032032233210011130232101010321320322332100111302
32101010321321320322332100111302321010103213213213203223321001113023210101032132
13213213203223321001113023210101032132132132132132032233210011130232101010321321
32132132132132032233210011130232101010321321321321321321321320322332100111302321
01010321321321321321321321321320322332100111302321010103213213213213213213213213
21320322332100111302321010103213213213213213213213213213213203223321001113023210
...
</pre>

Some kind of spidery scrawl?

![spidery scrawl](https://user-images.githubusercontent.com/118367/44754717-fee39200-aaf0-11e8-8c5e-e7f3ba71e89b.png)

Vaguely understandable symbols?

<pre>
...
✉ ᚋ (+) | ✉ ᚌ 3 | ☯ 4 (ᚋ 1 (ᚌ))
☯ 2 | ✉ ᚋ 1 | + $ᚋ 1
☯ 1 | ✉ ᚋ 1 $ᚋ
☯ 14 | ✉ ᚋ 1 14
☯ 4 | ✉ ᚋ (✉ ᚌ 3 | + 1 $ᚌ) $ᚋ
☯ 4 | ✉ ᚋ (✉ ᚋ 3 | + 1 $ᚋ) $ᚋ
✉ ᚋ 1 | ☯ (ᚋ) 1
✉ ᚋ 1 | ☯ $ᚋ 1
...
</pre>

Logic gates?

![A D gate](https://user-images.githubusercontent.com/118367/44753787-4ff18700-aaed-11e8-8728-652006a3c447.gif)

Audio?  You can listen to one rendering of the message at https://cosmicos.github.io/

Building the message
--------------------


I recommend you use docker to build the message.
Install docker (see https://docs.docker.com/install/), then do:

```
./make.sh tiny
```

You should find a message saved as `build/tiny/index.txt` and
`build/tiny/index.json`.

There is a tool for browsing parts of the message in:
```
node ./build/tiny/bin/cosmsg.js
```

There will be a simple console for playing with Fritz in:
```
node ./build/tiny/bin/cosh.js
```

If you don't want to use docker, you can see all the steps needed in `docker/Dockerfile`
and `tools/make_without_docker.sh`.

By default, `./make.sh` will compile the message in json form.  There are specific targets
if you want other forms of the message.  Do `./make.sh help` to list all targets.

Message source code
-------------------

The CosmicOS message is assembled from a series of "chapters".  Each
chapter is written in one of several languages, which are then
compiled into a common language called `Fritz`.  This is a low-level
language that is suitable for further conversion into a number of
forms for transmission.

Supported languages and how they are treated are:

 * __*.scm__: These files are incorporated into the message verbatim.  They are written
   in a lisp-like language called Fritz.

 * __*.js__:  These scripts are executed using node, and their output is incorporated
   into the message.

 * __*.java__: These files are compiled to bytecode, and that bytecode is then converted
   into Fritz statements, using elements introduced in the message itself.  Not all
   Java constructs are supported, don't get carried away here.

 * __*.pl__: These scripts are executed using perl, and their output is incorporated into
   the message.  CosmicOS is so old that its original source is was written in perl, and
   some of it is still lying around.  I can feel you judging me, please stop.

 * __*.gate__: These files are interpreted as a specification for a kind of circuit.
   You can find a simulator on the CosmicOS website.  The circuit specifications
   are converted into a form that can be incorporated into the message.  Rules for
   evaluating a circuit are given in the message.

Fritz
-----

The core language of the message is a stripped-down Lisp called Fritz.  Here's an example statement:

```
= 42 (+ 20 22);
```

If you've coded in scheme or lisp, this should feel familiar, except we've stripped
a pair of parentheses around the whole expression, and added a semicolon.  In general,
Fritz takes every opportunity to reduce nesting, since it seems a cognitive burden.
The above would typically be written as:

```
= 42 | + 20 22;
```

The `|` means: nest everything from here to the end of the current expression.

We can define new symbols with `@ symbol value`, and create functions with `? symbol body`:
```
@ square | ? x | * (x) (x);
= 100 | square 10;
```

Note the parentheses in `* (x) (x)`, which multiplies an argument stored in x by itself.
To get the value of x, you evaluate it like an expression (this makes writing self-referential
messages so much easier).  A shorthand for `(x)` is `$x`, so the above can be written as:
```
@ square | ? x | * $x $x;
= 100 | square 10;
```

There's nothing special about symbols in Fritz, this code would work just as well
with `square` and `x` replaced by arbitrary integers:
```
@ 9999 | ? 88 | * $88 $88;
= 100 | 9999 10;
```

The message can be encoded in lots of ways.  Originally, CosmicOS was encoded
in a four-symbol message, with symbols corresponding to:

 * `0`: binary digit zero
 * `1`: binary digit one
 * `(`: open parenthesis
 * `)`: close parenthesis

Fritz messages can still be encoded this way by expanding out all references
to `|` and `$`, ignoring `;`s, and replacing symbols with arbitrary integers.
This does not seem very kind to the reader though, so other encodings are used
today.  There is a lot of scope for imaginative renderings of the same message.

Variant messages
----------------

Perhaps you'd like to work on a somewhat different message without disturbing
the main message.  You can do that.  Take a look in the `variant` directory.
Each file there defines a different message.  For example, `variant/tiny.cmake`
contains:

```
set(COSMIC_DEPENDS
  COS_Intro
  COS_Compare)
```

This means to build the message by concatenating `msg/COS_Intro.*` and `msg/COS_Compare.*`.
You can make your own file, `mine.cmake`, and then build it using:

```
./make.sh mine
```

You can optionally add this line:
```
set(COSMIC_USE_FLATTENER false)
```
If you think the `$` and `|` message symbols should be converted to parentheses in the message.

Code quality
------------

Oh my goodness what can I say except <s>you're welcome</s> sorry.

Chatter
-------

 * https://en.wikipedia.org/wiki/CosmicOS
 * https://www.theatlantic.com/science/archive/2016/04/math-language-extraterrestrials/477051/

License
-------

Copyright (C) 2018 Paul Fitzpatrick

CosmicOS is released under the GNU General Public Licence --
See COPYING.txt for license information.
