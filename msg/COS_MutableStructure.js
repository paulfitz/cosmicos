#!/usr/bin/env node

const cos = require('./cosmic');

cos.header('OBJECT', 'introduce simple mutable structures');

cos.add(`define mutable-struct | ? x:list |
  let ((cell:list | map (? x | make-cell 0) $x:list)) |
  ? x:find | list-ref $cell:list | list:find $x:list $x:find`);

cos.add(`define demo:mutable-struct | mutable-struct | vector x:1 x:2 x:3`);
cos.add(`set! (demo:mutable-struct x:1) 15`);
cos.add(`= 15 | get! | demo:mutable-struct x:1`);
