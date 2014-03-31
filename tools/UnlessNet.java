
//package unless;

import java.util.*;

public class UnlessNet {
    private List/*Unless*/ net = new LinkedList();
    private Map/*String,Unless*/ nodes = new HashMap();
    private Map/*Unless,String*/ names = new HashMap();

    public void add(String name) {
	if (nodes.get(name)==null) {
	    Unless node = new Unless();
	    nodes.put(name,node);
	    names.put(node,name);
	    net.add(node);
	}
    }

    public Unless get(String name) {
	return (Unless)nodes.get(name);
    }
    
    public void setSource(String name, String srcName) {
	Unless ref = (Unless)nodes.get(name);
	if (ref!=null) {
	    Unless src = (Unless)nodes.get(srcName);
	    ref.setSource(src);
	}
    }

    public void setDestination(String name, String destName) {
	Unless ref = (Unless)nodes.get(name);
	if (ref!=null) {
	    Unless dest = (Unless)nodes.get(destName);
	    ref.setDestination(dest);
	}
    }

    public void update() {
	for (Iterator i=net.iterator(); i.hasNext(); ) {
	    Unless u = (Unless) i.next();
	    u.prepareForUpdate();
	}
	for (Iterator i=net.iterator(); i.hasNext(); ) {
	    Unless u = (Unless) i.next();
	    u.update();
	}
	for (Iterator i=net.iterator(); i.hasNext(); ) {
	    Unless u = (Unless) i.next();
	    u.finalizeUpdate();
	}
    }

    public String toString() {
	StringBuffer sb = new StringBuffer();
	for (Iterator i=net.iterator(); i.hasNext(); ) {
	    Unless u = (Unless) i.next();
	    String name = (String)names.get(u);
	    Unless src = u.getSource();
	    Unless dest = u.getDestination();
	    String srcName = "[1]";
	    String destName = "[0]";
	    if (src!=null) { srcName = (String)names.get(src); }
	    if (dest!=null) { destName = (String)names.get(dest); }
	    String line = "node " + name + " (" + srcName + ":" + destName + ") = " + u.getState() + "\n";
	    sb.append(line);
	}
	return sb.toString();
    }
}

