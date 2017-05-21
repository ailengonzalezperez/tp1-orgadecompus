.globl	encode
.ent	encode
encode:
	.frame	$fp, ENC_OUT_SF_SZ, ra
	.set	noreorder
	.cpload	t9
	.set	reorder
	subu	sp,sp,ENC_OUT_SF_SZ
	.cprestore 16

	sw	ra, ENC_OUT_RA(sp)			#Guardo el ra(return address) actual.
	sw	$fp, ENC_OUT_FP(sp)			#Guardo el $fp(frame pointer) actual.
	sw	gp, ENC_OUT_GP(sp)			#Guardo el gp(global pointer) actual.
	sw	s0, 80(sp)					#Guardo el valor actual de s0 porque voy a usar este resgistro.

	move $fp, sp 					#Muevo el stack frame pointer a la base del stack.

	sw	a0, ENC_OUT_a0_OFF($fp)		#Guardo los parametros recibidos (int infd, int outfd, int state, 
	sw	a1, ENC_OUT_a1_OFF($fp)		#unsigned char *read_letters) en el ABA de la callee.
	sw	a2, ENC_OUT_a2_OFF($fp)
	sw	a3, ENC_OUT_a3_OFF($fp)

	sw	sp, STACK_PTR_OFF($fp)		#Guardo el valor actual del stack pointer.
	li	v0, 4		 				#Regs[v0] <- (DECODED_GROUP_SZ * BYTE_SZ) / GROUP_SZ (Esta operacion da 4).
	sw	v0, MAX_GROUP_QTY_OFF($fp) 	#Guardo el resultado de (DECODED_GROUP_SZ * BYTE_SZ) / GROUP_SZ en 'max_group_qty' en memoria.

	lw	v0, ENC_OUT_a4_OFF($fp)		#Cargo el 5to argumento en v0. Regs[v0] <- tot_read
	sll	v0, v0, 3					#Regs[v0] <- tot_read * BYTE_SZ(8) 

	mtc1	v0, $f0 				#Mover el contenido de Regs[v0]= (tot_read * BYTE_SZ) a registro de punto flotante en Coprocesador1.
	cvt.d.w	$f2,$f0 				#Convertir el contenido de Regs[f0] de Word a Double y guardar el resultado en Regs[f2].
	li.d $f0, 6 					#(l.d $f0, E1)	#Load FP double (E1 debe ser la constante GROUP_SZ).
	div.d	$f0,$f2,$f0 			#Regs[f0] <- (double)((tot_read * BYTE_SZ) / GROUP_SZ).
	mov.d	$f12,$f0 				#Mover el resultado cargado en Regs[f0] a registro de doble precision Regs[f12].
	la	t9, ceil 					#Cargo la direccion de 'ceil' en Regs[t9].
	jal	ra, t9 						#Llamo a la funcion 'ceil'.

	trunc.w.d $f0,$f0,v0 			#Regs[f0] <- (int)Regs[v0] (Casteo el resultado de 'ceil' y lo guardo en $f0).
	s.s	$f0, GROUP_QTY_OFF($fp)		#Guardo el resultado de la operacion en una variable en memoria('group_qty'). 

	sw	zero, READ_BYTES_OFF($fp) 	#Inicializo read_bytes = 0 en memoria.
	sw	zero, INDEX_OFF($fp)		#Inicializo index = 0 en memoria.
	sw	zero, SHIFT_COUNT($fp)		#Inicializo shift_count = 0 en memoria, con doble precision.


	lw	v0, MAX_GROUP_QTY_OFF($fp)		#Regs[v0] <- max_group_qty
	addiu	v0, v0, 1 			 		#Regs[v0] <- max_group_qty + 1
	addiu	v0, v0, 7 			 		#Regs[v0] <- max_group_qty + 1 + 7

	srl	v0, v0, 3  	#Elimino los ultimos 3 bits de 'max_group_qty' para que quede un multiplo de 8:
					
	sll	v0, v0, 3 	#Armo el espacio para el vector 'encoded_chars' en la base del stack: 

	subu	sp,	sp,	v0
	addu	v1, sp, 16 	#Subo 2 posiciones el sp:


	sw	v1, ENCODED_CHARS_OFF($fp)		#Guardo el puntero 'encoded_chars' en memoria: Regs[v1] -> Mem[encoded_chars]

	
	la	t0, letters
	addiu t0, t0, FILL_CHAR_POS 
	lbu t1,0(t0) 							#Regs[t0] <- '='
	lw	a0, ENCODED_CHARS_OFF($fp)		#Guardo el puntero 'encoded_chars' en a0: Regs[a0] <- Mem[encoded_chars].
	move	a1, t0						#Guardo el caracter '=' (obtenido de llamar a 'get_fill_char') en Regs[a1].
	lw	a2,	MAX_GROUP_QTY_OFF($fp)		#Cargo la variable 'max_group_qty' a Regs[a2].
	la	t9,	memset 						#Llamado a memset
	jal	ra,	t9				


	li t0,0 # t0 = i
	li t1,0 # t1 = read_bytes
	li t2,4 # t2 = sizeof(int)
	la t4,ENC_OUT_a1_OFF($fp) #tengo en t4 a read_letters
	
	concatenate: 	beq t0,t2,finConcatenate	 #si i = sizeof(int) corto
			li t3,3 	# t3 = sizeof(int)-1
			subu t3,t3,t0 	# t3 = sizeof(int)-1 - i
			sll t3,t3,3 	# t3 = t3>>3 = t3*8 = t3*BYTE_SZ
			addu t4,t4,t0 	#characters i. voy a avanzar en t4
			lb t5,0(t4) 	#cargo el caracter
			sll t5,t5,t3 	#shifteo t4 según t3
			or t1,t1,t5     #hago el or
			addi t0,t0,1    #incremento i
			b concatenate	
			
	finConcatenate:
	sw	t1,	READ_BYTES_OFF($fp)			#Cargo la variable 'read_bytes' guardada en v0 (obtenida de llamar a 'concantenate_binary_to_int') en memoria.
	sw	zero,	J_OFF($fp)				#Inicializo j = 0 en memoria.
