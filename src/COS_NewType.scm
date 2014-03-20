# OBJECT introduce simple form of typing, for ease of documentation.
# An object is simply a function that takes an argument.
# The argument is the method to call on the object.
# Types are here taken to be just the existence of a particular method,
# with that method returning an object of the appropriate type.

(define make-integer
  (lambda (v)
    (lambda (x)
      (if (= (x) int)
	  (v)
	  0))));

(define objectify
  (? x 
     (if (number? (x))
	 (make-integer (x))
	 (x))));

(define instanceof
  (lambda (T t)
    (if (number? (t))
	(= (T) int)
	(not (number? ((objectify (t)) (T)))))));

# add version of lambda that allows types to be declared
(define prev-translate (translate));
(define translate
  (let ((prev (prev-translate)))
    (? x
      (if (number? (x))
        (prev (x))
        (if (= (head (x)) lambda)
          (let ((formals (head (tail (x))))
                (body (head (tail (tail (x))))))
            (if (> (list-length (formals)) 0)
		(if (number? (last (formals)))
		    (translate
		     (vector
		      lambda
		      (except-last (formals))
		      (vector ? (last (formals)) (body))))
		    (let ((formal-name (first (last (formals))))
			  (formal-type (second (last (formals)))))
		      (translate
		       (vector
			lambda
			(except-last (formals))
			(vector 
			 ? 
			 (formal-name) 
			 (vector 
			  let
			  (vector (vector 
				   (formal-name) 
				   (vector
				    (vector objectify (vector (formal-name)))
				    (formal-type))))
			  (body)))))))
		(translate (body))))
          (prev (x)))))));

# add conditional form
(define prev-translate (translate));
(define translate
  (let ((prev (prev-translate)))
    (? x
      (if (number? (x))
        (prev (x))
        (if (= (head (x)) cond)
          (let ((cnd (head (tail (x))))
                (rem (tail (tail (x)))))
            (if (> (list-length (rem)) 0)
		(translate
		 (vector
                  if
		  (first (cnd))
		  (second (cnd))
		  (prepend cond (rem))))
		(translate (cnd))))
          (prev (x)))))));

(= 99 (cond 99));

(= 8 (cond ((true) 8) 11));

(= 11 (cond ((false) 8) 11));

(= 7 (cond ((false) 3) ((true) 7) 11));

(= 3 (cond ((true) 3) ((true) 7) 11));

(= 11 (cond ((false) 3) ((false) 7) 11));


(define remove-match 
  (lambda (test lst)
    (if (> (list-length (lst)) 0)
	(if (test (head (lst)))
	    (remove-match (test) (tail (lst)))
	    (prepend (head (lst)) (remove-match (test) (tail (lst)))))
	(lst))));

(define remove-element
  (lambda (x) 
    (remove-match (lambda (y) (= (y) (x))))));

(list= (vector 1 2 3 5) (remove-element 4 (vector 1 2 3 4 5)));
(list= (vector 1 2 3 5) (remove-element 4 (vector 1 4 2 4 3 4 5)));

(define return
  (lambda (T t)
    (let ((obj (objectify (t))))
      (obj (T)))));

(define tester
  (lambda ((x int) (y int))
    (return int (+ (x) (y)))));


(= 42 (tester (make-integer 10) (make-integer 32)));

(= 42 (tester 10 32));

(define reflective
  (lambda (f)
    ((lambda (x)
       (f (lambda (y) ((x (x)) (y)))))
     (lambda (x)
       (f (lambda (y) ((x (x)) (y))))))));


# OBJECT an example object -- a 2D point

(define point
  (lambda (x y)
    (reflective
     (lambda (self msg)
       (cond ((= (msg) x) (x))
	     ((= (msg) y) (y))
	     ((= (msg) point) (self))
	     ((= (msg) +) 
	      (lambda ((p point))
		(point (+ (x) (p x))
		       (+ (y) (p y)))))
	     ((= (msg) =) 
	      (lambda ((p point))
		(and (= (x) (p x))
		     (= (y) (p y)))))
	     0)))));

(define point1 (point 1 11));
(define point2 (point 2 22));
(= 1 (point1 x));
(= 22 (point2 y));
(= 11 ((point 11 12) x));
(= 11 (((point 11 12) point) x));
(= 16 (((point 16 17) point) x));
(= 33 (point1 + (point2) y));
(point1 + (point2) = (point 3 33));
(point2 + (point1) = (point 3 33));
((point 100 200) + (point 200 100) = (point 300 300));

