import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSet implements State {
    private AtomicIntegerArray value;
    private byte maxval;

    private void cp(byte[] v){
	int len = v.length;
	value = new AtomicIntegerArray(len);
	for (int k = 0; k < len; k++){
	    value.set(k, v[k]);
	}
    }

    private byte[] rcp(){
	byte[] v = new byte[size()];
	for (int k = 0; k < size(); k++) {
	    v[k] = (byte) value.get(k);
	}
	return v;
    }

    GetNSet(byte[] v) { cp(v);  maxval = 127; }

    GetNSet(byte[] v, byte m) { cp(v); maxval = m; }

    public int size() { return value.length(); }

    public byte[] current() { return rcp(); }

    public boolean swap(int i, int j) {
	if (value.get(i) <= 0 || value.get(j) >= maxval) {
	    return false;
	}
	value.set(i, value.get(i)-1);
	value.set(j, value.get(j)+1);
	return true;
    }
}
