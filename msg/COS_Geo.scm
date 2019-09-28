
# MUD another simple little text-adventure space

# let us try to make a slightly more interesting world

(define make-table
  (lambda (lst)
    (reduce (? x | ? h | 
	       assign name (car | x) |
	       assign obj (cdr | x) |
	       hash-add (h) (name) (obj))
	    (append (hash-null) (lst)))));

# note, the quoted strings below are just represented as a big number,
# nothing special
(define geo-map 
  (make-table
   (map
    (? name (cons (name) (room new (name))))
    (vector "boston" "dublin" "paris" "genoa"))));

(define my-links
  (map 
   (? entry (assign src (car | entry) |
		    assign dest (cdr | entry) |
		    door new (geo-map | src) (geo-map | dest)))
   (vector
    (cons "boston" "dublin")
    (cons "dublin" "paris")
    (cons "boston" "paris")
    (cons "paris" "genoa"))));

(define myrobo (robo new));

(myrobo set-room (geo-map "dublin"));

(demo | myrobo get-room name);

(myrobo update);

(demo | myrobo get-room name);

(myrobo update);

(demo | myrobo get-room name);

(myrobo update);

(demo | myrobo get-room name);

(myrobo update);

(demo | myrobo get-room name);

(myrobo update);

(demo | myrobo get-room name);

(myrobo update);

(demo | myrobo get-room name);


# all characters should update together

(class world (the-places the-links)
       (field things (container new))
       (field names (cell new (hash-null)))
       (field places (cell new 0))
       (field links (cell new 0))
       (method new 
	       (begin
		 (places set
			(make-table
			 (map
			  (? name (cons (name) (room new (name))))
			  (the-places))))
		 (links set
			(map 
			 (? entry (assign src (car | entry) |
					  assign dest (cdr | entry) |
					  door new 
					  (places get | src) 
					  (places get | dest)))
			 (the-links)))))
       (method add (lambda (place name val) 
		     (begin
		       (val set-room (places get | place))
		       (val set-name | name)
		       (names set (hash-add (names get)
					    (name)
					    (val)))
		       (things add (val)))))
       (method find (lambda (n) (names get (n) get-room name)))
       (method reachable (lambda (place)
			   (let ((exits
				  (select-match (lambda (x) 
						  (instanceof door (x)))
						(places get (place) inventory))))
			     (map (? door (door access-from 
						(places get | place)
						name))
				  (exits)))))
       (method update (begin 
			(map (? x (x update)) 
			     (things inventory))
			(true))));

(define geo-world
  (world new 
	 (vector "boston" "dublin" "paris" "genoa")
	 (vector
	  (cons "boston" "dublin")
	  (cons "dublin" "paris")
	  (cons "boston" "paris")
	  (cons "paris" "genoa"))));

(geo-world add "dublin" "robo1" (robo new));

(geo-world add "genoa" "robo2" (robo new));

(demo | geo-world find "robo1");
(demo | geo-world find "robo2");

(geo-world update);

(demo | geo-world find "robo1");
(demo | geo-world find "robo2");

(demo | geo-world reachable "boston");

(demo | geo-world reachable "genoa");




