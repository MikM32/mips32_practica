### Text segment
        .text
start:
        la      $a0, matrix_4x4   # a0 = A (base address of matrix)
        li      $a1, 4             # a1 = N (number of elements per row)
                                    # <debug>
        jal     print_matrix        # print matrix before elimination
        nop                         # </debug>
        jal     eliminate           # triangularize matrix!
        nop                         # <debug>
        
        jal     print_matrix        # print matrix after elimination
        nop                         # </debug>
        jal     exit
	nop
exit:
        li      $v0, 10             # specify exit system call
        syscall                     # exit program

################################################################################
# eliminate - Triangularize matrix.
#
# Args:     $a0  - base address of matrix (A)
#           $a1  - number of elements per row (N)

########################
## t0 = k              #
## t1 = j              #
## t2 = i              #
## t3 = addr (A[k][k]) #
## t4 = 1.0 (single)   #
## t5 = addr (A[i][k]) #
## t6 = addr (A[k][j]) #
## t7 = addr (A[k][k]) #
## v0 = addr (A[i][j]) #
##                     #
## f0 = A[k][k]        #
## f1 = A[k][j]        #
## f2 = A[i][k]        #
## f3 = A[k][j]        #
##                     #
## s0 = addr (row k)   #
## s1 = addr (col k)   #
## s3 = addr (row j)   #
## s4 = addr (row i)   #
########################

eliminate:
        # If necessary, create stack frame, and save return address from ra
        #addiu   $sp, $sp, -4        # allocate stack frame
        #sw      $ra, 0($sp)         # done saving registers


        ## START ##
        addiu   $t0, $zero, 0       # number of diagonal elements
                                    # k, k is used in loop for 
                                    # number of diagonal elements
        
        addiu	$s6, $a1, -1                    
        addiu   $t4, $zero, 1065353216     
        			    # 1.0 = 00111111100000000000000000000000 base 2 
                                    # = 1065353216 base 10
                                    # does this work? Apparently it does
		
diagonal:                           # for (k = 0; k < N; k++)
                                    # loop over all diagonal (pivot) elements
        addiu   $t1, $t0, 1         # j = k + 1
        
        sll     $s2, $a1, 2         # s2 = 4*N (number of bytes per row)
        multu   $t0, $s2            # result will be 32-bit unless the matrix is huge
        mflo    $s1                 # s1 = a*s2
        addu    $s1, $s1, $a0       # Now s1 contains address to row a
        sll     $s0, $t0, 2         # s0 = 4*b (byte offset of column b)
        addu    $t3, $s1, $s0       # Now we have address to A[a][b] in t3...
        lwc1    $f0, 0($t3)         # ... and contents of A[a][b] in f0.
        
        
rightofpivotelem:                   # for (j = k + 1; j < N; j++)
                                    # for all elements in pivot row
                                    # and right of pivot element
        ## A[k][j]
        ## same row so we can reuse previous row calculation 
        sll     $s5, $t1, 2         # s0 = 4*b (byte offset of column b)
        addu    $t5, $s1, $s5       # Now we have address to A[a][b] in t5...
        lwc1    $f1, 0($t5)         # ... and contents of A[a][b] in f1.
        
        addiu   $t1, $t1, 1         # j++ 
        
        ##
        ## A[k][j] / A[k][k]
        div.s   $f1, $f1, $f0       # from coprocessor! Very slow! 
        ## f1 = f1 / f0
        ##
	
	                    # j < N
        bne     $t1, $a1, rightofpivotelem
        swc1    $f1, 0($t5)         # save in matrix
        
        ##
        ## A[k][k] = 1
        sw      $t4, 0($t3)         # store in matrix
        ## t4 = 1.0
        ##   
        addiu   $t2, $t0, 1         # i = k + 1
                
	
rightofpivotcol:
                                    # used in inner loop for(j = k + 1)...
        addiu   $t1, $t0, 1         # j = k + 1 again

        # A[i][k]
        # this time adress to column k has been calculated before so we can reuse
        sll     $s2, $a1, 2         # s2 = 4*N (number of bytes per row)
        multu   $t2, $s2            # result will be 32-bit unless the matrix is huge
        mflo    $s3                 # s1 = a*s2
        addu    $s3, $s3, $a0       # Now s3 contains address to row a
        addu    $t6, $s3, $s0       # Now we have address to A[a][b] in t6...
        lwc1    $f2, 0($t6)         # ... and contents of A[a][b] in f2.

	addu	$t7, $t6, $zero
	
