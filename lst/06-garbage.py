import sys
import gc

x = [object()]

print("Refcount:",
      sys.getrefcount (x))
print("x -> *:",
      gc.get_referents(x))
print("* ->: x",
      gc.get_referrers(x))
print("Objects:",
      len(gc.get_objects()))

