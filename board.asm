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
	
board:
	.space MAX_BSIZE*2	# row is hword (2 bytes)
board_t:
	.space MAX_BSIZE*2	# board transpose (for checking cols)
	
filtered_rows:
	.space MAX_VALID*2	# enough to fit bsize=10, template=all unknown
	
	.text
	.align 2
	
	.globl b_from_template
	
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
