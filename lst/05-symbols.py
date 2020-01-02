#+begin_src python
class Namespace:
    def __init__(self, decl):
        # str -> decl
        self.names = {}
        # Verzeigerung von Deklaration und Namespace
        self.decl = decl

    def createName(self, name, decl):
        self.names[name] = decl

    def findName(self, name):
        if name in self.names:
            return self.names[name]
        else:
            return None

    def __repr__(self):
        return "[%s: %s]" %(self.decl, self.names)

class SymbolTable:
    def __init__(self):
        self.namespaces = []

    def openNamespace(self, decl):
        NS = Namespace(decl)
        self.namespaces.append(NS)

    def closeNamespace(self, decl):
        NS = self.namespaces.pop()
        assert NS.decl == decl

    def createName(self, name, decl):
        # self.namespace[-1] ist das letzte Element der Liste!
        self.namespaces[-1].createName(name, decl)

    def findName(self, name):
        i = len(self.namespaces)
        while i > 0:
            i = i - 1
            decl = self.namespaces[i].findName(name)
            if decl != None:
                return decl
        raise RuntimeError("Name %s not found" % name)

    def __repr__(self):
        return "\n".join([repr(x) for x in self.namespaces])



ST = SymbolTable()

# pre_Namespace(A)
ST.openNamespace("A")

# pre_VarDecl(B)
ST.createName("tmp", "B")

# pre_Namespace(C)
ST.createName("math", "C")
ST.openNamespace("C")

# pre_Namespace(D)
ST.createName("fib", "D")
ST.openNamespace("D")

# pre_VarDecl(E)
ST.createName("tmp", "E")

# pre_DeclRef(F)
decl = ST.findName("tmp")
print("Decl: " + decl)
print("Symbol Table:")
print(repr(ST))
#+end_src

