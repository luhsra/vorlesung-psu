//Vs
class Visitor { public:
    virtual void visit(literal N) {
        N.h = 1;
    }
    virtual void visit(plus N) {
        N.h = max(N.lhs.h, N.rhs.h) + 1;
    }
};
//Ve

//Ts
void
traversal(Visitor v, Tree t) {
  for (Tree c : t.children()) {
    traversal(v, c);
  }
  ``@v.visit(c);@
}
//Te
