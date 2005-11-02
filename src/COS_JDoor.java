
public class COS_JDoor {
    private COS_JRoom src, dest;
    private String src_cmd, dest_cmd;

    public COS_JDoor(COS_JRoom src, String src_cmd,
		     COS_JRoom dest, String dest_cmd) {
	this.src = src;
	this.dest = dest;
	this.src_cmd = src_cmd;
	this.dest_cmd = dest_cmd;
	src.addDoor(this);
	dest.addDoor(this);
    }

    public COS_JRoom apply(COS_JRoom src, String cmd) {
	if (src == this.src) {
	    if (src_cmd.equals(cmd)) {
		return this.dest;
	    }
	}
	if (src == this.dest) {
	    if (dest_cmd.equals(cmd)) {
		return this.src;
	    }
	}
	return null;
    }

    public COS_JRoom apply(COS_JRoom src) {
	if (src==this.src) {
	    return this.dest;
	}
	if (src==this.dest) {
	    return this.src;
	}
	return null;
    }
}