ENCODE_GROUP:
	lw	v0, J_OFF($fp)					#Regs[v0] <- j
	lw	v1, GROUP_QTY_OFF($fp)			#Regs[v1] <- group_qty
	slt	v0, v0, v1						#Si (j < group_qty): Regs[V0] = 1; else: Regs[0] = 0
	bne	v0, zero, FIND_INDEX			#Si Regs[v0] != 0 (o sea si j < group_qty), ir a FIND_INDEX
	b	WRITE
FIND_INDEX:
	lw	v1, MAX_GROUP_QTY_OFF($fp)		#Regs[v1] <- max_group_qty
	lw	v0, J_OFF($fp)					#Regs[v0] <- j
	subu	v0, v1, v0 					#Regs[v0] <- max_group_qty - j
	addu	v0, v0, -1 					#Regs[v0] <- max_group_qty - j - 1
	mtc1	v0, $f0						#Mover el contenido de Regs[v0](=max_group_qty-j-1) a registro de punto flotante en Coprocesador1.
	cvt.d.w	$f2, $f0 					#Convertir el contenido de Regs[f0] de Word a Double y guardar el resultado en Regs[f2].
	li.d $f0, 6 		#			#Cargo el inmediato GROUP_SZ en Reg[f0] de doble precision.
	mul.d	$f2,$f2,$f0					#Regs[f2] <- (max_group_qty-j-1)*GROUP_SZ
	li.d	$f0, 8 				#Cargo el inmediato BYTE_SZ en Reg[f0] de doble precision.
	add.d	$f2,$f2,$f0 				#Regs[f2] <- (max_group_qty-j-1)*GROUP_SZ + BYTE_SZ
	s.d	$f2, 56($fp)					#Guardo el resultado de la operacion (ahora guardado en Regs[f2]) en memoria, con doble precision.
	li.d	$f0, 63 					#Cargo MASK en Regs[f0] de doble precision.
	s.d	$f0, 72($fp)					#Guardo MASK en memoria.
	l.d	$f2, 56($fp)					#Regs[f2] <- (max_group_qty-j-1)*GROUP_SZ + BYTE_SZ

	l.d	$f0, 72($fp)
	c.le.d	$f0,$f2 					#If (Regs[f0](MASK) <= Regs[f2]): goto J4
	bc1t	J4
	l.d	$f0,56($fp)
	trunc.w.d $f0,$f0,v0
	s.s	$f0,64($fp)
	b	J5
J4:
	l.d	$f2,56($fp)
	l.d	$f4,72($fp)
	sub.d	$f0,$f2,$f4
	li	v0,-2147483648			# 0xffffffff80000000
	trunc.w.d $f2,$f0,a0
	s.s	$f2,64($fp)
	lw	v1,64($fp)
	or	v1,v1,v0
	sw	v1,64($fp)
J5:
	lw	a0,64($fp)
	sw	a0,40($fp)
	lw	v1,32($fp)
	lw	v0,40($fp)
	sra	v0,v1,v0
	andi	v0,v0,0x3f
	sw	v0,36($fp)
	lw	v0, J_OFF($fp)
	lw	a1,52($fp)
	addu	s0,a1,v0
	lw	a0,36($fp)
	la	t9,encode
	jal	ra,t9
	sb	v0,0(s0)
	lw	v0, J_OFF($fp)
	addu	v0,v0,1
	sw	v0, J_OFF($fp)
	b	ENCODE_GROUP
WRITE:
	lw	v0, ENC_OUT_a2_OFF($fp)		#Regs[v0] <- state
	bne	v0, zero, END 				#If(state != SUCCESS): goto END
	
	lw	a0, ENC_OUT_a1_OFF($fp)		#Regs[a0] <- outfd
	lw	a1, ENCODED_CHARS_OFF($fp)  #Regs[a1] <- encoded_chars
	lw	a2, MAX_GROUP_QTY_OFF($fp)  #Regs[a2] <- max_group_qty

	li	v0, SYS_write # write file   
	syscall

	sw	v0, 44($fp)					#Verifico si write me devolvio error(-1).
	lw	v1, 44($fp)
	li	v0,-1			
	bne	v1,v0,END 					#Si no hubo error, goto END.
	la	t9,__errno					#Si hubo error, devuelvo el codigo de error en v0
	jal	ra,t9
	lw	v0,0(v0)
	sw	v0, ENC_OUT_a2_OFF($fp) 	#y guardo el codigo de error en state: Regs[v0] -> Mem[state].

END:

	lw	a0, ENC_OUT_a0_OFF($fp)		#Guardo los parametros recibidos (int infd, int outfd, int state, 
	lw	a1, ENC_OUT_a1_OFF($fp)		#unsigned char *read_letters) en el ABA de la callee.
	lw	a2, ENC_OUT_a2_OFF($fp)
	lw	a3, ENC_OUT_a3_OFF($fp)
	
	lw	v0,ENC_OUT_a2_OFF(sp) 	
	lw	gp,ENC_OUT_GP(sp)		#Restauro el stack pointer
	lw	$fp,ENC_OUT_FP(sp)			#Restauro el $fp(frame pointer).

	lw	ra,ENC_OUT_RA(sp)			#Restauro el ra(return address).
		
	addu sp,sp,ENC_OUT_SF_SZ
	
	jr	ra
	
.end encode
