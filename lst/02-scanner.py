# coding: utf-8

import io
import string

def stream_peek(stream):
    if stream.tell() >= len(stream.getvalue()):
        return "\0"
    return stream.getvalue()[stream.tell()]

def stream_read(stream):
    return stream.read(1)

def stream_read_many(stream, allowed_characters):
    ret = ""
    while stream_peek(stream) in allowed_characters:
        ret += stream.read(1)
    return ret


#scanner0
def scanner_next(stream):
    # Leerzeichen vom Anfang wegwerfen
    while stream_peek(stream) in " \t":
        stream_read(stream)

    ch = stream_read(stream)
    if ch == '0': # literal: hex, oktal, oder binär
        ch = stream_read(stream)
        if ch == 'x':
            hexdigits = "0123456789abcdefABCDEF"
            chars = stream_read_many(stream, hexdigits)
            value = int(chars, base=16)
            return ["literal", value]
        # ....
#scanner1
        elif ch == 'b':
            chars = stream_read_many(stream, string.hexdigits)
            value = int(chars, base=2)
            return ['literal', value]
        elif ch in string.octdigits:
            chars  = ch + stream_read_many(stream, string.octdigits)
            value = int(chars, 8)
            return ['literal', value]
#scanner2
        else:
            raise ScannerError("invalid character)
#scanner3

stream = io.StringIO("0x17 027 0b10111 0a")

while True:
    token = scanner_next(stream)
    if token is None:
        break
    print(repr(token))
