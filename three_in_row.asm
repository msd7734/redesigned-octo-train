# Constants
PRINT_INT=		1
PRINT_STRING=	4
READ_INT=		5

MIN_BSIZE=		2
MAX_BSIZE=		10
MAX_TILES=		MAX_BSIZE*MAX_BSIZE
IN_BUF_SIZE=	(MAX_TILES+1)*4			# buffer needs room for 32-bit size value

	.data
	.align 2

# Error messages
err_badsize:
	.asciiz "Invalid board size, 3-In-A-Row terminating"
	.asciiz "Illegal input value, 3-In-A-Row terminating"

# Formatting
banner:
	.ascii "******************\n"
	.ascii "**  3-In-A-Row  **\n"
	.asciiz "******************\n\n"
initpzl:
	.asciiz "Initial Puzzle\n\n"
finalpzl:
	.asciiz "Final Puzzle\n\n"
corner:
	.asciiz "+"
top:
	.asciiz "-"
side:
	.asciiz "|"
unknown:
	.asciiz "."
white:
	.asciiz " "
black:
	.asciiz "#"
newline:
	.asciiz "\n"
	
in_buf:
	.space IN_BUF_SIZE
	
	.text
	
	# External references
	# ===================
	
	# validrows.asm
	.globl valid_rows
	
	# io.asm
	.globl print_int
	.globl print_str
	.globl read_int
	
	# External definitions
	# ====================
	.globl main
	
main:
	addi	$sp, $sp, -36
	sw		$s7, 32($sp)
	sw		$s6, 28($sp)
	sw		$s5, 24($sp)
	sw		$s4, 20($sp)
	sw		$s3, 16($sp)
	sw		$s2, 12($sp)
	sw		$s1, 8($sp)
	sw		$s0, 4($sp)
	sw		$ra, 0($sp)
	
	la		$a0, banner
	jal		print_str
	
	lw		$s7, 32($sp)
	lw		$s6, 28($sp)
	lw		$s5, 24($sp)
	lw		$s4, 20($sp)
	lw		$s3, 16($sp)
	lw		$s2, 12($sp)
	lw		$s1, 8($sp)
	lw		$s0, 4($sp)
	lw		$ra, 0($sp)
	addi	$sp, $sp, 36
	
	jr		$ra
