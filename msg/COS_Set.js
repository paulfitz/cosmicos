#!/usr/bin/env node

const cos = require('./cosmic');

cos.seed(42);
cos.add('intro element');
cos.add('define element | ? x | ? y:list | not | = $undefined | list:find $y:list $x');

for (let i=0; i<5; i++) {
  const hset = new Map();
  const lst = [];
  for (let j=0; j<6; j++) {
    const x = cos.irand(10);
    if (!hset.has(x)) {
      hset.set(x, 1);
      lst.push(x);
    }
  }
  for (let j=0; j<3; j++) {
    const mem = lst[cos.irand(lst.length)];
    cos.add(`element ${mem} | ${cos.vector(lst)}`);
  }
}

for (let i=0; i<5; i++) {
  const hset = new Map();
  const lst = [];
  for (let j=0; j<6; j++) {
    const x = cos.irand(10);
    if (!hset.has(x)) {
      hset.set(x, 1);
      lst.push(x);
    }
  }
  const mem = lst.shift();
  cos.add(`not | element ${mem} | ${cos.vector(lst)}`);
}

cos.doc('Set some rules for set equality.');

cos.add(`define set:<= | ? x | ? y |
  if (= 0 | list-length $x) $true |
  and (element (head $x) $y) |
    set:<= (tail $x) $y`);

cos.add(`define set:= | ? x | ? y |
  and (set:<= $x $y) (set:<= $y $x)`);

cos.add(`set:= (vector 1 5 9) (vector 5 1 9)`);
cos.add(`set:= (vector 1 5 9) (vector 9 1 5)`);
cos.add(`not | set:= (vector 1 5 9) (vector 1 5)`)

cos.doc(`let's go leave ourselves wide open to Russell's paradox
  by using characteristic functions since it doesn't really matter
  within the bounds of this message`);

cos.add(`element 5 | all | ? x | = 15 | + $x 10`);
cos.add(`element 3 | all | ? x | = (* $x 3) (+ $x 6)`);

cos.add(`define set:0 | vector`);
cos.add(`element 0 $set:int:+`);
cos.add(`forall | ? x | => (element $x $set:int:+) (element (+ $x 1) $set:int:+)`);

for (let i=1; i<10; i++) {
  cos.add(`element ${i} $set:int:+`);
}

cos.add(`define set:true:false | vector $true $false`);
cos.add(`element $true $set:true:false`);
cos.add(`element $false $set:true:false`);

cos.add(`define set:even | all | ? x | exists | ? y |
  and (element $y $set:int:+) (= $x | * 2 $y)`);

for (let i=0; i<=6; i++) {
  cos.add(`element ${i} $set:int:+`)
  cos.add(`${(i % 2 === 0) ? '' : 'not | '}element ${i} $set:even`);
}
