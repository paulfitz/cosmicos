#!/usr/bin/env node

const cos = require('./cosmic');

cos.add(`define tape:tail | ? x |
  if (>= 1 | list-length $x) (vector | vector) |
  tail $x`);

cos.add(`define tape:head | ? x |
  if (= 0 | list-length $x) (vector) |
  head $x`);

cos.add(`define tape:get | ? tape | tape:head | second $tape`);

cos.add(`define tape:next | lambda (tape n x) |
  if (= $n 1) (pair (prepend $x | first $tape) (tape:tail | second $tape)) |
  if (= $n 0) (pair (tape:tail | first $tape) (prepend (tape:head | first $tape) (prepend $x (tape:tail | second $tape)))) |
  pair (first $tape) (prepend $x (tape:tail | second $tape))`);

cos.add(`define tape:do | lambda (x:function current end tape) |
  if (= $current $end) $tape |
  let ((next | x:function $current | tape:get $tape)) | 
    tape:do $x:function (list-ref $next 0) $end |
    tape:next $tape (list-ref $next 1) (list-ref $next 2)`);

cos.add(`define tape:make | ? x | pair (vector) $x`);

cos.add(`define tape:-:tail | ? x | ? x:list |
  if (= 0 | list-length $x:list) $x:list |
  if (not | equal $x | last $x:list) $x:list |
  tape:-:tail $x (except-last $x:list)`);

cos.add(`define tape:result | ? x | tape:-:tail (vector) (second $x)`);

cos.add(`define demo:tape:function:+:1 | make-hash | vector 
  (pair next (make-hash | vector
    (pair 0 (vector next 1 0))
    (pair 1 (vector next 1 1))
    (pair (vector) (vector +:1 0 (vector)))))
  (pair +:1 (make-hash | vector
    (pair 0 (vector not:+:1 0 1))
    (pair 1 (vector +:1 0 0))
    (pair (vector) (vector end 2 1))))
  (pair not:+:1 (make-hash | vector
    (pair 0 (vector not:+:1 0 0))
    (pair 1 (vector not:+:1 0 1))
    (pair (vector) (vector end 1 (vector)))))
  (pair end (make-hash | vector))`);

cos.add(`list= (vector 1 0 1 0) | tape:result |
  tape:do $demo:tape:function:+:1 next end (tape:make | vector 1 0 0 1)`);

cos.add(`list= (vector 1 0 0 0) | tape:result |
  tape:do $demo:tape:function:+:1 next end (tape:make | vector 1 1 1)`);

cos.add(`list= (vector 1 1 1 0 0 1 0 0 0) | tape:result |
  tape:do $demo:tape:function:+:1 next end (tape:make | vector 1 1 1 0 0 0 1 1 1)`);
