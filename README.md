CosmicOS
========

Sending the lambda calculus into deep space.  http://cosmicos.github.io/

[![Build Status](https://travis-ci.org/paulfitz/cosmicos.svg?branch=master)](https://travis-ci.org/paulfitz/cosmicos)

Long-distance relationships
----------------------------

It's a familiar problem. You've finally managed to contact that alien 
civilization. Things are going great. You feel like your world will 
never be the same, that whole new realms of possibilities are opening up 
before your eyes. Then, inevitably, a hint of strain starts to creep into 
your relationship. You find that you don't really have all that much in 
common. Heck, sometimes it feels like you're not even in the same 
galaxy. It's as if there is this vast gulf between you, making communication 
almost impossible. You're not even sure you'd understand each other no matter 
how physically close you become. What do you do?

You design a language for cosmic intercourse. Hans Freudenthal made a start at 
one in his book, Lincos, published in 1960. I think it's time for version II, 
the all-new action-packed sequel guaranteed to have you on the edge of your 
seat, which is a specific structure with a flat surface perpendicular to the 
pull of gravity, which is a thing that, oh never mind.

Building the message
--------------------

I recommend you use docker to build the message (if you don't want to, you can see
all the steps needed in `docker/Dockerfile`).

Install docker (see https://docs.docker.com/install/), then do:

```
./make.sh default
```

You should find the message saved in your `build/default` directory 
as `index.json` and `index.txt`.

There wil be a simple console for playing with Fritz in:
```
node ./build/default/bin/cosh.js
```

There is a tool for reading parts of the message in:
```
node ./build/default/bin/cosmsg.js
```

Message source code
-------------------

The CosmicOS message is assempled from a series of "chapters".
Each chapter is written in one of several languages, which are
then compiled into a standard language called "Fritz".  This
is a low-level language that is suitable for further conversion
into a number of forms.

Supported languages and how they are treated are:

    *.scm:  These files are incorporated into the
            message verbatim - they are written in Fritz.

    *.js:   These scripts are executed using node, and their
            output is incorporated into the message.

    *.pl:   These scripts are executed using perl, and their
            output is incorporated into the message.  CosmicOS
            is so old that quite a lot of its original source is
            in perl.  I can feel you judging me, please stop.

    *.java: These files are compiled to bytecode, and that
            bytecode is then converted into a form that
            can be incorporated into the message.  Not all
            Java constructs are supported - they are described
            in terms of Fritz in the message.

    *.gate: These files are interpreted as a specification
            for a kind of circuit.  You can find a simulator
            on the CosmicOS website.  The circuit specifications
            are converted into a form that can be incorporated
            into the message.

To add a source file or reorder existing material, edit `src/README.cmake`.

Variant messages
----------------

Perhaps you'd like to work on a somewhat different message without disturbing
the main message.  You can do that.  If you run the cmake user interface:
```
./build_with_docker.sh configure
```
You will see a `COSMIC_VARIANT` option that is currently set to `default`.
That tells the build to look for a message description starting at
`variant/default.cmake`.  You can add a different file in `variant` such as
`variant/my-version.cmake` and then set `COSMIC_VARIANT` to `my-version`.

Here are some existing options:

 * `COSMIC_VARIANT` set to `default` - this currently assumes that symbols like `$` and `|` can be
   somehow represented in the encoded message.
 * `COSMIC_VARIANT` set to `nested` - this converts the `$` and `|` symbols to parentheses.
 * `COSMIC_LINES` controls how many lines of the message are processed.  The default is 0, meaning
   unlimited.

Code quality
------------

Oh my goodness what can I say except <s>you're welcome</s> sorry.

License
-------

Copyright (C) 2018 Paul Fitzpatrick

CosmicOS is released under the GNU General Public Licence --
See COPYING.txt for license information.
