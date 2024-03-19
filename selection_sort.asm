
.data
	arreglo: .word 5, 3, 8, 9, 0, 2, 1, 4, 6, 7
	size: .word 10
	
.text
	la $t0, arreglo
	add $a0, $t0, $zero
	lw $a1, size
	
	
	
	add $a0, $t0, $zero
	addi $a1, $zero, 1 
	jal swap
	
	addi $v0, $zero, 10
	syscall


ssort:
	
	
	
	
	jr $ra


swap:
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	
	mul $t1, $a1, 4
	add $t0, $a0, $t1
	lw $t2, 0($t0)
	
	mul $t4, $t1, 2
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
	
	
	
	
