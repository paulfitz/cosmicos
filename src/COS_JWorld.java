
import java.util.Iterator;

public class COS_JWorld {
    private COS_JHashMap content;
    private COS_JList inventory;

    public COS_JWorld() {
	content = new COS_JHashMap();
	inventory = new COS_JList();
    }

    public void add(COS_JNamed named, String name) {
	named.setName(name);
	content.put(named.getName(),named);
	inventory.add(named);
    }

    public COS_JNamed get(String name) {
	return (COS_JNamed)content.get(new String(name));
    }

    public void update() {
	for (Iterator i = inventory.iterator(); i.hasNext(); ) {
	    COS_JNamed o = (COS_JNamed) i.next();
	    o.update();
	}
	for (Iterator i = inventory.iterator(); i.hasNext(); ) {
	    COS_JNamed o = (COS_JNamed) i.next();
	    o.postUpdate();
	}
    }
}
