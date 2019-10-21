#!/usr/bin/env node

const cos = require('./cosmic');

cos.header('MATH', 'quoting syntax');

cos.add(`define quote-f | ? key | ? x |
  if (not | function? $x) $x |
  if (= $key | list-ref $x 0) (tail $x) |
  prepend vector | map (quote-f $key) $x`);

cos.add(`= (quote-f x 1) 1`);
cos.add(`list= (quote-f x | vector 1) | vector vector 1`);
cos.add(`list= (quote-f x | vector 1 2 3) | vector vector 1 2 3`);
cos.add(`list= (quote-f x | vector 1 (vector 5 2) 3) | vector vector 1 (vector vector 5 2) 3`);
cos.add(`list= (quote-f x | vector 1 (vector 5 2) (vector x + 5 2)) | vector vector 1 (vector vector 5 2) (vector + 5 2)`);

cos.intro("quote");
cos.add(`define translate | assign prev $translate | ? x |
  if (not | function? $x) $x |
  if (not | = quote | head $x) (prev $x) |
  translate | quote-f (list-ref $x 1) (list-ref $x 2)`);

cos.add(`= (quote x 1) 1`);
cos.add(`list= (quote x | 1) | vector 1`);
cos.add(`list= (quote x | 1 2 3) | vector 1 2 3`);
cos.add(`list= (quote x | 1 (5 2) 3) | vector 1 (vector 5 2) 3`);
cos.add(`list= (quote x | 1 (5 2) (x + 5 2)) | vector 1 (vector 5 2) 7`);