(instanceof point (point1));
(not (instanceof int (point1)));
(instanceof int 5);
(not (instanceof point 5));


# OBJECT an example object -- a container


(define container
  (lambda (x)
    (let ((contents (make-cell (vector))))
      (reflective
       (lambda (self msg)
	 (cond ((= (msg) container) (self))
	       ((= (msg) inventory) (get! (contents)))
	       ((= (msg) add)
		(lambda (x) 
		  (if (not (element (x) (get! (contents))))
		      (set! (contents) (prepend (x) (get! (contents))))
		      (false))))
	       ((= (msg) remove)
		(lambda (x)
		  (set! (contents) (remove-element (x) (get! (contents))))))
	       ((= (msg) =)
		(lambda ((c container))
		  (set= (self inventory) (c inventory))))
	       0))))));

# Can pass anything to container function to create an object
# Should eventually use a consistent protocol for all objects,
# but all this stuff is still in flux
(define pocket (container new));

(pocket add 77);
(pocket add 88);
(pocket add 99);
(set= (pocket inventory) (vector 77 88 99));
(pocket remove 88);
(set= (pocket inventory) (vector 77 99));

(define pocket2 (container new));
(pocket2 add 77);
(pocket2 add 99);
(pocket2 = (pocket));



# OBJECT expressing inheritance

# counter-container adds one method to container: count

(define counter-container
  (lambda (x)
    (let ((super (container new)))
      (reflective
       (lambda (self msg)
	 (cond ((= (msg) counter-container) (self))
	       ((= (msg) count) (list-length (super inventory)))
	       (super (msg))))))));

(define cc1 (counter-container new));

(= 0 (cc1 count));
(cc1 add 4);
(= 1 (cc1 count));
(cc1 add 5);
(= 2 (cc1 count));

# OBJECT adding a special form for classes

# need a bunch of extra machinery first, will push this
# back into previous sections eventually, and simplify

(define list-append
  (lambda (lst1 lst2)
    (if (> (list-length (lst1)) 0)
	(list-append (except-last (lst1))
		     (prepend (last (lst1)) (lst2)))
	(lst2))));

(list= (list-append (vector 1 2 3) (vector 4 5 6)) (vector 1 2 3 4 5 6));

(define append
  (? x
     (? lst
	(if (> (list-length (lst)) 0)
	    (prepend (head (lst)) (append (x) (tail (lst))))
	    (vector (x))))));

(list= (append 5 (vector 1 2)) (vector 1 2 5));

(define select-match 
  (lambda (test lst)
    (if (> (list-length (lst)) 0)
	(if (test (head (lst)))
	    (prepend (head (lst)) (select-match (test) (tail (lst))))
	    (select-match (test) (tail (lst))))
	(lst))));

(define unique
  (let ((store (make-cell 0)))
    (lambda (x)
      (let ((id (get! (store))))
	(begin
	  (set! (store) (+ (id) 1))
	  (id))))));

(= (unique new) 0);

(= (unique new) 1);

(= (unique new) 2);

(not (= (unique new) (unique new)));


(define setup-this
  (lambda (this self)
    (if (number? / this)
	(self)
	(this))));


