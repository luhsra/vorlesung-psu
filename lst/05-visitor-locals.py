def dispatch(obj, name, args, locals=None):
    m = getattr(obj, name)
    print(m.__func__.__code__)
    exec(m.__func__.__code__,)
    help(m.__call__)
    
class TypeVisitor:
    def pre_literal(self, T):
        foo = 23

    def post_literal(self, T):
        print(foo)

visitor = TypeVisitor()

visitor_locals = {}
dispatch(visitor, "pre_literal", [], locals=visitor_locals)
print(visitor_locals)
dispatch(visitor, "post_literal", [], locals=visitor_locals)
