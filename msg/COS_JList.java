
/* STUB: # There is Java code for COS_JList available */

import java.util.Iterator;
import java.util.ArrayList;

public class COS_JList {
    private ArrayList lst = new ArrayList();
    public void add(Object o) {
	lst.add(o);
    }

    public boolean remove(Object o) {
	return lst.remove(o);
    }

    public boolean contains(Object o) {
	return lst.contains(o);
    }

    public int size() {
	return lst.size();
    }

    public Object get(int index) {
	return lst.get(index);
    }

    public Iterator iterator() {
	return lst.iterator();
    }
}

