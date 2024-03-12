
.data
	terminos: .word 1
	factorial: .word 1
	size: .word 0
.text
	
	jal leer_n
	lw $t5, size
	
	li $t2, 1	
	sw $t2, terminos # 0! = 1. inicializa el termino en 1
	add $t1, $t5, $zero # inicializa el contador. $t1 = $t5 = size
	
ciclo:	lw $t3, terminos # carga el termino actual n en $t3
	lw $t4, factorial # carga el termino actual (n-1)! en $t4
	mul $t2, $t3, $t4 # $t2 = $t3 * $t4 ---> n! = n * (n-1)! 
	sw $t2, factorial # guarda el resultado del factorial en la variable factorial
	addi $t3, $t3, 1, # incrementa a $t3, n = n+1
	sw $t3, terminos
	addi $t1, $t1, -1 # decrementa el contador. contador--
	bgtz $t1, ciclo	# salta a ciclo mientras $t1 > 0
	
	jal print_factorial
	
	add $v0, $zero, 10 # salida del programa (exit)
	syscall

# procedimiento para leer los n terminos a calcular
.data
	read_msg: .asciiz "Ingrese el numero a calcular: "
.text
leer_n:
	la $a0, read_msg
	li $v0, 4 # imprime cadena
	syscall
	li $v0, 5 # lee entero
	syscall
	sw $v0, size
	jr $ra

#procedimiento para escribir el factorial
.data
	print_msg: .asciiz "El factorial es: "
.text
print_factorial:
	la $a0, print_msg
	li $v0, 4 # imprime cadena
	syscall
	lw $a0, factorial
	li $v0, 1 # imprime entero
	syscall
	jr $ra