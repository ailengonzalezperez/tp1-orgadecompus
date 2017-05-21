
ENC_T_a1_OFF = 52
ENC_T_a0_OFF = 48
ENC_T_SF_SZ = 48
ENC_T_RA_OFF = 40
ENC_T_FP_OFF = 36
ENC_T_GP_OFF = 32
ENC_T_STATE_OFF = 28
ENC_T_READL_OFF = 24
ENC_T_QTY_READ_OFF = 20
SUCCESS = 0
READ_LETTERS_SZ = 4
DECODED_GROUP_SZ = 3
.align	2
.ent encode_text
.globl encode_text
encode_text:
	.frame $fp, ENC_T_SF_SZ, ra
	.set noreorder
	.cpload	t9
	.set reorder
	subu sp, sp, ENC_T_SF_SZ				#Creo el stack frame.
	.cprestore ENC_T_GP_OFF					#Guardo el gp(global pointer) en el stack.
	sw ra, ENC_T_RA_OFF(sp)					#Guardo el ra(return address) en el stack.
	sw $fp, ENC_T_FP_OFF(sp)				#Guardo el $fp(file pointer) en el stack.

	move $fp, sp							#Muevo el frame pointer a la base del stack.

	sw a0, ENC_T_a0_OFF($fp)				#Guardo los argumentos (int infd, int outfd) en el ABA de la callee.
	sw a1, ENC_T_a1_OFF($fp)

	sw SUCCESS, ENC_T_STATE_OFF($fp)		#Inicializo int state = SUCCESS en memoria.
	lw s0, ENC_T_STATE_OFF($fp)				#Regs[s0] <- state.

memset_read_letters:
	addiu a0, $fp, ENC_T_READL_OFF			#Regs[t0] <- read_letters. Cargo la direccion inicial del array 'read_letters' en Regs[t0].
	move a1, zero							#Muevo el caracter de relleno '\0' a Regs[a1].
	li a2, READ_LETTERS_SZ 					#Cargo la cantidad READ_LETTERS_SZ en Regs[a2]. Esta es la cantidad de bytes que tiene que inicializar memset.
	la	t9,	memset 							#Llamado a memset
	jal	ra,	t9								

read_letters:
	lw a0, ENC_T_a0_OFF($fp) 				#Regs[a0] <- infd
	addiu a1, $fp, ENC_T_READL_OFF			#Regs[a1] <- read_letters. Cargo la direccion inicial del array 'read_letters' en Regs[a1].
	li a2, DECODED_GROUP_SZ 

	li	v0, SYS_read 						#Read file   
	syscall

	sw v0, ENC_T_QTY_READ_OFF($fp)			#Guardo la cantidad de bytes leidos en la variable qty_read en memoria. FALTA CONTROLAR a3 para ver si hay error.

while_encode:	
	seq t1, s0, SUCCESS 					#If(state == SUCCESS): Regs[t0] <- 1 else: Regs[t0] <- 0.
	bnez t1, end_encode_text				#If(state != SUCCESS): Goto end_encode_text

	lw t0, ENC_T_QTY_READ_OFF($fp)			#Regs[t0] <- qty_read
	blez t0, end_encode_text    			#If(qty_read <= 0): Goto end_encode_text

	lw t1, ENC_T_a0_OFF($fp)				#Regs[t1] <- infd
	lw t2, ENC_T_a1_OFF($fp)				#Regs[t2] <- outfd


	move a3, t0								#Regs[a3] <- qty_read
	addiu a2, $fp, ENC_T_READL_OFF			#Regs[a2] <- read_letters
	move a1, t2								#Regs[a1] <- outfd
	move a0, t1 							#Regs[a0] <- infd

	la t9, encode 							#Llamado a subrutina 'encode'
	jal encode

	sw v0, ENC_T_STATE_OFF($fp) 			#Guardo el resultado de decode como 'state' en memoria.
	lw s0, ENC_T_STATE_OFF($fp)				#Regs[s0] <- state

	b memset_read_letters

end_encode_text:
	lw v0, ENC_T_STATE_OFF($fp)				#Regs[v0] <- state

	lw ra, ENC_T_RA_OFF(sp)					#Restauro el ra(return address).
	lw gp, ENC_T_GP_OFF(sp)					#Restauro el gp(global pointer).
	lw $fp, ENC_T_FP_OFF(sp)				#Restauro el $fp(file pointer).
	addiu sp, sp, ENC_T_SF_SZ

	jr ra
.end encode_text

DEC_T_a1_OFF = 52
DEC_T_a0_OFF = 48
DEC_T_SF_SZ = 48
DEC_T_RA_OFF = 40
DEC_T_FP_OFF = 36
DEC_T_GP_OFF = 32
DEC_T_STATE_OFF = 28
DEC_T_READL_OFF = 24
DEC_T_QTY_READ_OFF = 20
SUCCESS = 0
ENCODED_GROUP_SZ = 4
FILL_CHAR_POS = 64
.align	2
.ent decode_text
.globl decode_text
decode_text:
	.frame $fp, DEC_T_SF_SZ, ra
	.set noreorder
	.cpload	t9
	.set reorder
	subu sp, sp, DEC_T_SF_SZ				#Creo el stack frame.
	.cprestore DEC_T_GP_OFF					#Guardo el gp(global pointer) en el stack.
	sw ra, DEC_T_RA_OFF(sp)					#Guardo el ra(return address) en el stack.
	sw $fp, DEC_T_FP_OFF(sp)				#Guardo el $fp(file pointer) en el stack.

	move $fp, sp							#Muevo el frame pointer a la base del stack.

	sw a0, DEC_T_a0_OFF($fp)				#Guardo los argumentos (int infd, int outfd) en el ABA de la callee.
	sw a1, DEC_T_a1_OFF($fp)

	sw SUCCESS, DEC_T_STATE_OFF($fp)		#Inicializo int state = SUCCESS en memoria.
	lw s0, DEC_T_STATE_OFF($fp)				#Regs[s0] <- state.

