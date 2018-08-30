
import java.util.Iterator;

public class COS_JAction {
    private COS_JList terms = new COS_JList();

    private String str = "test1";
    
    void test() {
	if (str.equals("test1")) {
	    str = "test2";
	}
    }

    void add(int x) {
	terms.add(new Integer(x));
    }

    Iterator iterator() {
	return terms.iterator();
    }
}
