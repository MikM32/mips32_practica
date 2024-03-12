
.data
	cad: .asciiz "Waza"
	

.text
	li $v0, 5
	syscall
	move $a1, $v0
	li $v0, 55
	la $a0, cad
	syscall
	li $v0, 10
	syscall
	
