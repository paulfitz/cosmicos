
# GATE simulating unless gates
# for embedded image-and-logic-based primer

# practice with pure logic gate

# X unless Y = (X if Y=0, otherwise 0)
(intro unless);
(define unless | ? x | ? y | and $x | not $y);

# if second input is true, output is blocked (false)
# if second input is false, output copies first input
(= $false | unless $false $false);
(= $true | unless $true $false);
(= $false | unless $false $true);
(= $false | unless $true $true);


# To do: add a simple simulator for non-grid-based
# logic -- much simpler to understand than
# grid-based


# On to a grid-based logic simulation
# first, need unbounded, mutable matrices

(intro make-matrix);
(define make-matrix | ? default |
   make-cell | hash-default $default);

(intro matrix-set);
(define matrix-set | ? m | ? x | ? addr |
  set! $m | hash-add (get! $m) $addr $x);

(intro matrix-get);
(define matrix-get | ? m | ? addr |
  hash-ref (get! $m) $addr);

(define test-matrix | make-matrix 0);

(= 0 | matrix-get $test-matrix | vector 1 2 3);

(matrix-set $test-matrix 10 | vector 1 2 3);

(= 10 | matrix-get $test-matrix | vector 1 2 3);

# go through a circuit of unless gates and analyze data flow

(define unless-phase-1 | ? circuit |
  assign state (make-matrix $false) |
  begin
    (map 
     (? gate |
	assign x1 (list-ref $gate 0) |
	assign y1 (list-ref $gate 1) |
	assign x2 (list-ref $gate 2) |
	assign y2 (list-ref $gate 3) |
	assign v (list-ref $gate 4) |
	(if (= $x1 $x2)
	    (begin
	      (matrix-set $state $v | vector $x2 $y2 vert-value)
	      (matrix-set $state $true | vector $x2 $y2 vert-have)
	      (matrix-set $state $true | vector $x1 $y1 vert-want)
  	      $gate)
	    (begin
	      (matrix-set $state $v | vector $x2 $y2 horiz-value)
	      (matrix-set $state $true | vector $x2 $y2 horiz-have)
	      (matrix-set $state $true | vector $x1 $y1 horiz-want)
	      $gate)))
     $circuit)
    $state);

# move forward one simulation step

(define unless-phase-2 | ? circuit | ? state | map
   (? gate |
      assign x1 (list-ref $gate 0) |
      assign y1 (list-ref $gate 1) |
      assign x2 (list-ref $gate 2) |
      assign y2 (list-ref $gate 3) |
      assign v (list-ref $gate 4) |
      assign nv (if (= $x1 $x2)
		    (if (matrix-get $state | vector $x1 $y1 vert-have)
			(and (matrix-get $state | vector $x1 $y1 vert-value)
			     (not | and (matrix-get $state |
						   vector $x1 $y1 horiz-value)
				        (not  | matrix-get $state |
							vector $x1 $y1 horiz-want)))
			(if (matrix-get $state | vector $x1 $y1 horiz-have)
			    (matrix-get $state | vector $x1 $y1 horiz-value)
			    $true))
		    (if (matrix-get $state | vector $x1 $y1 horiz-have)
			(and (matrix-get $state | vector $x1 $y1 horiz-value)
			     (not | and (matrix-get $state |
						   vector $x1 $y1 vert-value)
				        (not | matrix-get $state |
							vector $x1 $y1 vert-want)))
			(if (matrix-get $state | vector $x1 $y1 vert-have)
			    (matrix-get $state | vector $x1 $y1 vert-value)
			    $true))) |
      vector $x1 $y1 $x2 $y2 $nv)
   $circuit);



# wrap up both phases of simulation

(intro simulate-unless);
(define simulate-unless | ? circuit |
  assign state (unless-phase-1 $circuit) |
  unless-phase-2 $circuit $state);


# A circuit is a list of gates
# Each gate is a list (x1 y1 x2 y2 v)
# where the coordinates (x1,y1) and (x2,y2) represent
# start and end points of a wire on a plane, carrying a 
# logic value v.
# Wires copy values from their start point.
#   |  
#   | (A)
#   V        
# -->-->
# (B)(C)
#
# Wire C here copies from wire B.
# If wire A is on, it blocks (sets to 0) C.

(assign circuit1
	(vector
	 (vector 2 2 4 2 $true)
	 (vector 4 2 6 2 $true)
	 (vector 6 2 8 2 $true)
	 (vector 6 4 6 2 $true)) |
	 assign circuit2
	 (vector
	  (vector 2 2 4 2 $true)
	  (vector 4 2 6 2 $true)
	  (vector 6 2 8 2 $false)
	  (vector 6 4 6 2 $true)) |
	  equal (simulate-unless $circuit1) $circuit2);

# okay, now let us make a simple image class
# we are going to encode each row as a single binary number,
# rather than a vector, so that images will be pretty
# obvious in the raw, uninterpreted message
# TODO: introduce div somewhere!

