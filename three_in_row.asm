# Constants
PRINT_INT=		1
PRINT_STRING=	4
READ_INT=		5

MIN_BSIZE=		2
MAX_BSIZE=		10
MAX_TILES=		MAX_BSIZE*MAX_BSIZE
BBUF_SIZE=		MAX_TILES*4			# board buffer

SENTINEL=		0xBAD				# 2989, 0b101110101101

	.data
	.align 2

# Error messages
err_badsize:
	.asciiz "Invalid board size, 3-In-A-Row terminating\n"
err_badinput:
	.asciiz "Illegal input value, 3-In-A-Row terminating\n"

# Message output
banner:
	.ascii "******************\n"
	.ascii "**  3-In-A-Row  **\n"
	.asciiz "******************\n\n"
initpzl:
	.asciiz "Initial Puzzle\n\n"
finalpzl:
	.asciiz "Final Puzzle\n\n"
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
	.globl print_bad_data_warn
	.globl print_template_row
	.globl print_board_hedge
	
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
	move	$s0, $v0				# s0 = board size
	
	slti	$t0, $v0, 11			# check valid size: 2 <= x <= 10
	slti	$t1, $v0, 2
	nor		$t1, $t1, $zero
	and		$t2, $t0, $t1			# 1 if in valid range
	li		$t3, 1					# ensure size is even too
	and		$t4, $v0, $t3			# size & 1 = 1 if size is odd
	xor		$t4, $t4, $t3
	and		$t2, $t2, $t4			# 1 if in valid range and even
	beq		$t2, $zero, bad_board
	
	la		$s1, bbuf				# s1 = board[MAX_TILES]
	li		$t0, 0					# i as t0 = 0
	mul		$s2, $s0, $s0			# s2 as tiles = bsize*bsize
readb_loop:
	slt		$t1, $t0, $s2			# if !(i < tiles) then loop end
	beq		$t1, $zero, readb_end
	
	jal		read_int				# v0 = read_int()
	slt		$t3, $v0, $zero			# 0 <= v0 <= 2
	nor		$t3, $t3, $zero
	slti	$t4, $v0, 3
	and		$t3, $t3, $t4
	beq		$t3, $zero, bad_input

	mul		$t2, $t0, 4				# offset as t2 = i*4
	add		$t3, $s1, $t2			# t3 = board+offset
	sw		$v0, 0($t3)				# board[i] = v0

	addi	$t0, $t0, 1				# i++
	j		readb_loop
	
readb_end:
	# pad rest of input buffer with SENTINEL value
	li		$t9, SENTINEL			# t9 = 0xBAD
	
	# reusing t0 (i) from above
padb_loop:
	slti	$t2, $t0, MAX_TILES		# if !(i < MAX_TILES) then loop end
	beq		$t2, $zero, padb_end
	
	mul		$t2, $t0, 4				# offset as t2 = i*4
	add		$t3, $s1, $t2
	sw		$t9, 0($t3)				# board[i] = SENTINEL
	
	addi	$t0, $t0, 1
	j		padb_loop
	
padb_end:
	
	la		$a0, banner		# print banner
	jal		print_str	
	
	la		$a0, initpzl
	jal		print_str
	
	la		$a0, newline
	jal		print_str
	
	j		main_done
	
bad_board:
	la		$a0, err_badsize
	jal		print_str
	j		main_done
bad_input:
	la		$a0, err_badinput
	jal		print_str
	
main_done:
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
