#!/usr/bin/env node

const cos = require('./cosmic');

cos.header('MATH', 'show how to execute a sequence of instructions');

cos.add(`intro begin`);
cos.add(`define translate:begin:prev $translate`);
cos.add(`define translate | let ((prev $translate:begin:prev)) | ? x |
  if (not | function? $x) (prev $x) |
  if (not | = (head $x) begin) (prev $x) |
  translate | vector (vector ? x (vector last (vector x))) (prepend vector | tail $x)`);
cos.add(`= 4 | begin 1 7 2 4`);
cos.add(`= 6 | begin (set! $demo:make-cell:x 88) (set! $demo:make-cell:x 6) (get! $demo:make-cell:x)`);
cos.add(`= 88 | begin (set! $demo:make-cell:y 88) (set! $demo:make-cell:x 6) (get! $demo:make-cell:y)`);
cos.add(`= 4 | begin (set! $demo:make-cell:x 88) (set! $demo:make-cell:x 6) (get! $demo:make-cell:x) 4`);
