
import java.util.Iterator;

public class COS_JRobo extends COS_JThing {
    private COS_JHashMap times;
    private int now;

    public COS_JRobo() {
	times = new COS_JHashMap();
	now = 1;
    }

    public void update() {
	COS_JRoom location = getRoom();
	//System.out.println("Updating robo...");
	if (location!=null) {
	    int oldestTime = now;
	    COS_JDoor oldestDoor = null;
	    for (Iterator i = location.getDoors(); i.hasNext(); ) {
		COS_JDoor door = (COS_JDoor) i.next();
		//System.out.println(" scanning door ");
		Integer t = (Integer)times.get(door);
		int v = 0;
		if (t!=null) {
		    v = t.intValue();
		}
		if (v<oldestTime) {
		    oldestTime = v;
		    oldestDoor = door;
		}
	    }
	    if (oldestDoor!=null) {
		times.put(oldestDoor,new Integer(now));
		setNextRoom(oldestDoor.apply(location));
	    }
	}
	now++;
    }
}

