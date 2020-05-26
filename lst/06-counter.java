class Counter {
  final int start;
  int next;       // `\dn{4}`

  public Counter(int n) {
    start = n;    // `\dn{3}`
  }

  public Counter() {
      start = 0;
  }

  public int inc() {
      return start+(next++);
  }
}
class Derived
     extends Counter {
  Derived(int x) {
      super(3+x); // `\dn{2}`
  }
  Derived(String s) { // `\dn{1}`
      this(parseInt(s));
  }
}
