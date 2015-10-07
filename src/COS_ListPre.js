var cos = require("./cosmic");
cos.language(2);
cos.seed(42);

function listVerbose(lst,wrap) {
    var result = [];
    if (!wrap) result = result.concat(-1);
    return result.concat([["list", lst.length]].concat(lst));
}

cos.section("illustrate lists and some list operators","MATH");
cos.comment("To make list describable as a function, need to preceed lists with an argument count. Lists keep an explicit record of their length. This is to avoid the need for using a special 'nil' symbol which cannot itself be placed in the list.");

cos.comment("pending: should introduce single? check function - but will be rewriting all this list stuff soon.");

cos.add("define list-helper | ? n | ? ret | if (> $n 1) (? x | list-helper (- $n 1) (? y | ? z | ret (+ 1 $y) (cons $x $z))) (? x | ret 1 $x)");

cos.add("define list | ? n | if (= $n 0) (cons 0 0) (list-helper $n (? y | ? z | cons $y $z))");

cos.add("define head | ? lst | if (= (car $lst) 0) $undefined (if (= (car $lst) 1) (cdr $lst) (car | cdr $lst))");

cos.add("define tail | ? lst | if (= (car $lst) 0) $undefined (if (= (car $lst) 1) (cons 0 0) (cons (- (car $lst) 1) (cdr | cdr $lst)))");

cos.add("define list-length | ? lst | car $lst");

cos.add("define list-ref | ? lst | ? n | if (= (list-ref $lst) 0) $undefined (if (= $n 0) (head $lst) (list-ref (tail $lst) (- $n 1)))");

cos.add("define prepend | ? x | ? lst | if (= (list-length $lst) 0) (cons 1 $x) (cons (+ (list-length $lst) 1) (cons $x (cdr $lst)))");

cos.add("define equal | ? x | ? y | if (= (single? $x) (single? $y)) (if (single? $x) (= $x $y) (list= $x $y)) $false");

cos.add("define list= | ? x | ? y | if (= (list-length $x) (list-length $y)) (if (> (list-length $x) 0) (and (equal (head $x) (head $y)) (list= (tail $x) (tail $y))) $true) $false");

var examples = cos.prand(10,5);

for (var i=0; i<examples.length; i++) {
    var r = examples[i];
    cos.add(["=", ["list-length", listVerbose(cos.prand(10,r))], r]);
}

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

for (var i=0; i<10; i++) {
    var len = cos.irand(10)+1;
    var lst = [];
    for (var j=0; j<len; j++) {
	lst.push(cos.irand(20));
    }
    var idx = cos.irand(len);
    var val = lst[idx];
    cos.add(["=",["list-ref",listVerbose(lst,true),idx],val]);
}

for (var i=0; i<5; i++) {
    var len = i;
    var lst = [];
    var cmp = "list=";
    for (var j=0; j<len; j++) {
	lst.push(cos.irand(20));
    }
    var idx = cos.irand(len);
    var val = lst[idx];
    cos.add([cmp,listVerbose(lst,true),listVerbose(lst,true)]);
}

cos.comment("this next batch of examples are a bit misleading, should streamline");
for (var i=0; i<5; i++) {
    var len = i;
    var lst = [];
    var cmp = "list=";
    for (var j=0; j<len; j++) {
	lst.push(cos.irand(20));
    }
    var idx = cos.irand(len);
    var val = lst[idx];
    cos.add(["not", [-1, cmp, listVerbose(lst,true), listVerbose([cos.irand(10)].concat(lst),true)]]);
    cos.add(["not", [-1, cmp, listVerbose(lst,true), listVerbose(lst.concat([cos.irand(10)]),true)]]);
}


cos.comment("some helpful functions");

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

cos.comment("this is a monster - simplify!");

cos.add("define list-find-helper | ? lst | ? key | ? fail | ? idx | if (= (list-length $lst) 0) (fail 0) (if (equal (head $lst) $key) $idx (list-find-helper (tail $lst) $key $fail (+ $idx 1)))");

cos.add("define list-find | ? lst | ? key | ? fail | list-find-helper $lst $key $fail 0");

cos.add("define example-fail | ? x 100");

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
	      val,
	      [-2, "example-fail"]],
	     idx2]);
}

for (var i=0; i<3; i++) {
    var lst = cos.prand(20,5+i*2);
    var head = lst[0];
    var tail = lst.slice(1);
    cos.add(["=",
	     ["list-find",
	      listVerbose(tail,true),
	      head,
	      [-2,"example-fail"]],
	     100]);
}
