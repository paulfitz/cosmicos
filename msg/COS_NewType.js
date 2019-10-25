#!/usr/bin/env node

const cos = require('./cosmic');

cos.header('OBJECT', 'introduce simple form of typing, for ease of documentation.');

cos.doc(`
An object is simply a function that takes an argument.
The argument is the method to call on the object.
Types are here taken to be just the existence of a particular method,
with that method returning an object of the appropriate type.
`);

cos.add(`define make-integer | ? x | ? n |
  if (= $n int) $x 0`);

cos.add(`define objectify | ? x |
  if (function? $x) $x |
  make-integer $x`);

cos.doc('add version of lambda that allows types to be declared');
cos.add(`define translate | let ((prev $translate)) | ? x |
  if (not | function? $x) (prev $x) |
  if (not | = lambda | head $x) (prev $x) |
  let ((formals | head | tail $x)
       (body | head | tail | tail $x)) |
    if (= 0 | list-length $formals) (translate $body) |
    if (not | function? | last $formals)
      (translate | vector lambda (except-last $formals) (vector  ? (last $formals) $body)) |
      let ((formal-name | first | last $formals)
           (formal-type | second | last $formals)) |
        translate | vector
          lambda (except-last $formals) |
            vector ? $formal-name |
              vector let (vector (vector $formal-name (vector
                (vector objectify | vector $formal-name)
                $formal-type))) $body`);

cos.doc('add conditional form');
cos.intro("cond");
cos.add(`define translate | let ((prev $translate)) | ? x |
  if (not | function? $x) (prev $x) |
  if (not | = cond | head $x) (prev $x) |
  let ((cnd | head | tail $x)
       (rem | tail | tail $x)) |
    if (= 0 | list-length $rem) (translate $cnd) |
    translate (vector if (first $cnd) (second $cnd) (prepend cond $rem))`);

cos.add(`= 99 | cond 99`);
cos.add(`= 8 | cond ($true 8) 11`);
cos.add(`= 11 | cond ($false 8) 11`);
cos.add(`= 7 | cond ($false 3) ($true 7) 11`);
cos.add(`= 3 | cond ($true 3) ($true 7) 11`);
cos.add(`= 11 | cond ($false 3) ($false 7) 11`);

cos.add(`define remove-match | lambda (test lst) |
  if (= 0 | list-length $lst) $lst |
  if (test | head $lst) (remove-match $test (tail $lst)) |
  prepend (head $lst) (remove-match $test (tail $lst))`);

cos.add(`define remove-element | ? x |
  remove-match (? y | = $y $x)`);

cos.add(`list= (vector 1 2 3 5) | remove-element 4 | vector 1 2 3 4 5`);
cos.add(`list= (vector 1 2 3 5) | remove-element 4 | vector 1 4 2 4 3 4 5`);

cos.intro("instanceof");
cos.add(`define instanceof | ? T | ? t |
  if (not | function? $t) (= $T int) |
  function? | (objectify $t) $T`);

cos.add(`define return | ? T | ? t |
  let ((obj | objectify $t)) |
    obj $T`);

cos.add(`define tester | lambda ((x int) (y int)) |
  return int | + $x $y`);

cos.add(`instanceof int 10`);
cos.add(`= 42 | tester (make-integer 10) (make-integer 32)`);
cos.add(`= 42 | tester 10 32`);

cos.intro("reflective");
cos.add(`define reflective | ? f |
  (? x | f | ? y | (x $x) $y)
  (? x | f | ? y | (x $x) $y)`);

cos.add(`define woop | reflective | ? self | ? x | if (= $x 10) 22 (self 10)`);
cos.add(`= (woop 1) 22`);

cos.header('OBJECT', 'message passing / object example - a 2D point');

cos.intro("point");
cos.add(`define point | lambda (x y) | reflective |
  lambda (self msg) | cond
    ((= $msg x) $x)
    ((= $msg y) $y)
    ((= $msg point) $self)
    ((= $msg +) | lambda ((p point)) |
                    point (+ $x | p x) (+ $y | p y))
    ((= $msg =) | lambda ((p point)) |
                    and (= $x | p x) (= $y | p y))
    0`);

