
# JAVA some preparatory work for integrating with Java code

(class Object ()
       (method add-one (lambda (x) (+ (x) 1)))
       (method unknown (lambda (x) (x)))
       (method <init>-V (self))
       (method <init> (self))
       (method classname Object)
       (method equals-Object-Z (this ==))
       (method equals (self equals-Object-Z))
       (method act (true))
       (method isobj (true)));

(define java-object / Object);

(define act / ? x / true);

#(class java-string ()
#       (field super (java-object new))
#       (method classname String)
#       (method unknown (lambda (x) (super (x)))));

# inconsistency of various kinds of equality throughout message
# needs to be cleaned up
(class Integer ()
       (field super (java-object new))
       (field value (cell new 0))
       (method <init> (self))
       (method <init>-V (self))
       (method <init>-I-V (lambda (v) 
			    (begin 
			      (value set (v))
			      (self))))
       (method intValue-V (value get))
       (method intValue (self intValue-V))
       (method equals-Object-Z (lambda (o) (if (= (o classname) Integer)
					       (= (value get) (o value get))
					       (false))))
       (method equals (self equals-Object-Z))
       (method get (value get))
       (method set (lambda(x)
		     (value set
			    (if (number? / x)
				(x)
				(x intValue)))))
       (method classname Integer)
       (method unknown (lambda (x) (super (x)))));


# string is basically the same as an integer
(class String ()
       (field super (java-object new))
       (field value (cell new 0))
       (method <init> (self))
       (method <init>-V (self))
       (method <init>-String-V (lambda (v) 
				 (begin 
				   (value set (v value get))
				   (self))))
       (method int-init (lambda (x) 
			  (begin 
			    (value set (x))
			    (self))))
       (method intValue-V (value get))
       (method intValue (self intValue-V))
       (method get (value get))
       (method set (lambda(x)
		     (value set
			    (if (number? / x)
				(x)
				(x intValue)))))
       (method equals-Object-Z (lambda (o) (if (= (o classname) String)
					       (= (value get) (o value get))
					       (false))))
       (method equals (self equals-Object-Z))
       (method classname String)
       (method unknown (lambda (x) (super (x)))));


# will need to install class hierarchy, just hardcode a few things for now

(define java
  (? x / ? y 
     (cond ((= (y) String) (String))
	   ((= (y) Object) (java-object))
	   ((= (y) Integer) (Integer))
	   (java-object))));
       
((java util String) new isobj);

(= ((java util String) new add-one 15) 16);

(class java-numeric ()
       (field super (java-object new))
       (method unknown (lambda (x) (super (x))))
       (field java-content (cell new 0))
       (method get (java-content get))
       (method init (lambda (v)
		      (begin
			(self set (v))
			(self))))
       (method set (lambda (v) (java-content set (v)))));
  

(define byte (java-numeric));
(define char (java-numeric));
(define double (java-numeric));
(define float (java-numeric));
(define int (java-numeric));
(define long (java-numeric));
(define short (java-numeric));
(define boolean (java-numeric));
(define void (java-numeric));

(define java-test1 (int new));

(java-test1 set 15);

(= 15 (java-test1 get));

(define java-test2 (int new init 17));

(= 17 (java-test2 get));


(define state-machine-test1
  (? x
     (cond ((= (x) 1) 20)
	   ((= (x) 2) 40)
	   ((= (x) 3) 60)
	   0)));

(= (state-machine-test1 3) 60);



# really ought to go back and be clear about eager/laziness issues
(define state-machine-test2
  (? x
     (cond ((= (x) 1) (java-test1 set 20))
	   ((= (x) 2) (java-test1 set 40))
	   ((= (x) 3) (java-test1 set 60))
	   0)));

(state-machine-test2 2);

(= (java-test1 get) 40);

(define compare-object-reference
  (lambda (o1 o2)
    (if (number? / o1)
	(number? / o2)
	(= (o1 unique-id) (o2 unique-id)))));

