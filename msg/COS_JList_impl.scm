# JAVA native implementation of a Java list, hash classes

(define flex-equals
  (lambda (x y) 
    (if (number? | x)
	(if (number? | y)
	    (= (x) (y))
	    (false))
	(if (number? | y)
	    (false)
	    (x equals (y))))));

(define remove-object
  (lambda (x) 
    (remove-match (lambda (y) 
		    (flex-equals (x) (y))))));

(define contains-object
  (lambda (x lst)
    (if (> (list-length | lst) 0)
	(if (flex-equals (head | lst) (x))
	    (true)
	    (contains-object (x) (tail | lst)))
	(false))));

(class COS_JList ()
       (field super ((java lang Object) new))
       (method unknown (lambda (x) (super (x))))
       (field contents (cell new (vector)))
       (method <init>-V (self))
       (method <init> (self <init>-V))
       (method add-Object-V (lambda (x)
		     (contents set (prepend (x) (contents get)))))
       (method add (self add-Object-V))
       (method remove-Object-Z (lambda (x)
			(contents set 
				  (remove-object (x) (contents get)))))
       (method remove (self remove-Object-Z))
       (method contains-Object-Z (lambda (x)
				   (contains-object (x) (contents get))))
       (method contains (self contains-Object-Z))
       (method get-I-Object (lambda (x)
		     (list-ref (contents get) (x))))
       (method get (self get-I-Object))
       (method iterator-Iterator (COS_JListIterator new (self)))
       (method iterator (self iterator-Iterator))
       (method size-V-I (list-length (contents get)))
       (method size (self size-V-I)));
       

(define test1 (COS_JList new));

(begin (test1 add-Object-V (test1))
       (= 1 | test1 size-V-I));

(test1 == (test1 get-I-Object 0));

(class COS_JHashMap ()
       (field super ((java lang Object) new))
       (method unknown (lambda (x) (super (x))))
       (field contents (cell new (? x 0)))
       (method <init>-V (self))
       (method <init> (self <init>-V))
       (method put-Object-Object-V (lambda (x y)
				     (let ((prev | contents get))
				       (contents set 
						 (? z 
						    (if (flex-equals (z) (x))
							(y)
							(prev (z))))))))
       (method put (self put-Object-Object-V))
       (method get-Object-Object (lambda (x)
				   (contents get (x))))
       (method get (self get-Object-Object)));

(define test2 (COS_JHashMap new));

(begin (test2 put-Object-Object-V 5 10)
       (= 10 | test2 get 5));

