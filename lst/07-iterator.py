# coding: utf-8

#s0
class Fibonacci:
    def __init__(self):
        self.acc = (1, 1)

    def __iter__(self):
        return self

    def __next__(self):
        a, b = self.acc
        self.acc = (a+b, a)
        return a

fibs = Fibonacci()
it   = iter(fibs)
print(next(it),next(it),next(it),
      next(it),next(it),next(it))
#e0

#s1
def fib():
    a, b = 1, 1
    while True:
        yield a
        a, b = (a+b, a)

it = fib()
print(next(it),next(it),next(it),
      next(it),next(it),next(it))
#e1
