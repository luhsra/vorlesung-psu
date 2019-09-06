# r2: a
bb0:
  ld t0, $b
  bgt r2, t0, bb1
  j bb2
bb1:
  mv a0, r2
  j bb3
bb2:
  ld a0, $b
bb3:
  ret