memset_read_letters:
	addiu a0, $fp, DEC_T_READL_OFF			#Regs[t0] <- read_letters. Cargo la direccion inicial del array 'read_letters' en Regs[t0].
	move a1, zero							#Muevo el caracter de relleno(0) a Regs[a1].
	li a2, ENCODED_GROUP_SZ 		
	addiu a2, a2, 1 						#Cargo la cantidad ENCODED_GROUP_SZ + 1 en Regs[a2]. Esta es la cantidad de bytes que tiene que inicializar memset.
	la	t9,	memset 							#Llamado a memset
	jal	ra,	t9				

read_letters:
	lw a0, DEC_T_a0_OFF($fp) 				#Regs[a0] <- infd
	addiu a1, $fp, DEC_T_READL_OFF			#Regs[a1] <- read_letters. Cargo la direccion inicial del array 'read_letters' en Regs[a1].
	li a2, ENCODED_GROUP_SZ

	li	v0, SYS_read 						#Read file   
	syscall

	sw v0, DEC_T_QTY_READ_OFF($fp)			#Guardo la cantidad de bytes leidos en la variable qty_read en memoria. FALTA CONTROLAR a3 para ver si hay error.

while_decode:	
	seq t1, s0, SUCCESS 					#If(state == SUCCESS): Regs[t0] <- 1 else: Regs[t0] <- 0.
	bnez t1, write_extra_chars				#If(state != SUCCESS: Goto write_extra_chars

	lw t0, DEC_T_QTY_READ_OFF($fp)			#Regs[t0] <- qty_read
	blez t0, end_decode_text    			#If(qty_read <= 0): Goto end_encode_text

	lw t1, DEC_T_a0_OFF($fp)				#Regs[t1] <- infd
	lw t2, DEC_T_a1_OFF($fp)				#Regs[t2] <- outfd

	move a3, t0								#Regs[a3] <- qty_read
	addiu a2, $fp, DEC_T_READL_OFF			#Regs[a2] <- read_letters
	move a1, t2								#Regs[a1] <- outfd
	move a0, t1 							#Regs[a0] <- infd

	la t9, encode 							#Llamado a subrutina 'encode'
	jal encode

	sw v0, DEC_T_STATE_OFF($fp) 			#Guardo el resultado de decode como 'state' en memoria.
	lw s0, DEC_T_STATE_OFF($fp)				#Regs[s0] <- state

	b memset_read_letters

end_decode_text:
	lw v0, DEC_T_STATE_OFF($fp)				#Regs[v0] <- state

	lw ra, DEC_T_RA_OFF(sp)					#Restauro el ra(return address).
	lw gp, DEC_T_GP_OFF(sp)					#Restauro el gp(global pointer).
	lw $fp, DEC_T_FP_OFF(sp)				#Restauro el $fp(file pointer).
	addiu sp, sp, DEC_T_SF_SZ

	jr ra
.end decode_text


ENC_OUT_SF_SZ = 96
ENC_OUT_RA = 92
ENC_OUT_FP = 88
ENC_OUT_GP = 84
ENC_OUT_a4_OFF = 112
ENC_OUT_a3_OFF = 108
ENC_OUT_a2_OFF = 104
ENC_OUT_a1_OFF = 100
ENC_OUT_a0_OFF = 96

SHIFT_COUNT = 40
INDEX_OFF = 36
READ_BYTES_OFF = 32
GROUP_QTY_OFF = 28
MAX_GROUP_QTY_OFF = 24
ENCODED_CHARS_OFF = 52
STACK_PTR_OFF = 48
J_OFF = 44

.align 2
.globl	encode
.ent	encode
encode:
	.frame	$fp, ENC_OUT_SF_SZ, ra
	.set	noreorder
	.cpload	t9
	.set	reorder
	subu	sp,sp, ENC_OUT_SF_SZ
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
	lbu t1, t0 							#Regs[t0] <- '='
	lw	a0, ENCODED_CHARS_OFF($fp)		#Guardo el puntero 'encoded_chars' en a0: Regs[a0] <- Mem[encoded_chars].
	move	a1, t0						#Guardo el caracter '=' (obtenido de llamar a 'get_fill_char') en Regs[a1].
	lw	a2,	MAX_GROUP_QTY_OFF($fp)		#Cargo la variable 'max_group_qty' a Regs[a2].
	la	t9,	memset 						#Llamado a memset
	jal	ra,	t9				


#ACA INSERTAR concatenate_byte_to_binary:
#    for(int i = 0; i < sizeof(int); ++i){
#        read_bytes = read_bytes | (read_letters[i] << (sizeof(int) -1 -i)*BYTE_SZ);
#    }
						
	sw	v0,	READ_BYTES_OFF($fp)			#Cargo la variable 'read_bytes' guardada en v0 (obtenida de llamar a 'concantenate_binary_to_int') en memoria.
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
	lw	v0, ENC_OUT_a2_OFF($fp) 	
	lw	sp, STACK_PTR_OFF($fp)		#Restauro el stack pointer
	move sp,$fp
	lw	ra, ENC_OUT_RA(sp)			#Restauro el ra(return address).
	lw	$fp, ENC_OUT_FP(sp)			#Restauro el $fp(frame pointer).
	lw	s0, 80(sp)
	addu	sp, sp, ENC_OUT_SF_SZ
	j	ra
.end	encode
