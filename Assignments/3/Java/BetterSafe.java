//better performance than Synchronized while retaining 100% reliability
//let's try to use locking https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/locks/ReentrantLock.html

import java.util.concurrent.locks.ReentrantLock;

class BetterSafe implements State {
    private byte[] value;
    private byte maxval;
    private final ReentrantLock lock = new ReentrantLock();

    BetterSafe(byte[] v) { value = v; maxval = 127; }

    BetterSafe(byte[] v, byte m) { value = v; maxval = m; }

    public int size() { return value.length; }

    public byte[] current() { return value; }

    public boolean swap(int i, int j) {
	lock.lock();
        if (value[i] <= 0 || value[j] >= maxval) {
            lock.unlock(); return false;
        }
        value[i]--;
        value[j]++;
	lock.unlock();
        return true;
    }
}
