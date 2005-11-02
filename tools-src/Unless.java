
//package unless;

public class Unless {
    private boolean state = true;
    private boolean nextState = true;
    private boolean forced = false;
    private Unless src = null;
    private Unless dest = null;

    public void setSource(Unless src) {
	this.src = src;
    }

    public void setDestination(Unless dest) {
	this.dest = dest;
    }

    public boolean getState() {
	return state;
    }

    public void block() {
	nextState = false;
    }

    public void prepareForUpdate() {
	if (!forced) {
	    nextState = true;
	    if (src!=null) {
		nextState = src.getState();
	    }
	}
    }

    public void update() {
	if (!forced) {
	    if (state) {
		if (dest!=null) {
		    dest.block();
		}
	    }
	}
    }

    public void finalizeUpdate() {
	if (!forced) {
	    state = nextState;
	}
	forced = false;
    }

    public Unless getSource() {
	return src;
    }

    public Unless getDestination() {
	return dest;
    }

    public void set(boolean state) {
	this.state = state;
	forced = true;
    }
}

