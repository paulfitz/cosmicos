var cos = require("./cosmic");
cos.language(2);
cos.seed(42);

function listVerbose(lst,wrap) {
    var result = [];
    if (!wrap) result = result.concat(-1);
    return result.concat([["list", lst.length]].concat(lst));
}

cos.add(`
define list-i | ? n | ? ret |
  if (= $n 1) (? x | ret 1 $x) |
  ? x | list-i (- $n 1) | ? y | ? z | ret (+ 1 $y) | cons $x $z`);

// (list 0)  =>  (cons 0 0)
// (list 1 x) => (cons 1 x)
// (list 2 x y) => (cons 2 (cons x y))

cos.add("define list | ? n | if (= $n 0) (cons 0 0) (list-i $n $cons)");

cos.add("intro undefined");
cos.add("= $undefined $undefined");
cos.add("not | = $undefined 0");
cos.add("not | = $undefined 1");
cos.add("not | = $undefined 2");

cos.add(`
define head | ? v |
  if (= 0 | car $v) $undefined |
  if (= 1 | car $v) (cdr $v) |
  car | cdr $v`);

cos.add(`
define tail | ? v |
  if (= 0 | car $v) $undefined |
  if (= 1 | car $v) (cons 0 0) |
  cons (- (car $v) 1) | cdr | cdr $v`);

for (var i=0; i<5; i++) {
    var len = cos.irand(10)+1;
    var lst = [];
    for (var j=0; j<len; j++) {
	lst.push(cos.irand(20));
    }
    var head = lst[0];
    cos.add(["=",head,[-1, "head", listVerbose(lst)]]);
}

for (var i=0; i<5; i++) {
    var len = cos.irand(9)+2;
    var lst = [];
    for (var j=0; j<len; j++) {
	lst.push(cos.irand(20));
    }
    cos.add(["=",lst[1],[-1, "head", "|", "tail", listVerbose(lst)]]);
}

for (var i=0; i<5; i++) {
    var len = cos.irand(8)+3;
    var lst = [];
    for (var j=0; j<len; j++) {
	lst.push(cos.irand(20));
    }
    cos.add(["=",lst[2],[-1, "head", "|", "tail", "|", "tail", listVerbose(lst)]]);
}

cos.add("define list-length $car");

var examples = cos.prand(10,5);

for (var i=0; i<examples.length; i++) {
    var r = examples[i];
    cos.add(["=", r, [-1, "list-length", listVerbose(cos.prand(10,r))]]);
}


cos.add(`
define list-ref | ? v | ? n |
  if (= 0 | car $v) $undefined |
  if (= $n 0) (head $v) |
  list-ref (tail $v) | - $n 1`);

for (var i=0; i<10; i++) {
    var len = cos.irand(10)+1;
    var lst = [];
    for (var j=0; j<len; j++) {
	lst.push(cos.irand(20));
    }
    var idx = cos.irand(len);
    var val = lst[idx];
    cos.add(["=",val, [-1, "list-ref",listVerbose(lst,true),idx]]);
}

cos.add("intro function?");
cos.add("function? | ? x 1");
cos.add("not | function? 1");
cos.add("not | function? | + 1 1");
cos.add("function? | ? y | + $y 2");
cos.add("function? $*");
cos.add("not | function? | = 1 2");

cos.add(`
define equal | ? x | ? y |
  if (not | = (function? $x) (function? $y)) $false |
  if (function? $x) (list= $x $y) (= $x $y)`);

cos.add(`
define list= | ? x | ? y |
  if (not | = (list-length $x) (list-length $y)) $false |
  if (= 0 | list-length $x) $true |
  if (not | equal (head $x) (head $y)) $false |
  list= (tail $x) (tail $y)`);

cos.add(`equal 1 1`);
cos.add(`equal ((list 2) 5 3) ((list 2) 5 3)`);
cos.add(`not | equal ((list 2) 5 3) ((list 3) 5 3 9)`);
cos.add(`not | equal ((list 2) 5 3) ((list 2) 5 4)`);
cos.add(`not | equal ((list 2) 5 3) ((list 2) 4 3)`);
cos.add(`not | equal ((list 2) 5 3) 12`);
cos.add(`equal ((list 3) 5 3 9) ((list 3) 5 3 9)`);
cos.add(`equal ((list 3) 5 ((list 2) 15 1) 9) ((list 3) 5 ((list 2) 15 1) 9)`);
cos.add(`not | equal ((list 3) 5 ((list 2) 15 1) 9) ((list 3) 5 ((list 2) 14 1) 9)`);
cos.add(`not | equal ((list 3) 5 3 9) ((list 3) 5 ((list 2) 14 1) 9)`);

for (var i=0; i<10; i++) {
    var len = cos.irand(10)+1;
    var lst = [];
    for (var j=0; j<len; j++) {
	lst.push(cos.irand(20));
    }
    var head = lst[0];
    var tail = lst.slice(1);
    cos.add(["=",["head", listVerbose(lst)],head]);
    cos.add(["list=",["tail", listVerbose(lst)],listVerbose(tail,true)]);
}

cos.add("intro prepend");

cos.add("define prepend | ? x | ? v | cons (+ (car $v) 1) | if (= (car $v) 0) $x | cons $x | cdr $v");

for (var i=0; i<8; i++) {
    var len = i;
    var lst = [];
    for (var j=0; j<len; j++) {
	lst.push(cos.irand(20));
    }
    var val = cos.irand(20);
    cos.add(["list=",
	     ["prepend", val, listVerbose(lst)],
	     listVerbose([val].concat(lst),true)]);
}


cos.add("define pair | ? x | ? y | (list 2) $x $y");
cos.add("define first | ? lst | head $lst");
cos.add("define second | ? lst | head | tail $lst");


var examples = cos.prand(10,3);
var examples2 = cos.prand(10,examples.length);
for (var i=0; i<examples.length; i++) {
    var r = examples[i];
    var r2 = examples2[i];
    cos.add(["list=",["pair",r,r2],listVerbose([r,r2])]);
    cos.add(["=",["first", [-1,"pair",r,r2]],r]);
    cos.add(["=",["second", [-1,"pair",r,r2]],r2]);
}

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
	      listVerbose(lst,true),
	      val],
	     idx2]);
}

for (var i=0; i<3; i++) {
    var lst = cos.prand(20,5+i*2);
    var head = lst[0];
    var tail = lst.slice(1);
    cos.add(["=",
	     ["list-find",
	      listVerbose(tail,true),
	      head],
	     "$undefined"]);
}
