#range0
class MemberExpr(Expr):
  # AST Kinder:
  lhs_obj    : Expr
  rhs_name   : Identifier

  # AST Attribute
  expr_type  : Type      = None
  field_decl : FieldDecl = None

  def __init__(self, L, R):
    self.lhs_obj   = L
    self.rhs_name  = R
  ...
#range1
