 .data
N: .word  3
M: .word  2
P: .word  4
A: .word  1, 2, 3, 4, 5, 6         # { {1, 2}, {3, 4}, {5, 6} }
B: .word  8, 7, 6, 5, 4, 3, 2, 1   # { {8, 7, 6, 5}, {4, 3, 2, 1} }
C: .space 48
 
 .text
  
multiply:
  # Register usage:
  # n is $s0, m is $s1, p is $s2,
  # r is $s3, c is $s4, i is $s5,
  # sum is $s6

  # Prologue
  sw   $fp, -4($sp)
  la   $fp, -4($sp)
  sw   $ra, -4($fp)
  sw   $s0, -8($fp)
  sw   $s1, -12($fp)
  sw   $s2, -16($fp)
  sw   $s3, -20($fp)
  sw   $s4, -24($fp)
  sw   $s5, -28($fp)
  sw   $s6, -32($fp)
  addi $sp, $sp, -36

  # Save arguments
  move $s0, $a0             # n
  move $s1, $a1             # m
  move $s2, $a2             # p

  li   $s3, 0               # r = 0
  li   $t0, 4               # sizeof(Int)

mult_loop:
  bge  $s3, $s0, mult_end   # if r >= n, branch
  li   $s4, 0               # c = 0

mult_loop2:
  bge  $s4, $s2, mult_end2  # if c >= p, branch
  li   $s6, 0               # int sum = 0;
  j    mult_loop3

mult_store:
  mul  $t3, $s3, $s2        # t3 = r * p
  mul  $t3, $t3, $t0        # t3 = t3 * 4
  mul  $t4, $s4, $t0        # t4 = c * 4
  add  $t3, $t3, $t4        # t3 = t3 * t4 = (r * p * 4) + (c * 4)
  sw   $s6, C($t3)          # C[r][c] = sum;

  addi $s4, $s4, 1          # c++

  li   $s5, 0               # i = 0
  j    mult_loop2

mult_loop3:
  bge  $s5, $s1, mult_store # if i >= m, branch

  # A[r][i]
  mul  $t5, $s3, $s1        # t5 = r * m
  mul  $t5, $t5, $t0        # t5 = t5 * 4
  mul  $t6, $s5, $t0        # t6 = i * 4
  add  $t5, $t5, $t6        # t5 = (r * m * 4) + (i * 4)
  lw   $t5, A($t5)

  # B[i][c]
  mul  $t7, $s5, $s2        # t7 = i * n
  mul  $t7, $t7, $t0        # t7 = t7 * 4
  mul  $t8, $s4, $t0        # t8 = 4 * c
  add  $t7, $t7, $t8        # t7 = (i * n * 4) + (c * 4)
  lw   $t7, B($t7)

  mul  $t7, $t5, $t7        # t7 = t5 * t7
  add  $s6, $s6, $t7        # sum = sum + t7

  addi $s5, $s5, 1          # i++
  j    mult_loop3

mult_end2:
  addi $s3, $s3, 1          # r++
  j    mult_loop

mult_end:
  # Epilogue
  lw   $ra, -4($fp)
  lw   $s0, -8($fp)
  lw   $s1, -12($fp)
  lw   $s2, -16($fp)
  lw   $s3, -20($fp)
  lw   $s4, -24($fp)
  lw   $s5, -28($fp)
  lw   $s6, -32($fp)
  la   $sp, 4($fp)
  lw   $fp, ($fp)
  jr   $ra