# okay, here it comes.  don't panic!
# I need to split this up into helpers, and simplify.
# It basically just writes code for classes like we saw in
# a previous section.
(define prev-translate (translate));
(define translate
  (let ((prev (prev-translate)))
    (? x
       (if (number? (x))
	   (prev (x))
	   (if (= (head (x)) class)
	       (let ((name (list-ref (x) 1))
		     (args (list-ref (x) 2))
		     (fields (tail (tail (tail (x))))))
		 (translate
		  (vector
		   define
		   (name)
		   (vector
		    lambda
		    (prepend ext-this (args))
		    (vector
		     let
		     (append
		      (vector unique-id (vector unique new))
		      (map 
		       (tail)
		       (select-match (? x (= (first (x)) field)) (fields))))
		     (vector
		      let
		      (vector
		       (vector
			self
			(vector
			 reflective
			 (vector
			  lambda
			  (vector self)
			  (vector
			   let
			   (vector 
			    (vector
			     this
			     (vector setup-this 
				     (vector ext-this)
				     (vector self))))
			   (vector 
			    let
			    (vector (vector ignore-this 1))
			    (vector
			     lambda
			     (vector method)
			     (list-append
			      (prepend
			       cond
			       (list-append
				(map
				 (? x 
				    (vector
				     (vector = (vector method) (first (x)))
				     (second (x))))
				 (map (tail)
				      (select-match 
				       (? x (= (first (x)) method)) 
				       (fields))))
				(map
				 (? x 
				    (vector
				     (vector = (vector method) (x))
				     (vector (x))))
				 (map (second)
				      (select-match 
				       (? x (= (first (x)) field)) 
				       (fields))))))
			      (vector
			       (vector
				(vector = (vector method) self)
				(vector self))
			       (vector
				(vector = (vector method) (name))
				(vector self self))
			       (vector
				(vector = (vector method) classname)
				(name))
			       (vector
				(vector = (vector method) unknown)
				(vector lambda (vector x) 0))
			       (vector
				(vector = (vector method) new)
				0)
			       (vector
				(vector = (vector method) unique-id)
				(vector unique-id))
			       (vector
				(vector = (vector method) ==)
				(vector
				 lambda
				 (vector x)
				 (vector = 
					 (vector unique-id)
					 (vector x unique-id))))
			       (vector self unknown (vector method)))))))))))
		      (vector 
		       begin
		       (vector self new)
		       (vector self))))))))
	       (prev (x)))))));

# revisit the point class example

(class point (x y) 
       (method x (x))
       (method y (y))
       (method + (lambda ((p point))
		   (point new 
			  (+ (x) (p x))
			  (+ (y) (p y)))))
       (method = (lambda ((p point))
		   (and (= (x) (p x))
			(= (y) (p y))))));

# note the appearance of new in the next line --
# this is the only difference to previous version

(define point1 (point new 1 11));
(define point2 (point new 2 22));
(= 1 (point1 x));
(= 22 (point2 y));
(= 11 ((point new 11 12) x));
(= 11 (((point new 11 12) point) x));
(= 16 (((point new 16 17) point) x));
(= 33 (point1 + (point2) y));
(point1 + (point2) = (point new 3 33));
(point2 + (point1) = (point new 3 33));
((point new 100 200) + (point new 200 100) = (point new 300 300));

(instanceof point (point1));
(not (instanceof int (point1)));


# Check that virtual calls can be made to work.
# They are a little awkward right now.
# Should they be the default?

(class c1 ()
       (method getid 100)
       (method altid (this getid)));

(class c2 ()
       (field super-ref (make-cell 0))
       (method new (set! (super-ref) (c1 / this)))
       (method super (? x ((get! / super-ref) (x))))
       (method unknown (? x (self super / x)))
       (method getid 200));

(= 100 / c1 new altid);

(= 200 / c2 new altid);

# OBJECT wrapper class for cells

(class cell (initial-value)
       (field content (make-cell (initial-value)))
       (method get (get! (content)))
       (method set (lambda (new-value)
		     (set! (content) (new-value))))
       (method reset (self set (initial-value)))
       (method unknown (lambda (x) ((objectify (self get)) (x)))));

(define cell-test1 (cell new 15));
(= 15 (cell-test1 get));
(cell-test1 set 82);
(= 82 (cell-test1 get));

(define cell-test2 (cell new (point new 120 150)));
(define cell-test3 (cell new (point new 300 300)));
(cell-test2 + (cell-test3) = (point new 420 450));
(not (cell-test2 = (cell-test3)));

(cell-test3 set (cell-test2));
(cell-test2 = (cell-test3));



# MUD playing around with doors and rooms

(class door ((src room) (dest room))
       (method new (begin
		     (src add (self))
		     (dest add (self))))
       (method access-from (lambda ((current room))
			     (cond ((current == (src)) (dest))
				   ((current == (dest)) (src))
				   0)))
       (method is-present (lambda ((current room))
			    (cond ((current == (src)) (true))
				  ((current == (dest)) (true))
				  (false)))));

(class room (name)
       (field content (container new))
       (method name (name))
       (method unknown (lambda (x) (content (x)))));

# need to fix up containers to use object equality

(define object-element
  (lambda (n lst)
    (> (list-length 
	(select-match (lambda (x) (x == (n))) (lst))) 
       0)));

(class container ()
    (field contents (cell new (vector)))
    (method inventory (contents get))
    (method add (lambda (x) 
		  (if (not (object-element (x) (contents get)))
		      (contents set (prepend (x) (contents get)))
		      (false)))));


