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
	
#############################
# read_file
# Read contents of a file into a buffer.
# Args:
#  a0 - Length of the side of a (square) board.
# Returns:
#  v0 - ptr to 0 if the length is unsupported, or ptr to a row_listing
#       in the following format:
#		struct row_listing {
# 			int16 count;
# 			int16 row_data[count];
# 		}
#############################
read_file:
	addi	$sp, $sp, -8
	sw		$s0, 0($sp)
	sw		$s1, 4($sp)
	# comprised of a sequence of FOPEN, FWRITE, FCLOSE
	# shouldn't need flags for a simple read
	
	# take a0 as name
	move	$a1, $zero
	li		$a2, O_RDONLY
	li		$v0, FOPEN
	syscall
	
	
	lw		$s0, 0($sp)
	lw		$s1, 4($sp)
	jr		$ra