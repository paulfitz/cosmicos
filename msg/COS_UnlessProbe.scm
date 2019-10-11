
# GATE probing networks of unless gates

(define set-input | ? circuit | ? index | ? value |
  assign wire (list-ref $circuit $index) |
  map (? w | if (not | equal $w $wire) $w |
	     vector (list-ref $w 0)
	 	    (list-ref $w 1)
	            (list-ref $w 2)	
		    (list-ref $w 3)
		    $value)
      $circuit);

(define read-output | ? circuit | ? index |
  assign len (list-length $circuit) |
  assign wire (list-ref $circuit | - (- $len 1) $index) |
  list-ref $wire 4);

(define sim | ? circuit | ? steps | ? setter |
  if (= $steps 0) $circuit |
  sim (simulate-unless | setter $circuit) (- $steps 1) $setter);

(define smart-sim | ? circuit | ? setter |
  sim $circuit (list-length $circuit) $setter);


# test cos_not gate

(define cos_not_harness | ? x |
  assign c $cos_not_gate | 
  assign c (smart-sim $c | ? c | set-input $c 0 $x) |
  read-output $c 0);

(= $false | cos_not_harness $true);

(= $true | cos_not_harness $false);

# test cos_and gate

(define cos_and_harness | ? x | ? y |
  assign c $cos_and_gate | 
  assign c (smart-sim $c | ? c | set-input (set-input $c 0 $x) 1 $y) |
  read-output $c 0);

(= $false | cos_and_harness $false $false);
(= $false | cos_and_harness $false $true);
(= $false | cos_and_harness $true $false);
(= $true | cos_and_harness $true $true);

# this code is more awkward than it needs to be -
# should make circuits mutable
