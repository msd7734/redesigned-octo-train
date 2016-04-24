# Constants
PRINT_INT=		1
PRINT_STRING=	4
READ_INT=		5

MIN_BSIZE=		2
MAX_BSIZE=		10
MAX_TILES=		MAX_BSIZE*MAX_BSIZE
BBUF_SIZE=		MAX_TILES*4			# board buffer

	.data
	.align 2

# Error messages
err_badsize:
	.asciiz "Invalid board size, 3-In-A-Row terminating\n"
err_badinput:
	.asciiz "Illegal input value, 3-In-A-Row terminating\n"

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

	.align 2
	
# Input buffer
bsize:
	.space 4
bbuf:
	.space BBUF_SIZE
	
	.text
	.align 2
	
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
	
	jal		read_int				# read board size
	la		$s0, bsize
	sw		$v0, 0($s0)				# store board size
	
	slti	$t0, $v0, 11			# check valid size: 2 <= x <= 10
	slti	$t1, $v0, 2
	nor		$t1, $t1, $zero
	and		$t2, $t0, $t1			# 1 if in valid range
	li		$t3, 1					# ensure size is even too
	and		$t4, $v0, $t3			# size & 1 = 1 if size is odd
	xor		$t4, $t4, $t3
	and		$t2, $t2, $t4			# 1 if in valid range and even
	beq		$t2, $zero, bad_board
	
	la		$s1, bbuf 
readb_loop:
	
	
	la		$a0, banner		# print banner
	jal		print_str	
	
	la		$a0, initpzl
	jal		print_str
	
	lw		$a0, 0($s0)
	jal		print_int
	
	la		$a0, newline
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
	
	j		main_done
	
bad_board:
	la		$a0, err_badsize
	jal		print_str
	j		main_done
bad_input:
	la		$a0, err_badinput
	jal		print_str
	
main_done:
	jr		$ra
