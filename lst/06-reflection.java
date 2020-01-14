import java.lang.reflect.*;

class Object {
    public static void main(String[] args) throws Exception {
        Field value = Integer.class.getDeclaredField("value");
        value.setAccessible(true);
        value.set(42, 43);
        System.out.printf("Six times Seven = %d%n", 6 * 7);
    }
}
