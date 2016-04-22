# syscalls
PRINT_INT=		1
PRINT_STRING=	4
READ_INT=		5
FOPEN=			13
FWRITE=			14
FCLOSE=			16

# file modes
O_RDONLY=		0
O_WRONLY=		1
O_RDWR=			2

	.text

print_int:
	li		$v0, PRINT_INT
	syscall
	jr		$ra

print_str:
	li		$v0, PRINT_STRING
	syscall
	jr		$ra
	
read_int:
	li		$v0, READ_INT
	syscall
	jr		$ra