
import java.io.IOException;

// This code is not intended to go into the message.
// It can be used to exercise parts of the message that are in Java.

class COS_JavaMain {
    public void testJList() {
	System.out.println("JList...");
	COS_JList lst = new COS_JList();
	lst.add(new Integer(11));
	lst.add(new Integer(22));
	lst.add(new Integer(33));
	lst.remove(new Integer(22));
	assert (lst.contains(new Integer(11))) : "bad containment";
	assert (!lst.contains(new Integer(22))) : "bad removal";
	assert (lst.size()==2) : "wrong list size";
	System.out.println("...passed");
    }

    public void testJHashMap() {
	System.out.println("JHashMap...");
	COS_JHashMap map = new COS_JHashMap();
	map.put(new Integer(11), new Integer(77));
	assert (((Integer)map.get(new Integer(11))).intValue()==77) : "wrong get value";
	System.out.println("...passed");
    }

    public void testJWorld() {
	System.out.println("JWorld...");
	COS_JWorld world = new COS_JWorld();
	COS_JRoom boston = new COS_JRoom();
	COS_JRoom newyork = new COS_JRoom();
	COS_JRobo bus = new COS_JRobo();
	world.add(boston, "boston");
	world.add(newyork, "newyork");
	world.add(bus, "bus");
	bus.setRoom(boston);
	new COS_JDoor((COS_JRoom)world.get("boston"),
		      "south",
		      (COS_JRoom)world.get("newyork"),
		      "north");
	assert(bus.getRoom().getName().equals("boston"));
	world.update();
	assert(bus.getRoom().getName().equals("newyork")) : "wrong final dest";
	System.out.println("...passed");
    }

    public String getAct() {
	String txt = "";
	boolean done = false;
	while (!done) {
	    try {
		char ch = (char) System.in.read();
		if (ch<0||ch=='\n') {
		    done = true;
		} else {
		    txt = txt + ch;
		}
	    } catch (IOException e) {
		e.printStackTrace();
		System.exit(0);
	    }
	}
	System.out.println("act " + txt);
	return txt;
    }

    public void testRun() {
	System.out.println("Running...");
	String cmd = getAct();

	COS_JWorld world = new COS_JWorld();
	COS_JRoom boston = new COS_JRoom();
	COS_JRoom newyork = new COS_JRoom();
	COS_JRobo bus = new COS_JRobo();
	world.add(boston, "boston");
	world.add(newyork, "newyork");
	world.add(bus, "bus");
	bus.setRoom(boston);

	while (1) {
	    System.out.println("current location is ", 
			       bus.getRoom().getName());
	    Iterator it = bus.getRoom().getDoors();
	    String cmd = getAct();
	    //world.update();
	}

    }

    public void testAll() {
	testJList();
	testJHashMap();
	testJWorld();
	testRun();
    }
    
    public static void main(String[] args) {
	System.out.println("Running tests...");
	COS_JavaMain main = new COS_JavaMain();
	main.testAll();
    }
}