cos.add(`define point1 | point 1 11`);
cos.add(`define point2 | point 2 22`);
cos.add(`= 1 | point1 x`);
cos.add(`= 22 | point2 y`);
cos.add(`= 11 | (point 11 12) x`);
cos.add(`= 11 | ((point 11 12) point) x`);
cos.add(`= 16 | ((point 16 17) point) x`);
cos.add(`= 33 | (point1 + $point2) y`);
cos.add(`point1 + $point2 = | point 3 33`);
cos.add(`point2 + $point1 = | point 3 33`);
cos.add(`(point 100 200) + (point 200 100) = (point 300 300)`);

cos.add(`instanceof point $point1`);
cos.add(`not | instanceof int $point1`);
cos.add(`instanceof int 5`);
cos.add(`not | instanceof point 5`);

cos.header('OBJECT', 'message passing / object example - a container');

cos.intro("container");
cos.add(`define container | ? x | assign contents (make-cell | vector) | reflective |
  lambda (self msg) | cond
    ((= $msg container) $self)
    ((= $msg inventory) | get! $contents)
    ((= $msg add) | ? x | if (element $x | get! $contents) $false | 
                         set! $contents | prepend $x | get! $contents)
    ((= $msg remove) | ? x | set! $contents | remove-element $x | get! $contents)
    ((= $msg =) | lambda ((c container)) | set:= (self inventory) (c inventory))
    0`);

cos.add(`define pocket | container new`);
cos.add(`pocket add 77`);
cos.add(`pocket add 88`);
cos.add(`pocket add 99`);
cos.add(`set:= (pocket inventory) | vector 77 88 99`);
cos.add(`pocket remove 88`);
cos.add(`set:= (pocket inventory) | vector 77 99`);

cos.add(`define pocket2 | container new`);
cos.add(`pocket2 add 77`);
cos.add(`pocket2 add 99`);
cos.add(`pocket2 = $pocket`);

cos.doc('a sketch of inheritance - add one method to container (count)');

cos.add(`define counter-container | ? x | assign super (container new) | reflective |
  lambda (self msg) | cond
    ((= $msg counter-container) $self)
    ((= $msg count) | list-length | super inventory)
    (super $msg)`);

cos.add(`define cc1 | counter-container new`);
cos.add(`= 0 | cc1 count`);
cos.add(`cc1 add 4`);
cos.add(`= 1 | cc1 count`);
cos.add(`cc1 add 8`);
cos.add(`= 2 | cc1 count`);

cos.header('OBJECT', 'adding a special form for classes');

cos.intro("list-append");
cos.add(`define list-append | lambda (lst1 lst2) |
  if (= 0 | list-length $lst1) $lst2 |
  list-append (except-last $lst1) | prepend (last | $lst1) $lst2`);

cos.add(`list= (vector 1 2 3 4 5 6) | list-append (vector 1 2 3) (vector 4 5 6)`);

cos.add(`define select-match | lambda (test lst) |
  if (= 0 | list-length $lst) $lst |
  if (not | test | head $lst) (select-match $test | tail $lst) |
  prepend (head $lst) (select-match $test | tail $lst)`);

cos.add(`list= (vector 14 19 13) | select-match (? x | > $x 10) | vector 1 14 19 3 13 0 4`);

cos.add(`define unique | assign store (make-cell 0) | ? x |
  assign id (get! $store) |
  begin (set! $store (+ $id 1)) $id`);

cos.add(`= 0 | unique new`);
cos.add(`= 1 | unique new`);
cos.add(`= 2 | unique new`);
cos.add(`not | = (unique new) (unique new)`);

cos.add(`define setup-this | lambda (this self) | if (function? $this) $this $self`);

cos.add(`define standard-class-methods | ? name | quote @@ |
  ((= $method self) $self)
  ((= $method (@@ name)) (self self))
  ((= $method classname) (@@ name))
  ((= $method unknown) | ? x 0)
  ((= $method new) 0)
  ((= $method unique-id) $unique-id)
  ((= $method ==) | ? x | = $unique-id | x unique-id)
  (self unknown $method)`);

cos.add(`define custom-class-methods | lambda (name args fields) | list-append
  (map (? x | quote @@ | (= $method | @@ first $x) (@@ second $x))
       (map $tail | select-match (? x | = method | first $x) $fields))
  (map (? x | quote @@ | (= $method | @@ x) ((@@ x)))
       (map $second | select-match (? x | = field | first $x) $fields))`);

