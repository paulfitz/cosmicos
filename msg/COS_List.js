#!/usr/bin/env node

var cos = require("./cosmic");
cos.language(2);
cos.seed(42);

cos.comment("MATH some more list functions");
cos.intro("list:find");
cos.add(`
define list:find:0 | ? x:list | ? y | ? n |
  if (= (list-length $x:list) 0) $undefined |
  if (equal (head $x:list) $y) $n |
  list:find:0 (tail $x:list) $y (+ $n 1)`);

cos.add("define list:find | ? x:list | ? y | list:find:0 $x:list $y 0");

for (var i=0; i<10; i++) {
    var len = cos.irand(10)+1;
    var lst = [];
    for (var j=0; j<len; j++) {
	lst.push(cos.irand(20));
    }
    var idx = cos.irand(len);
    var val = lst[idx];
    var idx2 = -1;
    for (var j=0; j<len; j++) {
	if (lst[j] == val) {
	    if (idx2<0) {
		idx2 = j;
	    }
	}
    }
      
    cos.add(["=",
	     ["list:find",
	      cos.listVerbose(lst,true),
	      val],
	     idx2]);
}

for (var i=0; i<3; i++) {
    var lst = cos.prand(20,5+i*2);
    var head = lst[0];
    var tail = lst.slice(1);
    cos.add(["=",
	     ["list:find",
	      cos.listVerbose(tail,true),
	      head],
	     "$undefined"]);
}

cos.add("intro last");
cos.add("define last | ? x | list-ref $x | - (list-length $x) 1");
cos.add("intro except-last");
cos.add(`
define except-last | ? x |
  if (>= 1 | list-length $x) (vector) |
  prepend (head $x) | except-last | tail $x`);
cos.add("= 15 | last | vector 4 5 15");
cos.add("list= (vector 4 5) | except-last | vector 4 5 15");

cos.add(`intro list:reverse`);
cos.add(`define list:reverse | ? x:list |
  if (<= (list-length $x:list) 1) $x:list |
  prepend (last $x:list) | list:reverse | except-last $x:list`);

cos.add(`list= (list:reverse | vector 1 2 3) (vector 3 2 1)`);
cos.add(`list= (list:reverse | vector 50 1 33 99) (vector 99 33 1 50)`);

cos.intro("append");
cos.add(`define append | ? x | ? lst |
  if (= 0 | list-length $lst) (vector $x) |
  prepend (head | $lst) | append $x | tail $lst`);

cos.add(`list= (vector 1 2 5) | append 5 | vector 1 2`);
