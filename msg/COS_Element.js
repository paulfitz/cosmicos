#!/usr/bin/env node

const cos = require('./cosmic');

cos.add("intro power:10");
cos.add(`define power:10 | ? n |
  if (= $n 0) 1 |
  assign part (if (>= $n 0) 10 (frac 1 10)) |
  reduce $* | map (? x $part) | range 0 (abs $n)`);

cos.add(`define float:= | ? x | ? y |
  if (= $x $y) $true |
  within (frac (+ $x $y) 200000) $x $y`);
cos.add(`float:= 10 | power:10 1`);
cos.add(`float:= 100 | power:10 2`);
cos.add(`float:= 1000 | power:10 3`);
cos.add(`float:= (frac 1 10) | power:10 | minus 1`);
cos.add(`float:= (frac 1 100) | power:10 | minus 2`);
cos.add(`float:= 1 | power:10 0`);

cos.add(`define decimal:power | ? x:power | ? x:int | ? x:list |
  * (power:10 $x:power) (decimal $x:int $x:list)`);

cos.add(`float:= 1530 | decimal:power 3 1 | vector 5 3`);
cos.add(`float:= 15300 | decimal:power 4 1 | vector 5 3`);
cos.add(`float:= (decimal 1 | vector 5 3) | decimal:power 0 1 | vector 5 3`);
cos.add(`float:= (decimal 0 | vector 0 0 1 5 3) | decimal:power (minus 3) 1 | vector 5 3`);

cos.intro("proton");
cos.intro("electron");
cos.intro("neutron");
cos.intro("mass");

cos.doc(`The following definitions are not included in the message, since they are
unit-specific.  The message will only present ratios.`);

cos.add(`assume | define proton | make-hash | vector
  (pair mass | decimal:power (minus 27) 1 | vector 6 7 2 6 1 9 2 3 6 9)
  (pair charge 1)`);

cos.add(`assume | define electron | make-hash | vector
  (pair mass | decimal:power (minus 31) 9 | vector 1 0 9 3 8 3 5 6)
  (pair charge | minus 1)`);

cos.add(`assume | define neutron | make-hash | vector
  (pair mass | decimal:power (minus 27) 1 | vector 6 7 4 9 2 7 4 7 1)
  (pair charge 0)`);

cos.add("float:= (proton mass) | * (electron mass) | decimal 1836 | vector 1 5 2 6 7 3");
cos.add("float:= (electron mass) | * (proton mass) | decimal 0 | vector 0 0 0 5 4 4 6 1 7");
cos.add("float:= (neutron mass) | * (proton mass) | decimal 1 | vector 0 0 1 3 7 8 4 2");

cos.add("float:= (proton charge) | * (electron charge) (minus 1)");
cos.add("float:= (neutron charge) 0");

cos.add(`define atom | ? x:proton | ? x:proton:neutron | make-hash | vector
  (pair proton $x:proton)
  (pair neutron | - $x:proton:neutron $x:proton)
  (pair electron $x:proton)`);

cos.add(`= ((atom 1 1) proton) 1`);
cos.add(`= ((atom 1 1) electron) 1`);
cos.add(`= ((atom 1 1) neutron) 0`);
cos.add(`= ((atom 1 2) proton) 1`);
cos.add(`= ((atom 1 2) electron) 1`);
cos.add(`= ((atom 1 2) neutron) 1`);

cos.add(`class elemental (proton isotope:list)
  (method proton $proton)
  (method isotope:list $isotope:list)
  (method electron $proton)
  (method neutron:list | map (? x | - $x $proton) $isotope:list)`);

cos.intro(`hydrogen`);
cos.intro(`helium`);
cos.intro(`carbon`);
cos.intro(`nitrogen`);
cos.intro(`oxygen`);
cos.add(`define hydrogen | elemental new 1 | vector 1 2`);
cos.add(`define helium | elemental new 2 | vector 2 4`);
cos.add(`define carbon | elemental new 6 | vector 12 13`);  // ignoring 14
cos.add(`define nitrogen | elemental new 7 | vector 14 15`);
cos.add(`define oxygen | elemental new 16 | vector 16 17 18`);

