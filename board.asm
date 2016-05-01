#############################
# board.asm
# Created by: Matthew Dennis (msd7734)
# Handles the entire board solution state internally, exposing various
# subroutines that help interact with it.
#############################

# Constants
MIN_BSIZE=	2
MAX_BSIZE=	10

# The max valid row combinations for bsize 10 is 84
MAX_VALID=	84

	.data
	.align 2
	
# Bitflags for 16bit number
hflags:
	.half 0x0001, 0x0002, 0x0004, 0x0008
	.half 0x0010, 0x0020, 0x0040, 0x0080
	.half 0x0100, 0x0200, 0x0400, 0x0800
	.half 0x1000, 0x2000, 0x4000, 0x8000

board:
	.space MAX_BSIZE*2	# row is hword (2 bytes)
board_t:
	.space MAX_BSIZE*2	# board transpose (for checking cols)

# for each row, need enough to fit bsize=10, template=all unknown
valid_for_row1:
	.space 2
	.space MAX_VALID*2
valid_for_row2:
	.space 2
	.space MAX_VALID*2
valid_for_row3:
	.space 2
	.space MAX_VALID*2
valid_for_row4:
	.space 2
	.space MAX_VALID*2
valid_for_row5:
	.space 2
	.space MAX_VALID*2
valid_for_row6:
	.space 2
	.space MAX_VALID*2
valid_for_row7:
	.space 2
	.space MAX_VALID*2
valid_for_row8:
	.space 2
	.space MAX_VALID*2
valid_for_row9:
	.space 2
	.space MAX_VALID*2
valid_for_row10:
	.space 2
	.space MAX_VALID*2
	
filtered_rows:
	.word valid_for_row1	
	.word valid_for_row2	
	.word valid_for_row3	
	.word valid_for_row4	
	.word valid_for_row5	
	.word valid_for_row6	
	.word valid_for_row7	
	.word valid_for_row8	
	.word valid_for_row9	
	.word valid_for_row10	
	

	.text
	.align 2
	
	# External references
	# ===================
	.globl valid_rows
	
	# io.asm
	.globl newline
	
	.globl print_int
	.globl print_str
	.globl read_int
	
	# External definitions
	# ====================
	.globl b_from_template
	.globl get_black_mask
	.globl get_white_mask

	
#############################
# valid_row_storage
# Get a pointer to valid rows values for a given row.
# Subroutine makes no guarantees whether memory is already initialized.
# Args:
#  a0 - Row number 0 to (MAX_BSIZE-1)
# Returns:
#  v0 - Pointer to a storage location in the format:
# 	struct row_listing {
# 		int16 count;
# 		int16 row_data[count];
# 	}
#############################
valid_row_storage:
	la	$t0, filtered_rows
	mul	$t1, $a0, 4
	add	$t0, $t0, $t1
	lw	$v0, 0($t0)
	jr	$ra
	
#############################
# b_from_template
# Initialize an empty board state based on a given template.
# Initialization entails:
# 	- Padding unused buffer space (rows) with sentinel values
#	- Storing a set of filtered valid rows based on the given template.
# 	- Initializing the board transpose
# Args:
#  a0 - Length of a board row
#  a1 - Pointer to a template used to filter valid rows.
#############################
b_from_template:
	addi	$sp, $sp, -36
	sw	$s7, 32($sp)
	sw	$s6, 28($sp)
	sw	$s5, 24($sp)
	sw	$s4, 20($sp)
	sw	$s3, 16($sp)
	sw	$s2, 12($sp)
	sw	$s1, 8($sp)
	sw	$s0, 4($sp)
	sw	$ra, 0($sp)
	
	
bft_loop:
	
	
bft_done:
	lw	$s7, 32($sp)
	lw	$s6, 28($sp)
	lw	$s5, 24($sp)
	lw	$s4, 20($sp)
	lw	$s3, 16($sp)
	lw	$s2, 12($sp)
	lw	$s1, 8($sp)
	lw	$s0, 4($sp)
	lw	$ra, 0($sp)
	addi	$sp, $sp, 36
	jr	$ra

#############################
# get_filtered_row
# Filter all valid rows for given board template row and store them.
# Args:
#  a0 - Length of a board row
#  a1 - Pointer to a template used to filter valid rows.
#  a2 - Pointer to row_listing where validated rows will be stored.
#  	struct row_listing {
# 		int16 count;
# 		int16 row_data[count];
# 	}
# Returns:
#  v0 - # valid rows found and stored
#############################
get_filtered_row:
	addi	$sp, $sp, -36
	sw	$s7, 32($sp)
	sw	$s6, 28($sp)
	sw	$s5, 24($sp)
	sw	$s4, 20($sp)
	sw	$s3, 16($sp)
	sw	$s2, 12($sp)
	sw	$s1, 8($sp)
	sw	$s0, 4($sp)
	sw	$ra, 0($sp)
	
	jal	valid_rows
	lh	$s0, 0($v0)		# s0 as size = row_listing.count
	addi	$s1, $v0, 2		# s1 as data* = (row_listing&)+2
	
	jal	get_black_mask		# s3 as blkmask = get_black_mask(a0,a1)
	move	$s3, $v0
	jal	get_white_mask		# s4 as whtmask = get_white_mask(a0,a1)
	move	$s4, $v0
	
	addi	$s5, $a2, 2		# s5 = ptr to storage in row_listing
	
	li	$v0, 0
	
	# loop through every possible valid row
	li	$s2, 0			# s2 as i = 0
