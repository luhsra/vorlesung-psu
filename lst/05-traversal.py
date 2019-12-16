class literal:
  def __init__(self,token):
    self.token = token

  @property
  def children(self):
    return []

class plus:
  def __init__(self, lhs, rhs):
    self.lhs = lhs
    self.rhs = rhs

  @property
  def children(self):
    return [self.lhs, self.rhs]

tree = plus(literal(3), plus(literal(4), literal(5)))

#v0s
def height(N):
  # Jedes Kind besuchen
  for child in N.children:
    height(child)
#v0e
#v1s
  # Knotenspezifischen Code
  if isinstance(N, literal):
    h = 1
  elif isinstance(N, plus):
    lhs, rhs = N.children
    h = max(lhs.h, rhs.h)+1
#v1e
#v2s
  # Wert propagieren
  N.h = h
#v2e

height(tree)

#v3s
def height(N):
  if isinstance(N, literal):
    N.h = 1
  elif isinstance(N, plus):
    h = max(height(N.lhs),
            height(N.rhs))
    N.h = h + 1
  return N.h
#v3e

print(height(tree))


#tgs
def traversal(V, T):
  # Depth-First Order
  for child in T.children:
    traversal(V, child)

  # Introspection
  T_name = type(T).__qualname__
  M_name = "visit_" + T_name
  method = getattr(V, M_name)

  # Aufruf des Visitors
  method(T)
#tge

#vgs
class HeightVisitor:
  def visit_literal(self, N):
    N.h = 1

  def visit_plus(self, N):
    h = max(N.lhs.h,
            N.rhs.h)
    N.h = h + 1
#vge

#igs
visitor = HeightVisitor()
traversal(visitor, tree)
#ige
print(tree.h)
