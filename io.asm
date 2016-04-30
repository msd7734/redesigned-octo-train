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

	.data
	.align 2
	
bad_data_msg:
	.asciiz "!! WARNING: SENTINAL READ AT ADDR "
bad_data_noaddr:
	.asciiz "[No address given]"
newline:
	.asciiz "\n"
	
	.text
	.align 2
	
	.globl print_int
	.globl print_str
	.globl read_int
	.globl print_bad_data_warn
	
#############################
# print_bad_data_warn
# Print warning that a sentinal indicating bad data has been read.
# Note: Feel free to put a break point here for even more useful debug info.
# Args:
#  a0 - Address at which the value occured. Either the PC or the mem address,
#		whatever your little heart desires. Or 0, if providing no address.
#############################
print_bad_data_warn:
	addi	$sp, $sp, -4
	sw		$ra, 0($sp)

	move	$t0, $a0
	la		$a0, bad_data_msg
	jal		print_str
	beq		$t0, $zero, pbdw_noaddr
	move	$a0, $t0
	jal		print_str
	j		pbdw_done
pbdw_noaddr:
	la		$a0, bad_data_noaddr
	jal		print_str
pbdw_done:
	la		$a0, newline
	jal		print_str
	
	lw		$ra, 0($sp)
	addi	$sp, $sp 4
	jr		$ra
	
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
# print_template_row
# Print the string representation of a board template (the "initial puzzle").
# Args:
#  a0 - Length of the row
#  a1 - Ptr to row data words
#############################
print_template_row:
	
	jr		$ra
	
print_template:
	
	jr		$ra
	
print_bstate_row:
	
	jr		$ra
