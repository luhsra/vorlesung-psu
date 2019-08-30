#sub0
i, j = 7, 35
while i != j:
  if i > j: i -= j
  else:     j -= i
#sub1
  print(i,j)


print("---")
#mod0
i, j = 7, 35
while i != 0:
  i,j = j % i, i
#mod1
  print(i,j)
