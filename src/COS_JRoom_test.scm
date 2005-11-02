
# JAVA test JRoom, JDoor, JThing, etc

(define s (? x / String new int-init / x));

(define room1 (COS_JRoom new <init>));
(define room2 (COS_JRoom new <init>));
(define door12 (COS_JDoor new <init> 
			  (room1) (s "south") (room2) (s "north")));
(define jworld (COS_JWorld new <init>));

(define thing1 (COS_JThing new <init>));
(define robo1 (COS_JRobo new <init>));

(act / jworld add (thing1) / s "bus");
(act / jworld add (robo1) / s "autobus");
(act / jworld add (room1) / s "boston");
(act / jworld add (room2) / s "newyork");

(begin (room1 get add (room1))
       (= 1 / room1 get size));

(= 1 / room1 get size);

(= 0 / room2 get size);

(act / thing1 setRoom (room1));

(= 2 / room1 get size);

(= 0 / room2 get size);

(act / thing1 setRoom (room2));

(room1 get size);

(room2 get size);

(thing1 equals (thing1));
(room1 equals (room1));
(not / thing1 equals (room1));

(demo / door12 apply (room1) (s "south") getName intValue);
(demo / door12 apply (room2) (s "north") getName intValue);

(define o
  (? x / jworld get / s / x));

(= "newyork" / (o "bus") getRoom getName intValue);

(act / robo1 setRoom (room1));

(demo / (o "autobus") getRoom getName intValue);
(act / jworld update);
(demo / (o "autobus") getRoom getName intValue);

