
#+begin_src python
class Elem:
    counter = 0
    def __init__(self, value, next):
        self.__id__ = Elem.counter
        Elem.counter +=1

        self.value = value
        self.next = next

    def __str__(self):
        return "([#%s] %s %s)" %(self.__id__, self.value, self.next)


def cat(value, list):
    """Vorne an die List anhaengen"""
    return Elem(value, list)

list_x = cat(2, cat(3, cat(4, None)))
list_y = cat(1, list_x)

print "list_x=", list_x
print "list_y=", list_y

def setnth(list, nth, value):
    """Das n-te Element setzen"""
    if nth == 0:
        return Elem(value, list.next)
    else:
        return Elem(list.value,
                 setnth(list.next,
                        nth - 1,
                        value))

list_xx = setnth(list_y, 1, 400)
print "list_xx=", list_xx
#+end_src