cos.add(`= (hydrogen proton) 1`);
cos.add(`= (hydrogen electron) 1`);
cos.add(`list= (hydrogen isotope:list) | vector 1 2`);
cos.add(`list= (hydrogen neutron:list) | vector 0 1`);

cos.add(`= (carbon proton) 6`);
cos.add(`= (carbon electron) 6`);
cos.add(`list= (carbon isotope:list) | vector 12 13`);
cos.add(`list= (carbon neutron:list) | vector 6 7`);

cos.add(`class molecule (elemental:list)
  (method elemental:list $elemental:list)
  (method count | lambda ((e elemental)) |
    list-length | select-match (? x | = (x proton) (e proton)) $elemental:list)`);

cos.intro('hydrogen:2');
cos.add(`define hydrogen:2 | molecule new | vector $hydrogen $hydrogen`);
cos.add(`= (hydrogen:2 count $hydrogen) 2`);
cos.add(`= (hydrogen:2 count $carbon) 0`);
cos.add(`= (hydrogen:2 count $nitrogen) 0`);
cos.add(`= (hydrogen:2 count $oxygen) 0`);
cos.intro('oxygen:2');
cos.add(`define oxygen:2 | molecule new | vector $oxygen $oxygen`);
cos.add(`= (oxygen:2 count $hydrogen) 0`);
cos.add(`= (oxygen:2 count $carbon) 0`);
cos.add(`= (oxygen:2 count $nitrogen) 0`);
cos.add(`= (oxygen:2 count $oxygen) 2`);
cos.intro('oxygen:3');
cos.add(`define oxygen:3 | molecule new | vector $oxygen $oxygen $oxygen`);
cos.add(`= (oxygen:3 count $hydrogen) 0`);
cos.add(`= (oxygen:3 count $carbon) 0`);
cos.add(`= (oxygen:3 count $nitrogen) 0`);
cos.add(`= (oxygen:3 count $oxygen) 3`);
cos.intro(`water`);
cos.add(`define water | molecule new | vector $hydrogen $hydrogen $oxygen`);
cos.add(`= (water count $hydrogen) 2`);
cos.add(`= (water count $carbon) 0`);
cos.add(`= (water count $nitrogen) 0`);
cos.add(`= (water count $oxygen) 1`);
cos.intro(`nitrogen:2`);
cos.add(`define nitrogen:2 | molecule new | vector $nitrogen $nitrogen`);
cos.add(`= (nitrogen:2 count $hydrogen) 0`);
cos.add(`= (nitrogen:2 count $carbon) 0`);
cos.add(`= (nitrogen:2 count $nitrogen) 2`);
cos.add(`= (nitrogen:2 count $oxygen) 0`);
cos.intro(`ammonia`);
cos.add(`define ammonia | molecule new | vector
  $nitrogen $hydrogen $hydrogen $hydrogen`);
cos.add(`= (ammonia count $hydrogen) 3`);
cos.add(`= (ammonia count $carbon) 0`);
cos.add(`= (ammonia count $nitrogen) 1`);
cos.add(`= (ammonia count $oxygen) 0`);
cos.intro(`methane`);
cos.add(`define methane | molecule new | vector
  $carbon $hydrogen $hydrogen $hydrogen $hydrogen`);
cos.add(`= (methane count $hydrogen) 4`);
cos.add(`= (methane count $carbon) 1`);
cos.add(`= (methane count $nitrogen) 0`);
cos.add(`= (methane count $oxygen) 0`);
cos.intro(`ethane`);
cos.add(`define ethane | molecule new | vector
  $hydrogen $hydrogen $hydrogen
  $carbon $carbon
  $hydrogen $hydrogen $hydrogen`);
cos.add(`= (ethane count $hydrogen) 6`);
cos.add(`= (ethane count $carbon) 2`);
cos.add(`= (ethane count $nitrogen) 0`);
cos.add(`= (ethane count $oxygen) 0`);
