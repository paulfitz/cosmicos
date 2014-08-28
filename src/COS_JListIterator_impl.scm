
# JAVA basic iterator implementation

(class COS_JListIterator (ref)
       (field pipe (cell new (ref contents get)))
       (method <init>-V (self))
       (method <init> (self <init>-V))
       (method hasNext-Z (> (list-length | pipe get) 0))
       (method hasNext (self hasNext-Z))
       (method next (self next-Object))
       (method next-Object 
	       (let ((result (head | pipe get)))
		 (begin 
		   (pipe set | tail | pipe get)
		   (result)))));

(define test1 (COS_JList new));

(begin
  (test1 add 15)
  (test1 add 72)
  (test1 add 99)
  (true));

(define iter1 (test1 iterator));

(iter1 hasNext);
(demo | iter1 next);
(iter1 hasNext);
(demo | iter1 next);
(iter1 hasNext);
(demo | iter1 next);
(not | iter1 hasNext);

