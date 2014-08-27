#!/usr/bin/env node

var cos = require("./cosmic");

cos.language(2);

cos.section("introduce numbers (in unary notation)","MATH")
cos.comment("Here we count up from zero, go through some primes, etc. There is some syntax around the numbers, but that doesn't need to be understood at this point. We give numbers in a tweaked unary format, rather than the encoding used in the main body of the message.");
cos.add("intro is:int");
for (var i=0; i<16; i++) {
    var ones = "";
    for (var j=0; j<i; j++) {
	ones += " 1";
    }
    cos.add("is:int | unary" + ones + " 0");
}

cos.add("intro is:square");
for (var i=0; i<6; i++) {
    var ones = "";
    for (var j=0; j<i*i; j++) {
	ones += " 1";
    }
    cos.add("is:square | unary" + ones + " 0");
}

cos.add("intro is:prime");
var primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31];
for (var i=0; i<primes.length; i++) {
    var prime = primes[i];
    var ones = "";
    for (var j=0; j<prime; j++) {
	ones += " 1";
    }
    cos.add("is:prime | unary" + ones + " 0");
}

