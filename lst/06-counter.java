class Counter {
  final int start;
  int next;

  public Counter(int n) {
    start = n;    // `\dn{1}`
  }
  public Counter()  {
    this(0);      // `\dn{2}`
  }
  
  public int inc() {
      return start+(next++);
  }
}

class Derived extends Counter {
  Derived() { }   // `\dn{3}`
  Derived(int x) { 
      super(3+x); // `\dn{4}`
  }
  Derived(String s) {
    this(Integer.parseInt(s));
  }
}
