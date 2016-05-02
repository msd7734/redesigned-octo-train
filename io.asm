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

# SENTINEL
SENTINEL=		0xBAD				# 2989, 0b101110101101

	.data
	.align 2
	
	# formatting
unknown:
	.asciiz "."
white:
	.asciiz " "
black:
	.asciiz "#"
corner:
	.asciiz "+"
top:
	.asciiz "-"
side:
	.asciiz "|"
	
	.align 2
	
	# format symbol tbl
symbols:
	.word unknown
	.word white
	.word black
	
	
	# messages
bad_data_msg:
	.asciiz "!! WARNING: SENTINEL READ AT ADDR "
bad_data_noaddr:
	.asciiz "[No address given]"
newline:
	.asciiz "\n"
	
	.text
	.align 2
	
	.globl newline
	
	.globl print_int
	.globl print_str
	.globl read_int
	
	.globl print_bad_data_warn
	
	.globl print_template_row
	.globl print_board_hedge
	.globl print_template
	.globl print_bstate
	.globl print_bstate_row
	
#############################
# print_bad_data_warn
# Print warning that a SENTINEL indicating bad data has been read.
# Note: Feel free to put a break point here for even more useful debug info.
# Args:
#  a0 - Address at which the value occured. Either the PC or the mem address,
#		whatever your little heart desires. Or 0, if providing no address.
#############################
print_bad_data_warn:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)

	move	$t0, $a0
	la	$a0, bad_data_msg
	jal	print_str
	beq	$t0, $zero, pbdw_noaddr
	move	$a0, $t0
	jal	print_int
	j	pbdw_done
pbdw_noaddr:
	la	$a0, bad_data_noaddr
	jal	print_str
pbdw_done:
	la	$a0, newline
	jal	print_str
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
print_int:
	li	$v0, PRINT_INT
	syscall
	jr	$ra

print_str:
	li	$v0, PRINT_STRING
	syscall
	jr	$ra
	
read_int:
	li	$v0, READ_INT
	syscall
	jr	$ra

#############################
# print_template_row
# Print the string representation of a board template row.
# Args:
#  a0 - Length of the row
#  a1 - Ptr to row data words
#############################
print_template_row:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	li	$t0, 0			# t0 as i = 0
	move	$t1, $a0		# t1 as len = a0
	move	$t2, $a1		# t2 as data* = a1
	la	$t3, symbols		# t3 as symtbl* = symbols&
	
ptr_loop:
	slt	$t4, $t0, $t1		# if !(i < len), done
	beq	$t4, $zero, ptr_done
	
	mul	$t4, $t0, 4		# t4 as offset = i*4
	add	$t4, $t4, $t2		# t4 = data+offset
	lw	$t5, 0($t4)		# t5 = data[i]
	
	li	$t6, SENTINEL		# reading bad data?
	beq	$t5, $t6, ptr_loop_break
	
	mul	$t6, $t5, 4		# t6 as offset = t5 * 4
	add	$t6, $t3, $t6		# t6 = symtbl+offset
	lw	$a0, 0($t6)		# get print symbol from symtbl (a0 = symtbl[data])
	jal	print_str
	
	addi	$t0, $t0, 1
	j	ptr_loop
	
ptr_loop_break:
	move	$a0, $t4		# print_bad_data_warn(data&)
	jal	print_bad_data_warn
	
ptr_done:	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
#############################
# print_template
# Print the string representation of a board template (the "initial puzzle")
# Args:
#  a0 - Length of a row (and a column)
#  a1 - Ptr to board template data structure
#############################
print_template:
	addi	$sp, $sp, -16
	sw	$s2, 12($sp)
	sw	$s1, 8($sp)
	sw	$s0, 4($sp)
	sw	$ra, 0($sp)
	
	move	$s0, $a0
	move	$s1, $a1
	
	jal	print_board_hedge
	
	la	$a0, newline
	jal	print_str
	
	li	$s2, 0			# s2 as i = 0
