#!/usr/bin/env node

const cos = require('./cosmic');

cos.intro("proton:electron:mass:ratio");
cos.intro("proton:mass");
cos.intro("neutron:mass");
cos.intro("electron:mass");

cos.add("define float:= | ? x | ? y | within (frac (+ $x $y) 200000) $x $y");
cos.add("float:= $proton:mass | * $electron:mass | decimal 1836 | vector 1 5 2 6 7 3");
cos.add("float:= $electron:mass | * $proton:mass | decimal 0 | vector 0 0 0 5 4 4 6 1 7");
cos.add("float:= $neutron:mass | * $proton:mass | decimal 1 | vector 0 0 1 3 7 8 4 2");
