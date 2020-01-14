#+begin_src python


Intern_Str2Value = {}
Intern_Value2Str = {}


def Intern(value):
    global Intern_Str2Value
    global Intern_Value2Str

    if value not in Intern_Str2Value:
        ret = len(Intern_Str2Value)
        # Bi-Directional Mapping
        Intern_Str2Value[value] = ret
        Intern_Value2Str[ret] = value
    else:
        ret = Intern_Str2Value[value]
    return ret

def InternString(value):
    global Intern_Value2Str
    return Intern_Value2Str[value]

x = Intern("foo")
y = Intern("bar")
z = Intern("foo")

print x,y,z
print InternString(x), InternString(y), InternString(z)
print Intern_Str2Value
print Intern_Value2Str

#+end_src