pt_loop:
	slt	$t1, $s2, $s0
	beq	$t1, $zero, pt_done
	
	la	$a0, side
	jal	print_str
	
	mul	$t1, $s2, $s0		# t1 as row = i * length
	mul	$t1, $t1, 4		# t1 as offset = row * 4
	add	$a1, $t1, $s1		# board + offset
	move	$a0, $s0
	jal	print_template_row
	
	la	$a0, side
	jal	print_str
	
	la	$a0, newline
	jal	print_str
	
	addi	$s2, $s2, 1
	j	pt_loop


pt_done:
	move	$a0, $s0
	jal	print_board_hedge

	la	$a0, newline
	jal	print_str
	
	sw	$s2, 12($sp)
	lw	$s1, 8($sp)
	lw	$s0, 4($sp)
	lw	$ra, 0($sp)
	addi	$sp, $sp, 16
	jr	$ra
	
#############################
# print_bstate
# Print the (non-template) board state.
# Args:
#  a0 - Length of a board side
#  a1 - Pointer series to halfwords representing rows.
#############################	
print_bstate:
	addi	$sp, $sp, -16
	sw	$s2, 12($sp)
	sw	$s1, 8($sp)
	sw	$s0, 4($sp)
	sw	$ra, 0($sp)
	
	move	$s0, $a0	# s0 = len
	move	$s1, $a1	# s1 = board*
	
	jal	print_board_hedge
	la	$a0, newline
	jal	print_str
	
	li	$s2, 0		# s2 as i = 0
	
pbs_loop:
	slt	$t0, $s2, $s0
	beq	$t0, $zero, pbs_done
	
	la	$a0, side
	jal	print_str
	
	move	$a0, $s0
	
	mul	$t1, $s2, 2
	add	$t2, $s1, $t1
	lh	$a1, 0($t2)
	move	$a0, $s0
	jal	print_bstate_row
	
	la	$a0, side
	jal	print_str
	
	la	$a0, newline
	jal	print_str
	
	addi	$s2, $s2, 1
	j	pbs_loop
pbs_done:
	move	$a0, $s0
	jal 	print_board_hedge
	
	sw	$s2, 12($sp)
	lw	$s1, 8($sp)
	lw	$s0, 4($sp)
	lw	$ra, 0($sp)
	addi	$sp, $sp, 16
	jr	$ra

#############################
# print_bstate_row
# Print a row from a "real" (non-template) board.
# Args:
#  a0 - Length of a board row
#  a1 - Integer (halfword) representation of valid final board row (no unknowns)
#  	Row data should be generated from validrows.asm.
# 	As a binary number, 0 is white, 1 is black.
#############################
print_bstate_row:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	move	$t0, $a0		# t0 as len = a0
	move	$t1, $a1		# t1 as row = a1
	
	li	$t2, 0			# t2 as i = 0
pbr_loop:
	slt	$t3, $t2, $t0		# if !(i < length), done
	beq	$t3, $zero, pbr_done
	
	sub	$t3, $t0, $t2		# t3 as rshift_coef = len - i - 1
	addi	$t3, $t3, -1
	srlv	$t3, $t1, $t3		# t3 as row_shift = row >> rshift_coef
	li	$t4, 1
	and	$t4, $t3, $t4		# t4 as ibit = row_shift & 1
	
	beq	$t4, $zero, pbr_white	# if ibit == 0, white; else, black.
	la	$a0, black
	jal	print_str
	j	pbr_loop_end
pbr_white:
	la	$a0, white
	jal	print_str
pbr_loop_end:
	addi	$t2, $t2, 1
	j	pbr_loop
pbr_done:
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
#############################
# print_board_hedge
# Print the horizontal edge (incl corners) of a board of a given length.
# Args:
#  a0 - Length of a row
#############################
print_board_hedge:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)

	move	$t1, $a0
	
	la	$a0, corner
	jal	print_str
	
	li	$t0, 0
pbh_loop:
	slt	$t2, $t0, $t1
	beq	$t2, $zero, pbh_done
	la	$a0, top
	jal	print_str
	
	addi	$t0, $t0, 1
	j	pbh_loop
	
pbh_done:
	la	$a0, corner
	jal	print_str
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
