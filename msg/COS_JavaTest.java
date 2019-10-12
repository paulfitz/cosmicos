public class COS_JavaTest {
    private int q = 0;
    public int add(int x, int y) {
	return x + y;
    }
    public int sub(int x, int y) {
	return x - y;
    }
    public int mult(int x, int y) {
	return x * y;
    }
    public int addmult(int x, int y, int z) {
	return add(x, mult(y, z));
    }
    public void set(int x) {
	q = x;
    }
    public int get() {
	return q;
    }
    public int fact(int x) {
	return ( x> 0) ? (x * fact(sub(x, 1))) : 1;
    }
}
