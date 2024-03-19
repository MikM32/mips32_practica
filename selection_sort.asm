
.data
	arreglo: .word 5, 3, 8, 9, 0, 2, 1, 4, 6, 7
	size: .word 10
	
.text
	la $t0, arreglo
	add $a0, $t0, $zero
	lw $a1, size
	
	addi $a1, $zero, 10
	jal ssort
	
	#add $a0, $t0, $zero
	#addi $a1, $zero, 1 
	#jal swap
	
	addi $v0, $zero, 10
	syscall


ssort:
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $s2, $zero ,0
	addi $s3, $a1, -1
for1:	add $s4, $s2, $zero
		
	addi $s5, $s4, 1
	add $s6, $a1, $zero
for2:	mul $t4, $s5, 4
	add $t4, $t4, $a0
	lw $t4, 0($t4)
	
	mul $t5, $s4, 4
	add $t5, $t5, $a0
	lw $t5, 0($t5)
	
	slt $t8, $t4, $t5
	bne $t8, 1, else
	
	add $s4, $s5, $zero
	
else:	addi $s5, $s5, 1
	slt $t7, $s5, $s6
	bne $t7, $zero, for2
	
	
	add $s0, $a0, $zero
	add $s1, $a1, $zero
	
	add $a1, $zero, $s2
	add $a2, $zero, $s4
	jal swap

	addi $s2, $s2, 1
	slt $t6, $s2, $s3
	bne $t6, $zero, for1
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra


swap:
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	
	mul $t1, $a1, 4
	add $t0, $a0, $t1
	lw $t2, 0($t0)
	
	mul $t4, $a2, 4
	add $t0, $a0, $t4
	lw $t3, 0($t0)
	
	sw $t2, 0($t0)
	add $t0, $a0, $t1
	sw $t3, 0($t0)
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	
	jr $ra
	
	
	
	
