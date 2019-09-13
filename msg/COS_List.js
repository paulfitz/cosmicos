#!/usr/bin/env node

var cos = require("./cosmic");
cos.language(2);
cos.seed(42);

cos.comment("MATH some more list functions");
cos.add(`
define list-find-helper | ? lst | ? key | ? idx |
  if (= (list-length $lst) 0) $undefined |
  if (equal (head $lst) $key) $idx |
  list-find-helper (tail $lst) $key (+ $idx 1)`);

cos.add("define list-find | ? lst | ? key | list-find-helper $lst $key 0");

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
	     ["list-find",
	      cos.listVerbose(lst,true),
	      val],
	     idx2]);
}

for (var i=0; i<3; i++) {
    var lst = cos.prand(20,5+i*2);
    var head = lst[0];
    var tail = lst.slice(1);
    cos.add(["=",
	     ["list-find",
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