rightofpivotcolinner:               # (for i = k + 1; i < N; i++)
      
        ## A[i][j]
        ## same row as before so reuse
        sll     $s4, $t1, 2         # s0 = 4*b (byte offset of column b)
        addu    $t7, $s3, $s4       # Now we have address to A[a][b] in v0...
        lwc1    $f3, 0($t7)         # ... and contents of A[a][b] in f0.	
	
        ## A[k][j]
        ## adress to both row and column are known so all we need to do is add them together
        addu    $v0, $s1, $s4       # Now we have address to A[a][b] in v0...
        lwc1    $f4, 0($v0)         # ... and contents of A[a][b] in f0.        
        
        addiu   $t1, $t1, 1         # j ++
        
        ##
        ## A[i][j] - A[i][k] * A[k][j]
        mul.s   $f4, $f2, $f4
        sub.s   $f4, $f4, $f3       # maybe switch places?
        ##
        ##
     
                                    # j < N
                                    # blt is a pseudoinstruction
        
        bne     $t1, $a1, rightofpivotcolinner
        swc1    $f4, 0($t7)         # save in matrix
        
        addiu   $t2, $t2, 1         # i ++
                                    # i < N
                                    # blt is a pseudoinstruction
        bne     $t2, $a1, rightofpivotcol
        ##  
        ## A[i][k] = 0
        sw      $zero, 0($t6)       # store 0 at adress in v0       
        ## 
        ## $t5 = adress to A[i][k]
        
        addiu   $t0, $t0, 1     # k ++
                                # k < N

        bne     $t0, $s6, diagonal 
        nop
 
        sll     $s2, $a1, 2         # s2 = 4*N (number of bytes per row)
        multu   $t0, $s2            # result will be 32-bit unless the matrix is huge
        mflo    $s1                 # s1 = a*s2
        addu    $s1, $s1, $a0       # Now s1 contains address to row a
        sll     $s0, $t0, 2         # s0 = 4*b (byte offset of column b)
        addu    $t3, $s1, $s0       # Now we have address to A[a][b] in t3...
        
        sw	$t4, 0($t3)
        
        #lw      $ra, 0($sp)         # done restoring registers
        #addiu   $sp, $sp, 4         # remove stack frame

        jr      $ra                 # return from subroutine
        nop                         # this is the delay slot associated with all types of jumps
	## END ##
     
################################################################################
# print_matrix
#
# This routine is for debugging purposes only. 
# Do not call this routine when timing your code!
#
# print_matrix uses floating point register $f12.
# the value of $f12 is _not_ preserved across calls.
#
# Args:     $a0  - base address of matrix (A)
#           $a1  - number of elements per row (N) 
print_matrix:
        addiu   $sp,  $sp, -20      # allocate stack frame
        sw      $ra,  16($sp)
        sw      $s2,  12($sp)
        sw      $s1,  8($sp)
        sw      $s0,  4($sp) 
        sw      $a0,  0($sp)        # done saving registers

        move    $s2,  $a0           # s2 = a0 (array pointer)
        move    $s1,  $zero         # s1 = 0  (row index)
loop_s1:
        move    $s0,  $zero         # s0 = 0  (column index)
loop_s0:
        l.s     $f12, 0($s2)        # $f12 = A[s1][s0]
        li      $v0,  2             # specify print float system call
        syscall                     # print A[s1][s0]
        la      $a0,  spaces
        li      $v0,  4             # specify print string system call
        syscall                     # print spaces

        addiu   $s2,  $s2, 4        # increment pointer by 4

        addiu   $s0,  $s0, 1        # increment s0
        blt     $s0,  $a1, loop_s0  # loop while s0 < a1
        nop
        la      $a0,  newline
        syscall                     # print newline
        addiu   $s1,  $s1, 1        # increment s1
        blt     $s1,  $a1, loop_s1  # loop while s1 < a1
        nop
        la      $a0,  newline
        syscall                     # print newline

        lw      $ra,  16($sp)
        lw      $s2,  12($sp)
        lw      $s1,  8($sp)
        lw      $s0,  4($sp)
        lw      $a0,  0($sp)        # done restoring registers
        addiu   $sp,  $sp, 20       # remove stack frame

        jr      $ra                 # return from subroutine
        nop                         # this is the delay slot associated with all types of jumps

### End of text segment

### Data segment 
        .data

### String constants
spaces:
        .asciiz "   "               # spaces to insert between numbers
newline:
        .asciiz "\n"                # newline
        
## Input matrix: (4x4) ##
matrix_4x4: 
        .float 57.0
        .float 20.0
        .float 34.0
        .float 59.0
        
        .float 104.0
        .float 19.0
        .float 77.0
        .float 25.0
        
        .float 55.0
        .float 14.0
        .float 10.0
        .float 43.0
        
        .float 31.0
        .float 41.0
        .float 108.0
        .float 59.0
        
        # These make it easy to check if 
        # data outside the matrix is overwritten
        .word 0xdeadbeef
        .word 0xdeadbeef
        .word 0xdeadbeef
        .word 0xdeadbeef
        .word 0xdeadbeef
        .word 0xdeadbeef
        .word 0xdeadbeef
        .word 0xdeadbeef

test:	
	.float 0.0
	.float 0.0