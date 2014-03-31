
//package unless;

import java.io.*;
import java.util.*;

public class GridLoader {
    public static UnlessGrid loadGrid(String name) {
	UnlessGrid grid = new UnlessGrid();
	try {
	    //System.out.println("Reading from file " + name);
	    BufferedReader reader = new BufferedReader(new FileReader(name));
	    boolean done = false;
	    while (!done) {
		String line = reader.readLine();
		//System.out.println(">>> " + line);
		if (line==null) {
		    done = true;
		} else {

		    //String[] parts = line.split(" ");
		    //for 1.4 compat, need to be a bit more roundabout
		    List partsList = new ArrayList();
		    StringBuffer tmp = new StringBuffer("");
		    for (int i=0; i<line.length(); i++) {
			char ch = line.charAt(i);
			if (ch==' ') {
			    partsList.add(tmp.toString());
			    //System.out.println("*" + tmp.toString());
			    tmp = new StringBuffer("");
			} else {
			    tmp.append(ch);
			}
		    }
		    partsList.add(tmp.toString());
		    //System.out.println("*" + tmp.toString());
		    List lst  = new ArrayList();
		    for (Iterator i=partsList.iterator(); i.hasNext(); ) {
			String s = (String) i.next();
			if (lst.size()<4) {
			    Integer v = new Integer(0);
			    try {
			    v = Integer.decode(s);
			    } catch (Exception e) {
				// default to 0
				v = new Integer(0);
				if (false) {
				    System.out.print("Glitch on line [");
				    System.out.print(line);
				    System.out.println("]");
				}
			    }
			    lst.add(v);
			}
		    }
		    if (lst.size()>=4) {
			String label = null;
			if (partsList.size()>=5) {
			    //System.out.println(partsList);
			    label = (String)partsList.get(4);
			}
			//System.out.println("add " + lst + "[" + label + "]");
			    grid.add(((Integer)lst.get(0)).intValue(),
				     ((Integer)lst.get(1)).intValue(),
				     ((Integer)lst.get(3)).intValue(),
				     ((Integer)lst.get(2)).intValue(),
				     label);
		    }
		}
	    }
	} catch (Exception e) {
	    e.printStackTrace();
	    throw (new RuntimeException("uh-oh"));
	}
	return grid;
    }

}

