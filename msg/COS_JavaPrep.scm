
# JAVA some preparatory work for integrating with Java code

(class Object ()
   (method add-one | ? x | + $x 1)
   (method unknown | ? x $x)
   (method <init>-V $self)
   (method <init> $self)
   (method classname Object)
   (method equals-Object-Z | this ==)
   (method equals | self equals-Object-Z)
   (method act $true)
   (method isobj $true));

(define java-object $Object);

(define act | ? x $true);

# inconsistency of various kinds of equality throughout message
# needs to be cleaned up
(class Integer ()
   (field super | java-object new)
   (field value | cell new 0)
   (method <init> $self)
   (method <init>-V $self)
   (method <init>-I-V | ? v | begin (value set $v) $self)
   (method intValue-V | value get)
   (method intValue | self intValue-V)
   (method equals-Object-Z | ? o |
      if (not | = Integer | o classname) $false |
      = (value get) (o value get))
   (method equals | self equals-Object-Z)
   (method get | value get)
   (method set | ? x | value set | if (number? $x) $x | x intValue)
   (method classname Integer)
   (method unknown | ? x | super $x));


# string is basically the same as an integer
(class String ()
   (field super | java-object new)
   (field value | cell new 0)
   (method <init> $self)
   (method <init>-V $self)
   (method <init>-String-V | ? v | begin (value set | v value get) $self)
   (method int-init | ? x | begin (value set $x) $self)
   (method intValue-V | value get)
   (method intValue | self intValue-V)
   (method equals-Object-Z | ? o |
      if (not | = String | o classname) $false |
      = (value get) (o value get))
   (method equals | self equals-Object-Z)
   (method get | value get)
   (method set | ? x | value set | if (number? $x) $x | x intValue)
   (method classname String)
   (method unknown | ? x | super $x));

# will need to install class hierarchy, just hardcode a few things for now

(define java | ? x | ? y |
  cond ((= $y String) $String)
       ((= $y Object) $java-object)
       ((= $y Integer) $Integer)
       $java-object);
       
((java util String) new isobj);

(= ((java util String) new add-one 15) 16);

(class java-numeric ()
   (field super (java-object new))
   (method unknown | ? x | super $x)
   (field java-content | cell new 0)
   (method get | java-content get)
   (method init | ? v | begin (self set $v) $self)
   (method set | ? v | java-content set $v));
  

(define byte $java-numeric);
(define char $java-numeric);
(define double $java-numeric);
(define float $java-numeric);
(define int $java-numeric);
(define long $java-numeric);
(define short $java-numeric);
(define boolean $java-numeric);
(define void $java-numeric);

(define java-test1 | int new);

(java-test1 set 15);

(= 15 | java-test1 get);

(define java-test2 | int new init 17);

(= 17 | java-test2 get);


(define state-machine-test1 | ? x | cond
  ((= $x 1) 20)
  ((= $x 2) 40)
  ((= $x 3) 60)
  0);

(= 60 | state-machine-test1 3);


(define state-machine-test2 | ? x | cond
  ((= $x 1) | java-test1 set 20)
  ((= $x 2) | java-test1 set 40)
  ((= $x 3) | java-test1 set 60)
  0);

(state-machine-test2 2);

(= 40 | java-test1 get);

(define compare-object-reference | ? o1 | ? o2 |
   if (number? $o1) (number? $o2) |
   = (o1 unique-id) (o2 unique-id));

(define minus-one | minus 1);