(define jvm-maker
  (lambda (vars stack pc ret)
    (? op
     (begin
       (pc set (+ (pc get) 1)) /
     cond ((= (op) new)
	    (lambda (type)
	      (stack-push (stack) ((type) new))))
	   ((= (op) dup)
	    (stack-push (stack) (stack-peek (stack))))
	   ((= (op) checkcast)
	    (lambda (t)
	      1))
	   ((or (= (op) astore) (= (op) istore))
	    (lambda (index)
	      (vars set (hash-add (vars get) (index) (stack-pop (stack))))))
	   ((or (= (op) aload) (= (op) iload))
	    (lambda (index)
	      (stack-push (stack) (hash-ref (vars get) (index)))))
	   ((or (= (op) iconst) (= (op) ldc))
	    (lambda (val)
	      (stack-push (stack) (val))))
	   ((= (op) aconst_null)
	    (stack-push (stack) 0))
	   ((= (op) instanceof)
	    (lambda (t)
	      (stack-push 
	       (stack)
	       (not / number? / (stack-pop / stack) (t new classname)))))
	   ((= (op) getfield)
	    (lambda (key ignore)
	      (stack-push (stack) ((stack-pop (stack)) (key) get))))
	   ((= (op) putfield)
	    (lambda (key ignore)
	      (let ((val (stack-pop (stack))))
		((stack-pop (stack)) (key) set (val)))))
	   ((= (op) imul)
	    (let ((v2 (stack-pop (stack))))
	      (let ((v1 (stack-pop (stack))))
		(stack-push (stack)
			    (* (v1) (v2))))))
	   ((= (op) iadd)
	    (let ((v2 (stack-pop (stack))))
	      (let ((v1 (stack-pop (stack))))
		(stack-push (stack)
			    (+ (v1) (v2))))))
	   ((= (op) isub)
	    (let ((v2 (stack-pop (stack))))
	      (let ((v1 (stack-pop (stack))))
		(stack-push (stack)
			    (- (v1) (v2))))))
	   ((= (op) goto)
	    (lambda (x)
	      (pc set (x))))
	   ((= (op) iflt)
	    (lambda (x)
	      (if (< (stack-pop (stack)) 0)
		  (pc set (x))
		  0)))
	   ((= (op) ifle)
	    (lambda (x)
	      (if (< (stack-pop (stack)) 1)
		  (pc set (x))
		  0)))
	   ((= (op) ifgt)
	    (lambda (x)
	      (if (> (stack-pop (stack)) 0)
		  (pc set (x))
		  0)))
	   ((= (op) ifge)
	    (lambda (x)
	      (if (>= (stack-pop (stack)) 0)
		  (pc set (x))
		  0)))
	   ((= (op) ifne)
	    (lambda (x)
	      (if (not (= (stack-pop (stack)) 0))
		  (pc set (x))
		  0)))
	   ((= (op) ifeq)
	    (lambda (x)
	      (if (= (stack-pop (stack)) 0)
		  (pc set (x))
		  0)))
	   ((= (op) if_icmpne)
	    (let ((v2 (stack-pop (stack))))
	      (let ((v1 (stack-pop (stack))))
		(lambda (x)
		  (if (not (= (v1) (v2)))
		      (pc set (x))
		      0)))))
	   ((= (op) if_icmpeq)
	    (let ((v2 (stack-pop (stack))))
	      (let ((v1 (stack-pop (stack))))
		(lambda (x)
		  (if (= (v1) (v2))
		      (pc set (x))
		      0)))))
	   ((= (op) if_acmpne)
	    (let ((v2 (stack-pop (stack))))
	      (let ((v1 (stack-pop (stack))))
		(lambda (x)
		  (if (not (compare-object-reference (v1) (v2)))
		      (pc set (x))
		      0)))))
	   ((= (op) if_acmpeq)
	    (let ((v2 (stack-pop (stack))))
	      (let ((v1 (stack-pop (stack))))
		(lambda (x)
		  (if (compare-object-reference (v1) (v2))
		      (pc set (x))
		      0)))))
	   ((= (op) if_icmpge)
	    (let ((v2 (stack-pop (stack))))
	      (let ((v1 (stack-pop (stack))))
		(lambda (x)
		  (if (>= (v1) (v2))
		      (pc set (x))
		      0)))))
	   ((= (op) if_icmpgt)
	    (let ((v2 (stack-pop (stack))))
	      (let ((v1 (stack-pop (stack))))
		(lambda (x)
		  (if (> (v1) (v2))
		      (pc set (x))
		      0)))))
	   ((= (op) if_icmple)
	    (let ((v2 (stack-pop (stack))))
	      (let ((v1 (stack-pop (stack))))
		(lambda (x)
		  (if (<= (v1) (v2))
		      (pc set (x))
		      0)))))
	   ((= (op) if_icmplt)
	    (let ((v2 (stack-pop (stack))))
	      (let ((v1 (stack-pop (stack))))
		(lambda (x)
		  (if (< (v1) (v2))
		      (pc set (x))
		      0)))))
	   ((= (op) ifnull)
	    (lambda (x)
	      (if (number? / stack-pop (stack))
		  (pc set (x))
		  0)))
	   ((= (op) ifnonnull)
	    (lambda (x)
	      (if (not (number? / stack-pop (stack)))
		  (pc set (x))
		  0)))
	   ((= (op) return)
	    (begin (ret set (hash-ref (vars get) 0))
		   (pc set -1)))
	   ((= (op) ireturn)
	    (begin (ret set (stack-pop (stack)))
		   (pc set -1)))
	   ((= (op) areturn)
	    (begin (ret set (stack-pop (stack)))
		   (pc set -1)))
	   ((= (op) goto)
	    (lambda (target)
	      (pc set (target))))
	   ((= (op) invokevirtual)
	    (lambda (target m n)
	      (let ((result (stack-call (stack) (target) (m))))
		(if (= (n) 1)
		    (stack-push (stack) (result))
		    0))))
	   ((= (op) invokeinterface)
	    (lambda (target m n ignore)
	      (let ((result (stack-call (stack) (target) (m))))
		(if (= (n) 1)
		    (stack-push (stack) (result))
		    0))))
	   ((= (op) invokespecial)
	    (lambda (target m n)
	      (let ((result (stack-call-special (stack) 
						(hash-ref (vars get) 0)
						(target) 
						(m))))
		(if (= (n) 1)
		    (stack-push (stack) (result))
		    0))))
	   0))));


