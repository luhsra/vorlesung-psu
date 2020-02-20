.text
main:
  push	%ebp
  mov	%esp, %ebp
  push  $6
  call  fib
  add   $4, %esp
  leave
  ret

.data
global_var:
  .long 23