(intro bit-get);
(define bit-get | lambda (n offset) |
  assign div2 (div $n 2) |
  if (= 0 | offset) (not | = $n | * 2 $div2) |
  bit-get $div2 | - $offset 1);

(= 0 | bit-get (::.) 0);
(= 1 | bit-get (::.) 1);
(= 1 | bit-get (::.) 2);
(= 0 | bit-get (::.) 3);
(= 0 | bit-get (::.) 4);

(= 0 | bit-get 8 0);
(= 0 | bit-get 8 1);
(= 0 | bit-get 8 2);
(= 1 | bit-get 8 3);

(intro make-image);
(define make-image | lambda (h w lst) |
  vector $h $w $lst);

(intro image-get);
(define image-get | lambda (image row col) |
  assign h (list-ref $image 0) |
  assign w (list-ref $image 1) |
  assign lst (list-ref $image 2) |
  assign bits (list-ref $lst $row) |
  bit-get $bits | - (- $w $col) 1);

(intro image-height);
(define image-height | ? image |
  list-ref $image 0);

(intro image-width);
(define image-width | ? image |
  list-ref $image 1);

(define test-image | make-image 3 5 |
  vector (:....) (:...:) (:....));

(= 3 | image-height $test-image);
(= 5 | image-width $test-image);
(= $true | image-get $test-image 0 0);
(= $false | image-get $test-image 0 1);
(= $false | image-get $test-image 0 4);
(= $true | image-get $test-image 1 0);
(= $true | image-get $test-image 2 0);
(= $true | image-get $test-image 1 4);

# need a way to join two lists
# TODO: is this similar to "list-append" in NewType?

(define merge-list | ? lst1 | ? lst2 |
  if (= 0 | list-length $lst1) $lst2 |
  prepend (head $lst1) | merge-list (tail $lst1) $lst2);

(define merge-lists | ? lst |
   if (> (list-length $lst) 2)
      (merge-list (head $lst) (merge-lists | tail $lst))
      (if (= (list-length $lst) 2)
	  (merge-list (head $lst) | (head | tail $lst))
	  (if (= (list-length $lst) 1)
	      (head $lst)
	      (vector))));

(equal (vector 1 2 3 4) | merge-list (vector 1 2) (vector 3 4));

(equal (vector 1 2 3 4) | merge-lists (vector (vector 1 2) (vector 3) (vector 4)));

# helper for pairing

(define prefix | ? x | ? lst | map
  (? y (vector (x) (y)))
  $lst);

(equal (vector (vector 1 10) (vector 1 11))
       (prefix 1 | vector 10 11));

# need a way to take product of domains

(define pairing | ? lst1 | ? lst2 |
   if (= 0 | list-length $lst1) (vector) |
   merge-list (prefix (head $lst1) $lst2)
	      (pairing (tail $lst1) $lst2));

(equal (vector (vector 1 10) (vector 1 11) (vector 2 10) (vector 2 11)) |
   pairing (vector 1 2) (vector 10 11));

# need a way to make counting sets
# TODO: is this like range?

(define count | ? lo | ? hi |
  if (> $lo $hi) (vector) |
  prepend $lo | count (+ $lo 1) $hi);

(equal (vector 0 1 2 3 4) (count 0 4));

# given an image of a circuit, extract a model.
# wire elements are centered on multiples of 8

# individual element...

(define distill-element |
   ? image | ? xlogic | ? ylogic | ? xmid | ? ymid |
   if (not | image-get $image $ymid $xmid) (vector) |
   assign vert (image-get $image (+ $ymid 4) $xmid) |
   assign dx (if $vert 0 1) |
   assign dy (if $vert 1 0) |
   assign pos (image-get $image
                 (+ $ymid | + (* 4 $dy) (* 2 $dx))
                 (+ $xmid | - (* 4 $dx) (* 2 $dy))) |
   assign sgn (if $pos 1 (minus 1)) |
   assign dx (* $sgn $dx) |
   assign dy (* $sgn $dy) |
   assign active (image-get $image (+ $ymid $dx) (- $xmid $dy)) |
     vector | vector
       (- $xlogic $dx) 
       (- $ylogic $dy)
       (+ $xlogic $dx)
       (+ $ylogic $dy)
       $active);


# full circuit...

(intro distill-circuit);
(define distill-circuit | ? image |
  assign h (div (image-height $image) 8) |
  assign w (div (image-width $image) 8)  |
  merge-lists |
    map (? v |
	   assign xlogic (list-ref $v 0) |
	   assign ylogic (list-ref $v 1) |
	   assign xmid (* 8 $xlogic) |
	   assign ymid (* 8 $ylogic) |
	   distill-element $image $xlogic $ylogic $xmid $ymid)
	(pairing (count 1 (- $w 1))
		 (count 1 (- $h 1))));

