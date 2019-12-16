# coding: utf-8

#V1s
class TypeVisitor:
  def visit_literal(self, T):
    # Ganzzahl-Literal
    T.Type = int
#V1e
#V2s
  def visit_addressof(self, T):
    # Typausdruck: &(op)
    T.Type = pointer(T.op.Type)
#V2e
#V3s
  def visit_add(self, T):
    L, R = T.lhs.Type, T.rhs.Type
    # Konsistenzprüfung
    if not L.equal(int) \
       or not L.equal(R):
      self.error(...)
    # Typausdruck: lhs + rhs
    T.Type = L
#V3e