gfr_loop:	
	slt	$t0, $s2, $s0		# if !(i < size), done
	beq	$t0, $zero, gfr_done
	
	mul	$t0, $s2, 2		# offset = i*2
	add	$t0, $s1, $t0		# t0 = data+offset
	lh	$t0, 0($t0)		# t0 as row_candidate = data[i]
	
	# if blkmask & row_candidate = blkmask
	#   && whtmask | row_candidate = whtmask
	# Then given row is valid for template
	
	and	$t1, $t0, $s3		# t1 = row_candidate & blkmask
	or	$t2, $t0, $s4		# t2 = row_candidate | whtmask
	
	sub	$t1, $s3, $t1
	sub	$t2, $s4, $t2
	add	$t3, $t1, $t2
	
	bne	$t3, $zero, gfr_loop_end
	
	# store the now validated row candidate and incr. ptr
	sh	$t0, 0($s5)
	addi	$s5, $s5, 2
	addi	$v0, $v0, 1
gfr_loop_end:
	addi	$s2, $s2, 1
	j	gfr_loop
gfr_done:
	sh	$v0, 0($a2)	# row_listing.count = count

	lw	$s7, 32($sp)
	lw	$s6, 28($sp)
	lw	$s5, 24($sp)
	lw	$s4, 20($sp)
	lw	$s3, 16($sp)
	lw	$s2, 12($sp)
	lw	$s1, 8($sp)
	lw	$s0, 4($sp)
	lw	$ra, 0($sp)
	addi	$sp, $sp, 36
	jr	$ra
	
#############################
# get_black_mask
# Generate a bitmask that can be AND'd with to validate row vs. a template row.
# Args:
#  a0 - Length of a board row
#  a1 - Pointer to a template row (a series of words)
# Returns:
#  v0 - An integer mask.
#	If row & black_mask = black_mask, row is valid for template (for black).
#############################
get_black_mask:
	li	$v0, 0
	la	$t9, hflags
	move	$t0, $a0
gblm_loop:
	beq	$t0, $zero, gblm_done
	
	addi	$t1, $t0, -1		# check the (i-1)th bit
	mul	$t1, $t1, 2		# t2 as flag = ptr hflags + (i-1)*2
	add	$t2, $t9, $t1
	lh	$t2, 0($t2)
	
	sub	$t3, $a0, $t0	# t3 as template_part = template[(len-i)*4]
	mul	$t3, $t3, 4
	add	$t3, $a1, $t3
	lw	$t3, 0($t3)
	
	# if the template_part is 2, treat bit in mask as 1 (black)
	# else, treat as 0 (white)
	
	addi	$t4, $t3, -2
	bne	$t4, $zero, gblm_loop_end
	or	$v0, $v0, $t2
gblm_loop_end:
	addi	$t0, $t0, -1
	j	gblm_loop
gblm_done:
	jr	$ra
	
#############################
# get_white_mask
# Generate a bitmask that can be OR'd with to validate row vs. a template row.
# Args:
#  a0 - Length of a board row
#  a1 - Pointer to a template row (a series of words)
# Returns:
#  v0 - An integer mask.
#	If row | white_mask = white_mask, row is valid for template (for white).
#############################
get_white_mask:
	li	$v0, 0
	la	$t9, hflags
	move	$t0, $a0
gwhm_loop:
	beq	$t0, $zero, gwhm_done
	
	addi	$t1, $t0, -1		# check the (i-1)th bit
	mul	$t1, $t1, 2		# t2 as flag = ptr hflags + (i-1)*2
	add	$t2, $t9, $t1
	lh	$t2, 0($t2)
	
	sub	$t3, $a0, $t0	# t3 as template_part = template[(len-i)*4]
	mul	$t3, $t3, 4
	add	$t3, $a1, $t3
	lw	$t3, 0($t3)
	
	# if the template_part is 1, treat bit as 0 in mask (white)
	# else, treat as 1 (black)
	
	addi	$t4, $t3, -1
	beq	$t4, $zero, gwhm_loop_end
	or	$v0, $v0, $t2
gwhm_loop_end:
	addi	$t0, $t0, -1
	j	gwhm_loop
gwhm_done:
	jr	$ra
	