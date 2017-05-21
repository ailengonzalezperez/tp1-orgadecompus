.ent decode
.globl	decode

decode:
	.frame	$fp,72,ra		
	.set	noreorder
	.cpload	t9
	.set	reorder
	subu	sp,sp,72
	.cprestore 16

	sw	ra,64(sp)
	sw	$fp,60(sp)
	sw	gp,56(sp)
	move $fp,sp
	sw	a0,72($fp) #Preservo los a_i que traje como parámetro
	sw	a1,76($fp)
	sw	a2,80($fp)
	sw	a3,84($fp)

	sw	zero,24($fp)
	sb	zero,28($fp)
	sw	zero,32($fp)

	li	v0,3			# 0x3
	sw	v0,40($fp)
	sw	zero,44($fp)
$L30:
	lw	v0,44($fp)
	lw	v1,84($fp)
	slt	v0,v0,v1
	bne	v0,zero,$L33
	b	$L31
$L33:

	lw	v1,80($fp)
	lw	v0,44($fp)
	addu	v0,v1,v0
	lbu	v1,0(v0)
	lb	v0,letters+64
	bne	v1,v0,$L34

	lw	v0,40($fp)
	addu	v0,v0,-1
	sw	v0,40($fp)

	lw	v1,44($fp)
	addu	v0,$fp,24
	addu	v0,v0,v1
	sb	zero,0(v0)

	b	$L32
$L34:

	lw	v1,80($fp)
	lw	v0,44($fp)
	addu	v0,v1,v0
	lbu	v1,0(v0)
	lw	v0,_ctype_
	addu	v0,v1,v0
	addu	v0,v0,1
	lbu	v0,0(v0)
	andi	v0,v0,0x1
	beq	v0,zero,$L35

	lw	v1,44($fp)
	addu	v0,$fp,24
	addu	a0,v0,v1
	lw	v1,80($fp)
	lw	v0,44($fp)
	addu	v0,v1,v0
	lbu	v0,0(v0)
	addu	v0,v0,-65
	sb	v0,0(a0)

	b	$L32
$L35:

	lw	v1,80($fp)
	lw	v0,44($fp)
	addu	v0,v1,v0
	lbu	v1,0(v0)
	lw	v0,_ctype_
	addu	v0,v1,v0
	addu	v0,v0,1
	lbu	v0,0(v0)
	srl	v0,v0,1
	andi	v0,v0,0x1
	beq	v0,zero,$L36

	lw	v1,44($fp)
	addu	v0,$fp,24
	addu	a0,v0,v1
	lw	v1,80($fp)
	lw	v0,44($fp)
	addu	v0,v1,v0
	lbu	v0,0(v0)
	addu	v0,v0,-71
	sb	v0,0(a0)

	b	$L32
$L36:

	lw	v1,80($fp)
	lw	v0,44($fp)
	addu	v0,v1,v0
	lbu	v1,0(v0)
	lw	v0,_ctype_
	addu	v0,v1,v0
	addu	v0,v0,1
	lbu	v0,0(v0)
	srl	v0,v0,2
	andi	v0,v0,0x1
	beq	v0,zero,$L37

	lw	v1,44($fp)
	addu	v0,$fp,24
	addu	a0,v0,v1
	lw	v1,80($fp)
	lw	v0,44($fp)
	addu	v0,v1,v0
	lbu	v0,0(v0)
	addu	v0,v0,4
	sb	v0,0(a0)

	b	$L32
$L37:

	lw	v1,80($fp)
	lw	v0,44($fp)
	addu	a0,v1,v0
	lw	v1,44($fp)
	addu	v0,$fp,24
	addu	v0,v0,v1
	move	a1,v0
	la	t9,issymbol
	jal	ra,t9
	bne	v0,zero,$L32

	li	v0,1			# 0x1
	sw	v0,48($fp)
	b	$L29

$L32:
	lw	v0,44($fp)
	addu	v0,v0,1
	sw	v0,44($fp)
	b	$L30
$L31:

$LBE7:
	lb	v0,24($fp)
	sll	v1,v0,2
	lbu	v0,25($fp)
	andi	v0,v0,0x30
	sra	v0,v0,4
	or	v0,v1,v0
	sb	v0,32($fp)

	lbu	v0,25($fp)
	andi	v0,v0,0xf
	sll	v1,v0,4
	lbu	v0,26($fp)
	andi	v0,v0,0x3c
	sra	v0,v0,2
	or	v0,v1,v0
	sb	v0,33($fp)
	
	lbu	v0,26($fp)
	andi	v0,v0,0x3
	sll	v0,v0,6
	move	v1,v0
	lbu	v0,27($fp)
	or	v0,v1,v0
	sb	v0,34($fp)
	
	addu	v0,$fp,32
	lw	a0,76($fp)
	move	a1,v0
	lw	a2,40($fp)
	la	t9,write
	jal	ra,t9
	move	v1,v0
	li	v0,-1			# 0xffffffffffffffff
	bne	v1,v0,$L39
	
	la	t9,__errno
	jal	ra,t9
	lw	v0,0(v0)
	sw	v0,48($fp)
	b	$L29
$L39:
	sw	zero,48($fp)
	
$L29:
$LBE6:
	lw	v0,48($fp)
	move	sp,$fp
	lw	ra,64(sp)
	lw	$fp,60(sp)
	addu	sp,sp,72
	j	ra
	.end	decode