cos.add(`define class-cond | lambda (name args fields) | prepend cond | list-append
  (custom-class-methods $name $args $fields)
  (standard-class-methods $name)`);

cos.intro("class");
cos.add(`define translate | assign prev $translate | ? x |
  if (not | function? $x) (prev $x) |
  if (not | = class | head $x) (prev $x) |
  let ((name | list-ref $x 1)
       (args | list-ref $x 2)
       (fields | tail | tail | tail $x)) |
    translate | quote @@ |
      define (@@ name) | lambda (@@ prepend ext-this $args) |
        let (@@ append (vector unique-id | vector unique new)
                       (map $tail | select-match (? x | = field | first $x) $fields)) |
          let ((self | reflective | lambda (self) |
            let ((this | setup-this $ext-this $self)) |
              lambda (method) |
                 @@ class-cond $name $args $fields)) |
            begin (self new) $self`);

cos.add(`class point (x y)
  (method x $x)
  (method y $y)
  (method + | lambda ((p point)) | point new (+ $x | p x) (+ $y | p y))
  (method = | lambda ((p point)) | and (= $x | p x) (= $y | p y))`);

cos.add(`define point1 | point new 1 11`);
cos.add(`define point2 | point new 2 22`);

cos.add(`= 1 | point1 x`);
cos.add(`= 22 | point2 y`);
cos.add(`= 11 | (point new 11 12) x`);
cos.add(`= 11 | ((point new 11 12) point) x`);
cos.add(`= 16 | ((point new 16 17) point) x`);
cos.add(`= 33 | (point1 + $point2) y`);
cos.add(`point1 + $point2 = | point new 3 33`);
cos.add(`point2 + $point1 = | point new 3 33`);
cos.add(`(point new 100 200) + (point new 200 100) = (point new 300 300)`);

cos.add(`instanceof point $point1`);
cos.add(`not | instanceof int $point1`);
cos.add(`instanceof int 5`);
cos.add(`not | instanceof point 5`);

cos.header('OBJECT', 'wrapper class for cells');

cos.intro("cell");
cos.add(`class cell (initial-value)
  (field content | make-cell $initial-value)
  (method get | get! $content)
  (method set | ? new-value | set! $content $new-value)
  (method reset | self set $initial-value)
  (method unknown | ? x | (objectify | self get) $x)`);

cos.add(`define cell-test1 | cell new 15`);
cos.add(`= 15 | cell-test1 get`);
cos.add(`cell-test1 set 82`);
cos.add(`= 82 | cell-test1 get`);

cos.add(`= 82 | get! | cell-test1 content`);

cos.add(`define cell-test2 | cell new | point new 120 150`);
cos.add(`define cell-test3 | cell new | point new 300 300`);
cos.add(`cell-test2 + $cell-test3 = | point new 420 450`);
cos.add(`not | cell-test2 = $cell-test3`);
cos.add(`cell-test3 set $cell-test2`);
cos.add(`cell-test2 = $cell-test3`);

cos.header('MUD', 'playing around with doors and rooms');

cos.intro("door");
cos.add(`class door ((src room) (dest room))
  (method new | begin (src add $self) (dest add $self))
  (method access-from | lambda ((current room)) |
     cond ((current == $src) $dest) ((current == $dest) $src) 0)
  (method is-present | lambda ((current room)) |
     or (current == $src) (current == $dest))`);

cos.intro("room");
cos.add(`class room (name)
  (field content | container new)
  (method name $name)
  (method unknown | ? x | content $x)`);

cos.doc(`need to fix up containers to use object equality`);

cos.add(`define object-element | lambda (n lst) |
  < 0 | list-length | select-match (? x | x == $n) $lst`);

cos.add(`class container ()
  (field contents | cell new (vector))
  (method inventory | contents get)
  (method add | ? x |
     if (object-element $x | contents get) $false |
     contents set | prepend $x | contents get)`);

cos.add(`define hall | room new 0`);
cos.add(`define kitchen | room new 1`);
cos.add(`define door1 | door new $hall $kitchen`);

cos.add(`(first | hall inventory) == $door1`);
cos.add(`(first | kitchen inventory) == $door1`);
cos.add(`(door1 access-from $hall) == $kitchen`);
cos.add(`(door1 access-from $kitchen) == $hall`);