(define hall (room new 0));
(define kitchen (room new 1));
(define door1 (door new (hall) (kitchen)));

((first (hall inventory)) == (door1));
((first (kitchen inventory)) == (door1));
(door1 access-from (hall) == (kitchen));
(not (door1 access-from (hall) == (hall)));
(door1 access-from (kitchen) == (hall));

(define stairs (room new 2));
(define lawn (room new 3));
(define bedroom (room new 4));
(define nowhere (room new 0));
(define door2 (door new (hall) (lawn)));
(define door3 (door new (hall) (stairs)));
(define door4 (door new (stairs) (bedroom)));

(class character ()
       (field location (cell new 0))
       (field name (cell new 0))
       (method set-room (lambda ((r room)) 
			  (begin
			    (if (not (number? / location get))
				(location get remove (self))
				0)
			    (r add (self))
			    (location set (r)))))
       (method get-room (location get))
       (method set-name (lambda (n) (name set / n)))
       (method get-name (name get))
       (method update 0));

(define find-max-helper
  (lambda (test max idx n lst)
    (if (> (list-length (lst)) 0)
	(if (> (test (head (lst))) (max))
	    (find-max-helper (test) (test (head (lst))) (n) (+ (n) 1) (tail (lst)))
	    (find-max-helper (test) (max) (idx) (+ (n) 1) (tail (lst))))
	(idx))));

(define find-max-idx
  (lambda (test lst)
    (find-max-helper (test) (test (head (lst))) 0 0 (lst))));

(define find-min-helper
  (lambda (test max idx n lst)
    (if (> (list-length (lst)) 0)
	(if (< (test (head (lst))) (max))
	    (find-min-helper (test) (test (head (lst))) (n) (+ (n) 1) (tail (lst)))
	    (find-min-helper (test) (max) (idx) (+ (n) 1) (tail (lst))))
	(idx))));

(define find-min-idx
  (lambda (test lst)
    (find-min-helper (test) (test (head (lst))) 0 0 (lst))));

(= 2 (find-max-idx (lambda (x) (x)) (vector 3 4 5 0)));

(= 1 (find-max-idx (lambda (x) (x)) (vector 3 5 4 0)));

(= 0 (find-max-idx (lambda (x) (x)) (vector 5 3 4 0)));

# the robo class makes a character that patrols from room to room

(class robo ()
       (field super (character new))
       (field timestamp (cell new 1))
       (field timestamp-map (cell new (lambda (x) 0)))
       (method unknown (lambda (x) (super (x))))
       (method update 
	       (let ((exits 
		      (select-match (lambda (x) (instanceof door (x)))
				    (self location inventory))))
		 (let ((timestamps
			(map (lambda (x) (timestamp-map get (x)))
			     (exits))))
		   (let ((chosen-exit (list-ref 
				       (exits)
				       (find-min-idx (lambda (x) (x))
						     (timestamps))))
			 (current-tmap (timestamp-map get))
			 (current-t (timestamp get)))
		     (begin
		       (self location set (chosen-exit 
					   access-from 
					   (self location get)))
		       (timestamp-map set 
				      (lambda ((d door))
					(if (d == (chosen-exit))
					    (current-t)
					    (current-tmap (d)))))
		       (timestamp set (+ (timestamp get) 1))))))));


(define myrobo (robo new));

(myrobo set-room (stairs));

(define which-room
  (lambda ((rr robo))
    (find-max-idx 
     (lambda ((r room)) (if (r == (rr get-room)) 1 0))
     (vector (hall) (kitchen) (stairs) (lawn) (bedroom)))));

(define sequencer
  (lambda (n current lst)
    (if (< (current) (n))
	(begin
	  (myrobo update)
	  (sequencer
	   (n)
	   (+ (current) 1)
	   (append
	    (which-room (myrobo))
	    (lst))))
	(lst))));


# here is a list of the first 30 rooms the robot character visits
# 0=hall, 1=kitchen, 2=stairs, 3=lawn, 4=bedroom
(list= (sequencer 30 0 (vector)) (vector 4 2 0 3 0 1 0 2 4 2 0 3 0 1 0 2 4 2 0 3 0 1 0 2 4 2 0 3 0 1));


# Now should start to introduce a language to talk about what is
# going on in the simulated world, and start to move away from
# detailed mechanism

