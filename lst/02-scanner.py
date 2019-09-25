# coding: utf-8

#+begin_src python

class Stream:
    """Eine (ineffiziente) Abstraktion fuer einen Eingabestrom aus Zeichen,
       die es erlaubt ein einzelnes Zeichen in die Zukunft zu blicken
       (look-ahead).
    """
    def __init__(self, data):
        self.data = list(data)

    def peek(self):
        if len(stream.data) == 0:
            return '\0'
        return stream.data[0]

    def read(self):
        if len(self.data) == 0:
            return '\0'
        return self.data.pop(0)

    def read_many(self, allowed_characters):
        ret = ""
        while self.peek() in allowed_characters:
            ret += self.read()
        return ret


#scanner0
def scanner_next(stream):
    # Leerzeichen vom Anfang wegwerfen
    while stream.peek() in " \t":
        stream.read()

    ch = stream.read()
    if ch == '0': # literal: hex, oktal, oder binär
        ch = stream.read()
        if ch == 'x':
            hexdigits = "0123456789abcdefABCDEF"
            chars = stream.read_many(hexdigits)
            value = int(chars, base=16)
            return ["literal", value]
        # ....
#scanner1
        elif ch == 'b':
            chars = stream.read_many('01')
            value = int(chars, base=2)
            return ['literal', value]
        elif ch in '01234567':
            chars  = ch + stream.read_many('01234567')
            value = int(chars, 8)
            return ['literal', value]
#scanner2
        else:
            raise ScannerError("invalid character")
#scanner3

stream = Stream("0x17 027 0b10111 0777")

while True:
    token = scanner_next(stream)
    if token is None:
        break
    print(repr(token))
#+end_src
