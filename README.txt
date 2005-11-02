
INTRODUCTION:

  Welcome to CosmicOS.

  Copyright (C) 2005 Paul Fitzpatrick, paulfitz@csail.mit.edu

  CosmicOS is released under the GNU General Public Licence --
  See COPYING.txt for license information.


DEPENDENCIES:

  CosmicOS was developed on a fairly typical linux system.
  It has not been tested in other environments, but if you
  are prepared to do some tweaking, it should work just fine.

  For full functionality, CosmicOS has some dependencies:
    MIT/GNU Scheme
    BCEL
    A java compiler and vm (e.g. kaffe)
    GD module for perl
    ImageMagick's convert tool

  Here are appropriate debian packages - see packages.debian.org for
  information that'll let you work out what you need for your system:

    apt-get install mit-scheme libbcel-java kaffe \
                    libgd-gd2-perl imagemagick


SOURCE CODE:

  CosmicOS arranges and compiles "lessons" into a complete,
  self-contained message.  Source code for the lessons is
  in the src directory.  Supported formats and how they
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


COMPILATION:

  To build the message, type:
    make
  The output appears in the msg directory.  The full compilation 
  procedure now performs message EXECUTION (next section) to 
  perform evaluations whose results are embedded in the message.
  Some parts of the message are quite slow to execute, so be patient.


EXECUTION:

  To test the message by executing it, type:
    make test
  Some parts of the message are quite slow to execute, so be patient.


VIEWING:

  To build web-pages and material related to viewing the message, type:
    make web
  The output appears in the www directory.
  You may need to run "make test" before this step (see "EXECUTION"), 
  since the latest results of testing are made available for viewing.

  To render the message in the form of glyphs, type:
    make icon
  Until you do this, there will be a broken link on www/index.html
  going to a page of the form "iconic-000000.html"