(define jvm-maker | lambda (vars stack pc ret) | ? op | begin
   (pc set | + (pc get) 1) |
   cond
     ((= $op new) | ? type | stack-push $stack | $type new)
     ((= $op dup) | stack-push $stack | stack-peek $stack)
     ((= $op checkcast) | ? t 1)
     ((or (= $op astore) (= $op istore)) | ? index |
        vars set | hash-add (vars get) $index | stack-pop $stack)
     ((or (= $op aload) (= $op iload)) | ? index |
        stack-push $stack | hash-ref (vars get) $index)
     ((or (= $op iconst) (= $op ldc)) | ? val | stack-push $stack $val)
     ((= $op aconst_null) | stack-push $stack 0)
     ((= $op instanceof) | ? t |
        stack-push $stack | not | number? | (stack-pop $stack) (t new classname))
     ((= $op getfield) | ? key | ? ignore |
	stack-push $stack | (stack-pop $stack) $key get)
     ((= $op putfield) | ? key | ? ignore |
        assign val (stack-pop $stack) |
        (stack-pop $stack) $key set $val)
     ((= $op imul) |
        assign v2 (stack-pop $stack) |
        assign v1 (stack-pop $stack) |
        stack-push $stack | * $v1 $v2)
     ((= $op iadd) |
        assign v2 (stack-pop $stack) |
        assign v1 (stack-pop $stack) |
        stack-push $stack | + $v1 $v2)
     ((= $op isub) |
        assign v2 (stack-pop $stack) |
        assign v1 (stack-pop $stack) |
        stack-push $stack | - $v1 $v2)
     ((= $op goto) | ? x | pc set $x)
     ((= $op iflt) | ? x |
        if (< (stack-pop $stack) 0) (pc set $x) 0)
     ((= $op ifle) | ? x |
        if (<= (stack-pop $stack) 0) (pc set $x) 0)
     ((= $op ifgt) | ? x |
        if (> (stack-pop $stack) 0) (pc set $x) 0)
     ((= $op ifge) | ? x |
        if (>= (stack-pop $stack) 0) (pc set $x) 0)
     ((= $op ifne) | ? x |
        if (not | = (stack-pop $stack) 0) (pc set $x) 0)
     ((= $op ifeq) | ? x |
        if (= (stack-pop $stack) 0) (pc set $x) 0)
     ((= $op if_icmpne) | ? x |
        assign v2 (stack-pop $stack) |
        assign v1 (stack-pop $stack) |
        if (not | = $v1 $v2) (pc set $x) 0)
     ((= $op if_icmpeq) | ? x |
        assign v2 (stack-pop $stack) |
        assign v1 (stack-pop $stack) |
        if (= $v1 $v2) (pc set $x) 0)
     ((= $op if_acmpne) | ? x |
        assign v2 (stack-pop $stack) |
        assign v1 (stack-pop $stack) |
        if (not | compare-object-reference $v1 $v2) (pc set $x) 0)
     ((= $op if_acmpeq) | ? x |
        assign v2 (stack-pop $stack) |
        assign v1 (stack-pop $stack) |
        if (compare-object-reference $v1 $v2) (pc set $x) 0)
     ((= $op if_icmpge) | ? x |
        assign v2 (stack-pop $stack) |
        assign v1 (stack-pop $stack) |
        if (>= $v1 $v2) (pc set $x) 0)
     ((= $op if_icmpgt) | ? x |
        assign v2 (stack-pop $stack) |
        assign v1 (stack-pop $stack) |
        if (> $v1 $v2) (pc set $x) 0)
     ((= $op if_icmple) | ? x |
        assign v2 (stack-pop $stack) |
        assign v1 (stack-pop $stack) |
        if (<= $v1 $v2) (pc set $x) 0)
     ((= $op if_icmplt) | ? x |
        assign v2 (stack-pop $stack) |
        assign v1 (stack-pop $stack) |
        if (< $v1 $v2) (pc set $x) 0)
     ((= $op ifnull) | ? x |
	if (number? | stack-pop $stack) (pc set $x) 0)
     ((= $op ifnonnull) | ? x |
	if (not | number? | stack-pop $stack) (pc set $x) 0)
     ((= $op return) | begin
	(ret set | hash-ref (vars get) 0)
        (pc set $minus-one))
     ((= $op ireturn) | begin
	(ret set | stack-pop $stack)
        (pc set $minus-one))
     ((= $op areturn) | begin
	(ret set | stack-pop $stack)
        (pc set $minus-one))
     ((= $op invokevirtual) | lambda (target m n) |
         assign result (stack-call $stack $target $m) |
         if (not | = $n 1) 0 |
         stack-push $stack $result)
     ((= $op invokeinterface) | lambda (target m n ignore) |
         assign result (stack-call $stack $target $m) |
         if (not | = $n 1) 0 |
         stack-push $stack $result)
     ((= $op invokespecial) | lambda (target m n) |
         assign result (stack-call-special $stack (hash-ref (vars get) 0) $target $m) |
         if (not | = $n 1) 0 |
         stack-push $stack $result)
     0);

