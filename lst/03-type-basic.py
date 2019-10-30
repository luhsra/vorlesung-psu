# coding: utf-8

#+begin_src python
# Built-in Types
BOOL = 0
CHAR = 1
INT  = 2

# Typkonstruktoren
def POINTER(pointee_type):
    return (100, pointee_type)

def PAIR(T1, T2):
    return (101, T1, T2)

def SET(element_type):
    return (102, element_type)

# Typausdrücke
print "char: ", CHAR
print "pointer to char:", POINTER(CHAR)
print "pair of int and set of char:", PAIR(INT, SET(CHAR))
#+end_src
