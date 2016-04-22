# Constants
PRINT_INT=		1
PRINT_STRING=	4
READ_INT=		5

MIN_BSIZE=		2
MAX_BSIZE=		10
MAX_TILES=		MAX_BSIZE*MAX_BSIZE
IN_BUF_SIZE=	MAX_TILES+1			# buffer needs 1 byte for size input

	.data
	.align 2

pow10:
	.word 1, 10, 100, 1000, 10000
	
print0:
	.asciiz "Enter board size to check: "
print1:
	.asciiz "Possible valid rows for board size "
print2:
	.asciiz ": "
newline:
	.asciiz "\n"
	
getsize_buf:
	.space 4
	
	.text
	
	# extern ref
	.globl valid_rows
	
	# extern def
	.globl main
	
main:
	addi	$sp, $sp, -8
	sw		$s0, 4($sp)
	sw		$ra, 0($sp)
	
	la		$a0, print0
	li		$v0, PRINT_STRING
	syscall
	
	li		$v0, READ_INT
	syscall
	move	$s0, $v0

	la		$a0, print1
	li		$v0, PRINT_STRING
	syscall
	
	move	$a0, $s0
	li		$v0, PRINT_INT
	syscall
	
	la		$a0, print2
	li		$v0, PRINT_STRING
	syscall
	
	move	$a0, $s0
	jal		valid_rows
	
	lh		$a0, 0($v0)
	li		$v0, PRINT_INT
	syscall
	
	la		$a0, newline
	li		$v0, PRINT_STRING
	syscall
	
	
	
	lw		$ra, 0($sp)
	lw		$s0, 4($sp)
	addi	$sp, $sp, 8
	
	jr		$ra
