
public class COS_JThing extends COS_JNamed {
    private COS_JRoom location;
    private COS_JRoom nextLocation;

    public void setRoom(COS_JRoom location) {
	if (this.location!=null) {
	    this.location.removeThing(this);
	}
	this.location = location;
	location.addThing(this);
	this.nextLocation = location;
    }
    
    public COS_JRoom getRoom() {
	return location;
    }

    public void setNextRoom(COS_JRoom location) {
	nextLocation = location;
    }

    public void postUpdate() {
	if (nextLocation!=location) {
	    setRoom(nextLocation);
	}
    }
}

