
.text
#pasando parametros al stack
main: 
	li $t0, 2
	addi $sp, $sp, -8	# reservo dos espacios en el stack
	sw $t0, 4($sp)
	
	li $t0, 4
	sw $t0, 0($sp)
	jal suma
	
	li $v0, 10
	syscall

suma:
	addi $sp, $sp, -4
	sw $ra, 0($sp)		# push $ra

	lw $t0, 8($sp)
	lw $t1, 4($sp)
	
	add $v0, $t0, $t1
	
	lw $ra, 0($sp)		# pop $ra
	addi $sp, $sp, 4
	
	jr $ra

resta:

