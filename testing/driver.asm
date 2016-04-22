
# Constants
PRINT_INT=		1
PRINT_STRING=	4

MIN_BSIZE=		2
MAX_BSIZE=		10
MAX_TILES=		MAX_BSIZE*MAX_BSIZE
IN_BUF_SIZE=	MAX_TILES+1
	
	.data
	.align 2

newline:
	.asciiz "\n"
	
size_msg:
	.asciiz "Table size: "

rowval_msg:
	.asciiz "Row values: "
	
	.text
	.align 2
	
	.globl main
	
	.globl row_bsize2
	.globl row_bsize3
	.globl row_bsize4
	.globl row_bsize5
	.globl row_bsize6
	.globl row_bsize7
	.globl row_bsize8
	.globl row_bsize9
	.globl row_bsize10
	
main:
	addi	$sp, $sp, -4
	sw		$ra, 0($sp)
	
	li		$v0, PRINT_STRING
	la		$a0, size_msg
	syscall
	
	la		$t0, row_bsize2
	
	li		$v0, PRINT_INT
	lh		$a0, 0($t0)
	syscall
	
	li		$v0, PRINT_STRING
	la		$a0, newline
	syscall
	
	lw		$ra, 0($sp)
	addi	$sp, $sp, 4
	
	jr		$ra

