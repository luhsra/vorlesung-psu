#+begin_src python
class C(object):
    def __init__(self):
        self._Elements = None

    def getElements(self):
        return [Elements * 2 for Elements in self._Elements]

    def setElements(self, value):
        assert type(value) is list, "Not a list"
        self._Elements = value

    def delElements(self):
        del self._Elements

    Elements = property(getElements, setElements)

obj = C()
obj.Elements = [1,2,3]
print(obj.Elements)

obj.Elements = 4
print(obj.Elements)
#+end_src
