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

Goals of CosmicOS
-----------------

 * To create a complete message which, if noticed by a non-human intelligence, stands some chance of being understood. The message should introduce the intelligence to a significant portion of the human world view.
 * To develop this message in a form that is easy to edit and extend, so that anyone interested can simply take it and make it better without having to track down out-of-print books.
 * To avoid making too many assumptions about the perceptual abilities of the non-human intelligence; for example that they make sense of 2D images in the same way we do. While some arguments can be made for this, as a machine vision guy I am very skeptical that we really understand the variability possible here.
 * To send Scheme into deep space.
 * To send the GPL into deep space.

The "intelligence" reading the message could be extra-terrestrial, or artificial. It is this second possibility that motivates me -- I want this message as a challenge for AI -- but the ET possibility is also fun.

Status
------

The current goal of development work on CosmicOS is to communicate enough structure to simulate a simple MUD (multi-user dungeon) and to use the interactions between locations, objects, and characters as an alternative to the clever "morality plays" in Lincos.

The message has a strong backbone of actual executable code. The results of executing code is fundamentally what gets talked about in most of the message so far. This has the advantage that it can be understood on two levels: working out what the code does by looking at its details, or just treating it as a black box and learning from examples what it does. It also gives the listener the ability to do experiments using the code that are not talked about in the message. At the level of the MUD, this means the listener is free to play around with the simulated world and understand its logic through experimentation.

A difficulty with using code is that it assumes the listener has a computer to run the code on, or is computer-like enough themselves to work through the code with excruciating patience. I'm okay with this assumption for now, since it is hard to imagine the message being detected in the first place without some good hardware.

Links
-----

 * http://cosmicos.sourceforge.net/
 * http://en.wikipedia.org/wiki/CosmicOS

Dependencies
------------

CosmicOS is a message that is put together from "chapters"
written as programs.  To compile those chapters, you currently
need:

 * A java compiler and runtime
 * perl, plus GD module for perl
 * BCEL
 * nodejs
 * haxe
 * CMake

Here are appropriate packages for Debian:

    apt-get install libbcel-java openjdk-6-jdk libgd-gd2-perl nodejs haxe cmake

If you end up with a version of haxe lower than 3, please uninstall and 
visit http://haxe.org/download/

Source code
-----------

CosmicOS arranges and compiles chapters into a complete,
self-contained message.  Source code for the chapters is
in the `src` directory.  Supported formats and how they
are treated are:


    *.scm:  These files are incorporated into the 
            message verbatim.

    *.pl:   Perl scripts are executed, and their output
            is incorporated into the message verbatim.

    *.java: These files are compiled to bytecode, and that
            bytecode is then converted into a form that
            can be incorporated into the message.  Not all
            Java constructs are supported, just enough for
            the message.

    *.gate: These files are interpreted as a specification
            for a kind of circuit.  The specifications
            are converted into a form that can be incorporated
            into the message.

If you wish to add a source file or reorder existing material,
edit index.txt in that directory.

Compilation
-----------

To build the message, type:

    mkdir build && cd build && cmake .. && make

You should find the message saved in your build directory 
as `index.json` and `index.txt`.

Compilation options
-------------------

There are options in how the message is built.  Run the cmake gui (`cmake-gui` or `ccmake` in Linux)
and look for options starting with `COSMIC_`.

 * `COSMIC_VARIANT` set to `default` - this currently assumes that symbols like `$` and `|` can be
   somehow represented in the encoded message.
 * `COSMIC_VARIANT` set to `nested` - this converts the `$` and `|` symbols to parentheses.
 * `COSMIC_LINES` controls how many lines of the message are processed.  The default is 0, meaning
   unlimited.

Troubleshooting
---------------
If you have compilation issues with `nodejs` similar to `node returned No such file or directory`, this can be resolved by symlinking it to `node`.  Another workaround is to install `nodejs-legacy`.

License
-------

Copyright (C) 2014 Paul Fitzpatrick

CosmicOS is released under the GNU General Public Licence --
See COPYING.txt for license information.

CosmicOS was started back in 2005/2006, neglected for a long time,
and is being hacked on again since early 2014.