(define stack-call
  (lambda (stack target ct)
    (if (= (ct) 0)
	((stack-pop (stack)) (target))
	(let ((arg (stack-pop (stack))))
	  ((stack-call (stack) (target) (- (ct) 1)) (arg))))));

(define stack-call-special
  (lambda (stack self target ct)
    (if (= (ct) 0)
	(let ((act (stack-pop / stack)))
	  (if (act == (self))
	      (act super (target))
	      (act (target))))
	(let ((arg (stack-pop (stack))))
	  ((stack-call-special (stack) (self) (target) (- (ct) 1)) (arg))))));

(define stack-push
  (lambda (stack x)
    (stack set (prepend (x) (stack get)))));

(define stack-pop
  (lambda (stack)
    (let ((v (head (stack get))))
      (begin
	(stack set (tail (stack get)))
	(v)))));

(define stack-peek
  (lambda (stack)
    (head (stack get))));


(define stack-test1 (cell new (vector 5 3 1)));

(= (stack-pop (stack-test1)) 5);

(= (stack-peek (stack-test1)) 3);
	      
(= (stack-pop (stack-test1)) 3);
	      
(stack-push (stack-test1) 7);

(= (stack-pop (stack-test1)) 7);

(define vars-test1 (cell new (hash-null)));

(define pc-test1 (cell new 0));

(define ret-test1 (cell new 0));

(define test-jvm (jvm-maker (vars-test1) (stack-test1) (pc-test1) (ret-test1)));

(stack-push (stack-test1) 4);

(test-jvm dup);

(= (stack-pop (stack-test1)) 4);

(= (stack-pop (stack-test1)) 4);

(stack-push (stack-test1) 66);

(stack-push (stack-test1) 77);

(test-jvm astore 3);

(= (stack-pop (stack-test1)) 66);

(test-jvm aload 3);

(= (stack-pop (stack-test1)) 77);

(class test-class ()
       (field x ((int) new))
       (field y ((int) new)));

(define test-this (test-class new));

(test-this x set 5);

(= (test-this x get) 5);

(stack-push (stack-test1) (test-this));

(= ((stack-pop (stack-test1)) x get) 5);

(stack-push (stack-test1) (test-this));

(test-jvm astore 0);

(test-jvm aload 0);

(test-jvm getfield x (int));

(= (stack-pop (stack-test1)) 5);

(test-jvm aload 0);

(test-jvm iconst 15);

(test-jvm putfield y (int));

(= (test-this y get) 15);

(stack-push (stack-test1) 7);

(stack-push (stack-test1) 10);

(test-jvm imul);

(test-jvm ireturn);

(= (ret-test1 get) 70);

(define state-machine-helper /
  ? at /
  lambda (vars stack machine) /
  let ((pc (cell new (at)))
       (ret (cell new (true)))) /
  let ((jvm (jvm-maker (vars) (stack) (pc) (ret))))
  (begin
    (machine (jvm) (pc get))
    (if (= (pc get) -1)
	(ret get)
	(state-machine-helper (pc get) (vars) (stack) (machine)))));

(define state-machine
  (state-machine-helper 0));

(stack-push (stack-test1) 10);

(stack-push (stack-test1) 33);

(= (state-machine (vars-test1) (stack-test1) / ? jvm / ? x
		  (cond ((= (x) 0) (jvm istore 4))
			((= (x) 1) (jvm iload 4))
			(jvm ireturn)))
   33);

(stack-push (stack-test1) 10);

(define bytecode-test-mul
  (lambda (arg0 arg1) /
	  let ((vars / cell new / make-hash / vector (pair 0 0) (pair 1 (arg0)) (pair 2 (arg1)))
	       (stack / cell new / vector)) /
	       state-machine (vars) (stack) / ? jvm / ? x / cond
	       ((= (x) 0) (jvm iload 1))
	       ((= (x) 1) (jvm iload 2))
	       ((= (x) 2) (jvm imul))
	       ((= (x) 3) (jvm ireturn))
	       (jvm return)));

(= (bytecode-test-mul 5 9) 45);


