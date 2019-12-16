#ts
def traversal(V, T):
    # V.pre_<DynamicTypeName>(T)
    dispatch(V, "pre_", T)

    for child in T.children:
        traversal(V, child)

    # V.post_<DynamicTypeName>(T)
    dispatch(V, "post_", T)
#te
#V1s
class NameVisitor:
  def __init__(self):
    self.ST = SymbolTable()
#V1e
#V2s
  def pre_NamespaceDecl(self, NS):
    self.ST.openNamespace(NS)

  def post_NamespaceDecl(self, NS):
    self.ST.closeNamespace(NS)
#V2e
#V3s
  def pre_VarDecl(self, D):
    N = D.identifier
    self.ST.createName(N, D)
#V3e
#V4s
  def pre_DeclRefExpr(self, T):
    N = R.identifier
    decl = self.ST.findName(N)
    R.decl = decl
#V4e
