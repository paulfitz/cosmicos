
import java.util.Iterator;

public class COS_JRoom extends COS_JNamed {
    //private COS_JList content = new COS_JList();
    //private COS_JList doors = new COS_JList();

    private COS_JList content;
    private COS_JList doors;

    public COS_JRoom() {
	content = new COS_JList();
	doors = new COS_JList();
    }

    public COS_JList get() {
	return content;
    }

    public Iterator getDoors() {
	return doors.iterator();
    }

    public void addDoor(COS_JDoor door) {
	//System.out.println("add door -> " + getName());
	doors.add(door);
    }

    public void addThing(COS_JThing thing) {
	content.add(thing);
    }

    public void removeThing(COS_JThing thing) {
	content.remove(thing);
    }
}
