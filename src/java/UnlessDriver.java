
//package unless;

public class UnlessDriver {

    public static void exercise() {
	UnlessNet net = new UnlessNet();
	net.add("john");
	net.add("mary");
	net.add("liam");
	net.add("paul");
	net.add("deirdre");
	net.setDestination("john","mary");
	net.setDestination("mary","liam");
	System.out.println(net);
	net.update();
	System.out.println(net);
	net.update();
	System.out.println(net);
	net.update();
	System.out.println(net);

	System.out.println("*************************************");
	System.out.println("*************************************");
	System.out.println("*************************************");

	UnlessGrid grid = new UnlessGrid();
	grid.add(3,6,1,0,"");
	grid.add(3,10,1,0,"");
	grid.add(5,6,1,0,"");
	UnlessNet net2 = grid.compile();
	System.out.println(net2);


	UnlessGrid grid3 = GridLoader.loadGrid("src/D.txt");
	UnlessNet net3 = grid3.compile();

	System.out.println(net3);

	for (int i=0; i<120; i++) {
	    String str = grid3.render(net3);
	    if (i>=20&&i<=60) {
		net3.get(grid3.getLabel("DATA")).set(false);
	    }
	    if (i>=40&&i<=80) {
		net3.get(grid3.getLabel("CLK")).set(false);
	    }
	    System.out.println("*************************************");
	    //System.out.println(">>> clock_" + String.format("%03d",i));
	    System.out.print(str);
	    net3.update();
	}
    }

    public static void showGrid(String name) {
	UnlessGrid grid = GridLoader.loadGrid(name);
	UnlessNet net = grid.compile();
	for (int i=0; i<100; i++) {
	    net.update();
	}
	System.out.println(">>> " + name);
	System.out.println(grid.render(net));
    }

    public static void main(String[] arg) {
	for (int i=0; i<arg.length; i++) {
	    showGrid(arg[i]);
	}
    }
}

