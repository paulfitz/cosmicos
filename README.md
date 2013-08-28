
CosmicOS
========

Sending the lambda calculus into deep space.

Copyright (C) 2013 Paul Fitzpatrick

CosmicOS is released under the GNU General Public Licence --
See COPYING.txt for license information.

CosmicOS was written back in 2005/2006 and is currently in a 
state of neglect.

Links
-----

 * http://cosmicos.sourceforge.net/
 * http://en.wikipedia.org/wiki/CosmicOS

Dependencies
------------

CosmicOS is a message that is put together from "chapters"
written as programs.  To compile those chapters, you currently
need:

 * MIT/GNU Scheme
 * BCEL
 * A java compiler and runtime
 * GD module for perl
 * ImageMagick's convert tool

Here are appropriate packages for Debian:

    apt-get install mit-scheme libbcel-java openjdk-6-jdk libgd-gd2-perl imagemagick


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
edit depend.txt and then type:

    make depend

Compilation
-----------

To build the message, type:

    make

The output appears in the msg directory.  The full compilation 
procedure now performs message EXECUTION (next section) to 
perform evaluations whose results are embedded in the message.
Some parts of the message are quite slow to execute, so be patient.

Execution
---------

To test the message by executing it, type:

    make test

Some parts of the message are quite slow to execute, so be patient.


Viewing
-------

To build web-pages and material related to viewing the message, type:

    make web

The output appears in the www directory.  You can view it by opening:
> www/index.html

You may need to run `make test` before this step, 
since the latest results of testing are made available for viewing.

To render the message in the form of glyphs, type:

    make icon

Until you do this, there will be a broken link on www/index.html
going to a page of the form "iconic-000000.html"

