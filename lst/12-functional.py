from functools import partial,reduce
from math import sqrt
import inspect

def nargs(function):
    print(inspect.getfullargspec(function))

def inc(x):
    return x + 1

def compose(f, g):
    return lambda x: f(g(x))

x = compose(inc, inc)
print(x(0))

def partial(f, arg0):
    return lambda *args: f(arg0, *args)

def add(a,b):
    return a+b

inc = partial(add, 1)
print(inc(0))



points = [(-0.3,0.4),  (-0.3, -0.2),
          (0.6,-0.4),  (1, 1)]


def norm(N, point):
    coords = map(lambda c: c ** N, point)
    return sum(coords) ** (1/N)

max_distance = \
  reduce(max,
    filter(lambda d: d <= 1.0,
      map(partial(norm, 2),
          points)))
print(max_distance)
