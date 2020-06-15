# coding: utf-8

#s0
class FancyList(list):
  def __iter__(self):
    return PairIterator(self)

class PairIterator:
  def __init__(self, seq):
    self.seq = seq[:]

  def __next__(self):
    if not self.seq:
       raise StopIteration
        ret = self.seq[0:2]
    del self.seq[0:2]
    return ret

for p in FancyList([1,2,3,4]):
  print(p)
#e0

#s1
def pairs(seq):
  i = 0
  while i + 1 < len(seq):
    yield seq[i:i+2]
    i += 2

for pair in pairs([1,2,3,4]):
  print(pair)
#e1


def pairs(seq):
  it = iter(seq)
  try:
    while True:
      yield [next(it), next(it)]
  except StopIteration:
      pass

for pair in pairs([1,2,3,4]):
  print(pair)
