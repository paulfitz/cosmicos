
//package unless;

import java.util.*;

public class UnlessGrid {
    private class Pair {
	public int x, y;
	public Pair(int x, int y) {
	    this.x = x;
	    this.y = y;
	}
	public boolean equals(Object o) {
	    if (!(o instanceof Pair)) 
		return false;
	    Pair p = (Pair) o;
	    return this.x == p.x && this.y == p.y;
	}
	public int hashCode() {
	    return 31*x+y;
	}
    }

    private Map/*Pair,Pair*/ points = new HashMap();
    private Map/*String,Pair*/ names = new HashMap();

    public void add(int x, int y, int dx, int dy, String label) {
	points.put(new Pair(x,y), new Pair(dx,dy));
	names.put(label, new Pair(x,y));
    }

    public static String getName(int x, int y) {
	return "(" + x + "," + y + ")";
    }

    public UnlessNet compile() {
	UnlessNet net = new UnlessNet();
	for (Iterator i=points.keySet().iterator(); i.hasNext(); ) {
	    Pair entry = (Pair) i.next();
	    Pair rec = (Pair)points.get(entry);  // a bit inefficient
	    int x = entry.x;
	    int y = entry.y;
	    int dx = rec.x;
	    int dy = rec.y;
	    net.add(getName(x,y));
	}
	for (Iterator i=points.keySet().iterator(); i.hasNext(); ) {
	    Pair entry = (Pair) i.next();
	    Pair rec = (Pair)points.get(entry);  // a bit inefficient
	    int x = entry.x;
	    int y = entry.y;
	    int dx = rec.x;
	    int dy = rec.y;
	    int x0 = x+dx*2;
	    int y0 = y+dy*2;
	    int x90 = x+dx+dy;
	    int y90 = y+dy-dx;
	    int x270 = x+dx-dy;
	    int y270 = y+dy+dx;
	    Pair rec0 = (Pair)points.get(new Pair(x0,y0));
	    Pair rec90 = (Pair)points.get(new Pair(x90,y90));
	    Pair rec270 = (Pair)points.get(new Pair(x270,y270));
	    boolean blocking = false;
	    boolean lr = false;
	    if (rec90!=null && rec270!=null) {
		if (rec90.equals(rec270)) {
		    blocking = true;
		    lr = true;
		}
	    }
	    if (rec0!=null) {
		if (rec0.equals(rec)) {
		    blocking = false;
		}
	    }
	    if (blocking) {
		// set appropriate destination
		net.setDestination(getName(x,y),
				   getName(x+dx+rec90.x,y+dy+rec90.y));
	    }
	    if (!blocking) {
		if (rec0!=null) {
		    if (rec0.equals(rec)) {
			// good to src
			net.setSource(getName(x0,y0),
				      getName(x,y));
		    }
		}
		if (!lr) {
		    if (rec90!=null) {
			if (x90-rec90.x==x+dx &&
			    y90-rec90.y==y+dy) {
			    // good to src
			    net.setSource(getName(x90,y90),
					  getName(x,y));
			}
		    }
		    if (rec270!=null) {
			if (x270-rec270.x==x+dx &&
			    y270-rec270.y==y+dy) {
			    // good to src
			    net.setSource(getName(x270,y270),
					  getName(x,y));
			}
		    }
		}
	    }

	}
	return net;
    }

    public String render(UnlessNet net) {
	StringBuffer str = new StringBuffer("");
	for (Iterator i=points.keySet().iterator(); i.hasNext(); ) {
	    Pair entry = (Pair) i.next();
	    Pair rec = (Pair)points.get(entry);
	    int x = entry.x;
	    int y = entry.y;
	    int dx = rec.x;
	    int dy = rec.y;
	    String name = getName(x,y);
	    int v = 0;
	    boolean b = net.get(name).getState();
	    if (b) { v = 1; }
	    str.append( x + " " + y + " " + dx + " " + dy);
	    str.append(" " + v + "\n");
	}
	return str.toString();
    }

    public String getLabel(String label) {
	Pair p = (Pair)names.get(label);
	return getName(p.x,p.y);
    }
}