(define stack-call | lambda (stack target ct) |
  if (= $ct 0)
     ((stack-pop $stack) $target)
     (assign arg (stack-pop $stack) |
      (stack-call $stack $target (- $ct 1)) $arg));

(define stack-call-special |
  lambda (stack self target ct) |
    if (= (ct) 0)
	(let ((act | stack-pop $stack)) |
	   if (act == $self)
	      (act super $target)
	      (act $target))
	(let ((arg | stack-pop $stack)) |
	   (stack-call-special $stack $self $target (- $ct 1)) $arg));

(define stack-push | lambda (stack x) |
   stack set | prepend $x | stack get);

(define stack-pop | lambda (stack) |
   let ((v | head | stack get)) |
     begin
	(stack set | tail | stack get)
        $v);

(define stack-peek | lambda (stack) |
   head | stack get);

(define stack-test1 | cell new | vector 5 3 1);

(= (stack-pop $stack-test1) 5);

(= (stack-peek $stack-test1) 3);
	      
(= (stack-pop $stack-test1) 3);
	      
(stack-push $stack-test1 7);

(= (stack-pop $stack-test1) 7);

(define vars-test1 | cell new $hash-null);

(define pc-test1 | cell new 0);

(define ret-test1 | cell new 0);

(define test-jvm | jvm-maker $vars-test1 $stack-test1 $pc-test1 $ret-test1);

(stack-push $stack-test1 4);

(test-jvm dup);

(= (stack-pop $stack-test1) 4);

(= (stack-pop $stack-test1) 4);

(stack-push $stack-test1 66);

(stack-push $stack-test1 77);

(test-jvm astore 3);

(= (stack-pop $stack-test1) 66);

(test-jvm aload 3);

(= (stack-pop $stack-test1) 77);

(class test-class ()
   (field x | int new)
   (field y | int new));

(define test-this | test-class new);

(test-this x set 5);

(= (test-this x get) 5);

(stack-push $stack-test1 $test-this);

(= ((stack-pop $stack-test1) x get) 5);

(stack-push $stack-test1 $test-this);

(test-jvm astore 0);

(test-jvm aload 0);

(test-jvm getfield x $int);

(= (stack-pop $stack-test1) 5);

(test-jvm aload 0);

(test-jvm iconst 15);

(test-jvm putfield y $int);

(= (test-this y get) 15);

(stack-push $stack-test1 7);

(stack-push $stack-test1 10);

(test-jvm imul);

(test-jvm ireturn);

(= (ret-test1 get) 70);

(define state-machine-helper | ? at |
  lambda (vars stack machine) |
  let ((pc | cell new $at)
       (ret | cell new $true)) |
  let ((jvm | jvm-maker $vars $stack $pc $ret)) |
  begin
    (machine $jvm | pc get)
    (if (= (pc get) $minus-one) (ret get) |
      state-machine-helper (pc get) $vars $stack $machine));

(define state-machine | state-machine-helper 0);

(stack-push $stack-test1 10);

(stack-push $stack-test1 33);

(= 33 | state-machine $vars-test1 $stack-test1 | ? jvm | ? x |
  cond
    ((= $x 0) | jvm istore 4)
    ((= $x 1) | jvm iload 4)
    (jvm ireturn));

(stack-push $stack-test1 10);

(define bytecode-test-mul | lambda (arg0 arg1) |
  let ((vars | cell new | make-hash | vector (pair 0 0) (pair 1 $arg0) (pair 2 $arg1))
       (stack | cell new | vector)) |
  state-machine $vars $stack | ? jvm | ? x | cond
    ((= (x) 0) | jvm iload 1)
    ((= (x) 1) | jvm iload 2)
    ((= (x) 2) | jvm imul)
    ((= (x) 3) | jvm ireturn)
    (jvm return));

(= (bytecode-test-mul 5 9) 45);
