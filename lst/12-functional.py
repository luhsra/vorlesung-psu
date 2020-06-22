from functools import partial
import inspect

def nargs(function):
    print(inspect.getfullargspec(function))

def compose(*functions):
    def composed(*args):
        for func in functions:
            args = [func(*args)]
        return args[0]
    composed.__str__ = lambda: "<asdasd>"
    return composed

nargs(lambda a, b: a)
nargs(compose(lambda a, b: a))
