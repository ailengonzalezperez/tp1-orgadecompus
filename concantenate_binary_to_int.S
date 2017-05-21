.align	2
.ent concantenate_binary_to_int
.globl concantenate_binary_to_int

concantenate_binary_to_int:
	.frame $fp, 8, ra			
	.set noreorder
	.cpload	t9
	.set reorder
	subu sp, sp, 8
	.cprestore 4
	sw	$fp, 0(sp)
	move $fp,sp
	
	li t0, 0 								#t0 = i
	li t1, 0 								#t1 = number
	li t2, 4 								#t2 = sizeof(int)
	
	while: 	beq t0, t2, finConcatenate
			li t3, 3 						#t3 = sizeof(int)-1
			subu t3, t3, t0 				#t3 = sizeof(int)-1 - i
			sll t3, t3, 3 					#t3 = t3>>3 = t3*8 = t3*BYTE_SZ
			addu t4, t0, a0					#characters i
			lb t4, 0(t4) 
			sll t4, t4, t3
			or t1, t1, t4
			addi t0, t0, 1
			b while			
	
	finConcatenate: move v0,t1
					lw $fp, 0(sp)
					lw gp, 4(sp)
					addu sp, sp, 8
	
					j	ra
.end concantenate_binary_to_int