cos.add(`define stairs | room new 2`);
cos.add(`define lawn | room new 3`);
cos.add(`define bedroom | room new 4`);
cos.add(`define nowhere | room new 0`);
cos.add(`define door2 | door new $hall $lawn`);
cos.add(`define door3 | door new $hall $stairs`);
cos.add(`define door4 | door new $stairs $bedroom`);

cos.intro("character");
cos.add(`class character ()
  (field location | cell new 0)
  (field name | cell new 0)
  (method set-room | lambda ((r room)) | begin
     (if (not | function? | location get) 0 | location get remove $self)
     (r add $self)
     (location set $r))
  (method get-room | location get)
  (method set-name | ? n | name set $n)
  (method get-name | name get)
  (method update 0)`);

cos.add(`define find-max-helper | lambda (test max idx n lst) |
  if (= 0 | list-length $lst) $idx |
  if (> (test | head $lst) $max)
     (find-max-helper $test (test | head $lst) $n (+ $n 1) (tail $lst))
     (find-max-helper $test $max $idx (+ $n 1) (tail $lst))`);

cos.add(`define find-max-idx | lambda (test lst) |
  find-max-helper $test (test | head $lst) 0 0 $lst`);

cos.add(`define find-min-helper | lambda (test max idx n lst) |
  if (= 0 | list-length $lst) $idx |
  if (< (test | head $lst) $max)
     (find-min-helper $test (test | head $lst) $n (+ $n 1) (tail $lst))
     (find-min-helper $test $max $idx (+ $n 1) (tail $lst))`);

cos.add(`define find-min-idx | lambda (test lst) |
  find-min-helper $test (test | head $lst) 0 0 $lst`);

cos.add(`= 2 | find-max-idx (? x $x) | vector 3 4 5 0`);
cos.add(`= 1 | find-max-idx (? x $x) | vector 3 5 4 0`);
cos.add(`= 0 | find-max-idx (? x $x) | vector 5 3 4 0`);

cos.add(`= 2 | find-min-idx (? x $x) | vector 3 4 0 2`);
cos.add(`= 1 | find-min-idx (? x $x) | vector 3 1 4 2`);
cos.add(`= 0 | find-min-idx (? x $x) | vector 1 3 4 2`);

cos.doc(`the 'robo' class makes a character that patrols from room to room`);

cos.add(`class robo ()
  (field super | character new)
  (field timestamp | cell new 1)
  (field timestamp-map | cell new (? x 0))
  (method unknown | ? x | super $x)
  (method update |
     assign exits (select-match (? x | instanceof door $x) (self location inventory)) |
     assign timestamps (map (? x | timestamp-map get $x) $exits) |
     assign chosen-exit (list-ref $exits | find-min-idx (? x $x) $timestamps) |
     assign current-tmap (timestamp-map get) |
     assign current-t (timestamp get) |
     begin
       (self location set | chosen-exit access-from | self location get)
       (timestamp-map set | lambda ((d door)) |
          if (d == $chosen-exit) $current-t (current-tmap $d))
       (timestamp set | + 1 | timestamp get))`);

cos.add(`define myrobo | robo new`);

cos.add(`myrobo set-room $stairs`);

cos.add(`define which-room | lambda ((rr robo)) |
  find-max-idx
    (lambda ((r room)) | if (r == | rr get-room) 1 0) |
    vector $hall $kitchen $stairs $lawn $bedroom`);

cos.add(`define sequencer | lambda (n current lst) |
  if (>= $current $n) $lst | begin
    (myrobo update)
    (sequencer $n (+ $current 1) (append (which-room $myrobo) $lst))`);

cos.doc(`here is a list of the first 30 rooms the robot character visits`);
cos.doc(`0=hall, 1=kitchen, 2=stairs, 3=lawn, 4=bedroom`);

cos.add(`list= (sequencer 30 0 (vector)) |
  vector 4 2 0 3 0 1 0 2 4 2 0 3 0 1 0 2 4 2 0 3 0 1 0 2 4 2 0 3 0 1`);

cos.doc(`Now should start to introduce a language to talk about what is
going on in the simulated world, and start to move away from detailed mechanism`);
