//Vs
class Visitor { public:
    virtual void visit(literal& N) {
        N.h = 1;
    }
    virtual void visit(plus& N) {
        N.h = max(N.lhs.h, N.rhs.h) + 1;
    }
};
//Ve

// The broken version
//Ts
void
traversal(Visitor& v, Tree& t) {
  for (Tree& c : t.children()) {
    traversal(v, c);
  }
  ``@v.visit(t);@
}
//Te

// The corrected version
//Tcs
void traversal(Visitor& v, Tree& t) {
  ...
  ``@!t.accept(v);@
  ...
}
//Tce

//Tacs
class literal : public Tree {
  `\tikzmark{accept}`virtual void accept(Visitor& v) {
    ``@!v.visit(*this)@
    // static type
    // this: literal*
  }
};
//Tace

//Tvcs
class HeightVisitor : public Visitor {
  `\tikzmark{visit}`virtual void visit(literal& N) {
      N.h = 1;
  }
};
//Tvce
