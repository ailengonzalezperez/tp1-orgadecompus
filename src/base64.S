#include<mips/regdef.h>
#include<sys/syscall.h>

FILL_CHAR_POS = 64
SUCCESS = 0

DECODE_a3_OFF = 68
DECODE_a2_OFF = 64
DECODE_a1_OFF = 60
DECODE_a0_OFF = 56
DECODE_SF_SZ = 56

DECODE_S0_OFF = 48
DECODE_S1_OFF = 44

DECODE_RA_OFF = 40
DECODE_FP_OFF = 36
DECODE_GP_OFF = 32
DECODE_BUFF_OFF = 28
DECODE_INDEXES_OFF = 24
DECODE_LEN_OFF = 20
DECODE_i_OFF = 16

ENCODED_GROUP_SZ = 4
DECODED_GROUP_SZ = 3
INVALID_CHARACTER = 1
DELTA_UPP = 0x41
DELTA_LOW = 0x47
DELTA_NUM = 0x4
MIN_VAL_UPP = 0x41
MAX_VAL_UPP = 0x5A
MIN_VAL_LOW = 0x61
MAX_VAL_LOW = 0x7A
MIN_VAL_DIGIT = 0x30
MAX_VAL_DIGIT = 0x39
SYMBOL_A_POS = 62
SYMBOL_B_POS = 63

DMASK_1 = 48
DMASK_2 = 15
DMASK_3 = 60
DMASK_4 = 3

ENCODE_a3_OFF = 76
ENCODE_a2_OFF = 72
ENCODE_a1_OFF = 68
ENCODE_a0_OFF = 64

ENCODE_SF_SZ = 64
ENCODE_RA_OFF = 56
ENCODE_FP_OFF = 52
ENCODE_GP_OFF = 48
GROUP_QTY_OFF = 44
J_OFF = 40
I_OFF = 36
ENCODED_CHARS_OFF = 32
SHIFT_COUNT = 24
INDEX_OFF = 20
READ_BYTES_OFF = 16

GROUP_SZ = 6
BYTE_SZ = 8
MAX_GROUP_QTY = 4
SZ_INT = 4
MASK = 0x3F

.rdata

version:  .asciiz "\n\nOrganizacion de Computadoras - TP1 \nEncoder/Decoder Base64 - v2.2 \nGroup Members:\nGonzalez Perez, Ailen Padron: 97043\nMariotti, Maria Eugenia Padron: 96260\nRaña, Cristian Ezequiel Padron: 95457\n"		
help: .asciiz "\n\nUsage: \ntp0 -h \ntp1 -V \ntp0 [options] \nOptions: \n-V, --version Print version and quit.\n-h, --help Print this information.\n-i, --input Location of the input file.\n-o, --output Location of the output file.\n-a, --action Program action: encode (default) or decode.\nExamples:\ntp1 -a encode -i ~/input -o ~/output\ntp1 -a decode \n"

.align	2
.type	letters, @object
.size	letters, 65
letters:
	.byte 65
	.byte 66
	.byte 67
	.byte 68
	.byte 69
	.byte 70
	.byte 71
	.byte 72
	.byte 73
	.byte 74
	.byte 75
	.byte 76
	.byte 77
	.byte 78
	.byte 79
	.byte 80
	.byte 81
	.byte 82
	.byte 83
	.byte 84
	.byte 85
	.byte 86
	.byte 87
	.byte 88
	.byte 89
	.byte 90
	.byte 97
	.byte 98
	.byte 99
	.byte 100
	.byte 101
	.byte 102
	.byte 103
	.byte 104
	.byte 105
	.byte 106
	.byte 107
	.byte 108
	.byte 109
	.byte 110
	.byte 111
	.byte 112
	.byte 113
	.byte 114
	.byte 115
	.byte 116
	.byte 117
	.byte 118
	.byte 119
	.byte 120
	.byte 121
	.byte 122
	.byte 48
	.byte 49
	.byte 50
	.byte 51
	.byte 52
	.byte 53
	.byte 54
	.byte 55
	.byte 56
	.byte 57
	.byte 43
	.byte 47
	.byte 61

.text

.ent show_version		
.globl show_version		
show_version: 
	.frame $fp,8,ra		
	.set noreorder		
	.cpload t9		
	.set reorder		
	
	subu sp,sp,8		
	sw $fp,0(sp)			
	.cprestore 4		

	li v0,SYS_write		
	li a0,1 # show_version es stdout  	
	la a1,version		
	li a2,197 #frase de 195 caracteres (1 character = 8 bits = 1 byte)	
	syscall		
					
	lw $fp,0(sp)		
	lw gp,4(sp)			
	addu sp,sp,8		
	jr ra
.end show_version
		

.ent show_help		
.globl show_help	
show_help: 
	.frame $fp,8,ra		
	.set noreorder		
	.cpload t9		
	.set reorder		
	
	subu sp,sp,8		
	sw $fp,0(sp)			
	.cprestore 4		

	li v0,SYS_write		
	li a0,1 # show_version es stdout  	
	la a1,help		
	li a2,326 #frase de 326 caracteres (1 character = 8 bits = 1 byte)	
	syscall		
					
	lw $fp,0(sp)		
	lw gp,4(sp)			
	addu sp,sp,8		
	jr ra
.end show_help


.align 2
.globl	encode
.ent	encode
encode:
	.frame	$fp, ENCODE_SF_SZ, ra
	.set	noreorder
	.cpload	t9
	.set	reorder
	subu	sp, sp, ENCODE_SF_SZ
	.cprestore ENCODE_GP_OFF
	sw	ra, ENCODE_RA_OFF(sp)			#Guardo el ra(return address) actual.
	sw	$fp, ENCODE_FP_OFF(sp)			#Guardo el $fp(frame pointer) actual.

	move $fp, sp 						#Muevo el stack frame pointer a la base del stack.

	sw	a0, ENCODE_a0_OFF($fp)			#Guardo los parametros recibidos (int infd, int outfd, int state, 
	sw	a1, ENCODE_a1_OFF($fp)			#unsigned char *read_letters) en el ABA de la callee.
	sw	a2, ENCODE_a2_OFF($fp)
	sw	a3, ENCODE_a3_OFF($fp)

	addiu a0, $fp, ENCODED_CHARS_OFF 	#Regs[a0] <- encoded_chars.
	la t2, letters + FILL_CHAR_POS 		#Regs[t2] <- letters + FILL_CHAR_POS. Cargo la direccion en memoria del caracter de relleno en Regs[t2].
	lbu a1, (t2) 					 	#Regs[a2] <- '='.
	li a2, MAX_GROUP_QTY 				#Regs[a3] <- MAX_GROUP_QTY.

	la t9, memset						#Llamado a subrutina 'memset'.
	jalr t9

	sw zero, I_OFF($fp) 				#Inicializo la variable i = 0.
	lw t2, I_OFF($fp) 					#Regs[t2] <- i.
	li t3, SZ_INT 						#Regs[t3] <- sizeof(int). Guardo el valor en bytes del tipo 'int' en Regs[t3].
	lw t4, ENCODE_a2_OFF($fp) 			#Regs[t4] <- read_letters.
	move t5, zero 						#Regs[t5] <- read_bytes. Inicializo Regs[t5] en 0 para usarlo como variable 'read_bytes'. 
	sw t5, READ_BYTES_OFF($fp)          #Inicializo la variable 'read_bytes' en memoria.

concatenate:
	lw t5, READ_BYTES_OFF($fp)          #Regs[t5] <- read_bytes.
	bge t2, t3, find_b64_char 			#If(i >= sizeof(int)): Goto find_b64_char.
	addu t6, t4, t2 					#Regs[t6] <- read_letters + i.
	lbu t6, (t6)						#Regs[t6] <- read_letters[i].

	subu t7, t3, 1 						#Regs[t7] <- (sizeof(int) -1).
	subu t7, t7, t2 					#Regs[t7] <- (sizeof(int) -1 -i).
	mul t7, t7, BYTE_SZ         		#Regs[t7] <- (sizeof(int) -1 -i)*BYTE_SZ.
	sll t8, t6, t7 						#Regs[t8] <- (read_letters[i] <<(sizeof(int) -1 -i)*BYTE_SZ).
	or t5, t5, t8 						#read_bytes = read_bytes | (read_letters[i] <<(sizeof(int) -1 -i)*BYTE_SZ).
	sw t5, READ_BYTES_OFF($fp)          #Actualizo la variable 'read_bytes' en memoria.
	addiu t2, t2, 1 					#i++.
	sw t2, I_OFF($fp)					#Actualizo la variable 'i' en memoria.
	b concatenate						#Goto concatenate.

find_b64_char:
	lw	t0, ENCODE_a3_OFF($fp)			#Regs[t0] <- tot_read.
	sll	t0, t0, 3						#Regs[t0] <- tot_read * BYTE_SZ.
	li t1, GROUP_SZ 					#Regs[t1] <- GROUP_SZ.
	divu t0, t1 						#Regs[lo] <- tot_read * BYTE_SZ / GROUP_SZ.

	mflo t2 							#Regs[t2] <- group_qty = (tot_read * BYTE_SZ ) / GROUP_SZ.
	mfhi t3 							#Si el resto de la division fue mayor a 0, group_qty se redondea para arriba.
	sgt t4, t3, zero 					
	addu t2, t2, t4 					
	sw t2, GROUP_QTY_OFF($fp) 			#Actualizo en memoria la variable group_qty.

	sw zero, J_OFF($fp) 				#Inicializo la variable j = 0 en el memoria.
	lw t3, J_OFF($fp) 					#Regs[t3] <- j.

	li t4, MAX_GROUP_QTY                #Regs[t4] <- MAX_GROUP_QTY.
	lw t5, READ_BYTES_OFF($fp)			#Regs[t5] <- read_bytes.	
	la t6, letters 						#Regs[t6] <- letters. 
	addiu t7, $fp, ENCODED_CHARS_OFF 	#Regs[t7] <- encoded_chars.

for_group_qty:
	bge t3, t2, write_enc 				#If(j >= group_qty): Goto write_enc.

	subu t8, t4, t3 					#Regs[t8] <- (MAX_GROUP_QTY - j).
	subu t8, t8, 1   					#Regs[t8] <- (MAX_GROUP_QTY - j - 1).
	mul t8, t8, t1   					#Regs[t8] <- (MAX_GROUP_QTY - j - 1)*GROUP_SZ.
	addiu t8, t8, BYTE_SZ				#Regs[t8] <- (MAX_GROUP_QTY - j - 1)*GROUP_SZ + BYTE_SZ.
	sw t8, SHIFT_COUNT($fp)				#Actualizo la variable shift_count en memoria.

	srl t8, t5, t8 						#Regs[t8] <- (read_bytes >> shift_count).
	and t8, t8, MASK 					#Regs[t8] <- (read_bytes >> shift_count) & MASK.

	sw t8, INDEX_OFF($fp)				#Actualizo la variable index en memoria.

	addu t9, t6, t8 					#Regs[t9] <- letters + index.
	lbu t8, (t9)						#Regs[t8] <- letters[index].

	addu t0, t7, t3 					#Regs[t0] <- encoded_chars + j.
	sb t8, (t0)							#encoded_chars[j] = letters[index].  

	addiu t3, t3, 1 					#j++.
	sw t3, J_OFF($fp) 					#Actualizo la variable 'j' en memoria.
	b for_group_qty						#Goto for_group_qty.

write_enc:
	lw a0, ENCODE_a1_OFF($fp) 				#Regs[a0] <- outfd.
	addiu a1, $fp, ENCODED_CHARS_OFF		#Regs[a1] <- encoded_chars. Cargo la direccion inicial del array 'encoded_chars' en Regs[a1].
	li a2, MAX_GROUP_QTY 					#Regs[a2] <- max_group_qty.

	li	v0, SYS_write 						#Write file.   
	syscall

	bnez a3, end_encode					    #Si hubo error de escritura (a3!=0): Goto end_decode. El error esta cargado en v0.
	li v0, SUCCESS 							#Si no, cargo SUCCESS en v0.
	b end_encode

end_encode:
	lw	ra, ENCODE_RA_OFF(sp)			#Restauro el return address.	
	lw	gp, ENCODE_GP_OFF(sp)			#Restauro el global pointer.
	lw	$fp, ENCODE_FP_OFF(sp)			#Restauro el $fp(frame pointer).
		
	addu sp, sp, ENCODE_SF_SZ			#Restauro el stack pointer.
	
	jr	ra
.end encode

.align	2
.globl	base64_decode
.ent	base64_decode
base64_decode:
	.frame	$fp,64,ra
	.set	noreorder
	.cpload	t9
	.set	reorder
	subu	sp,sp,64
	.cprestore 16

	sw	ra,56(sp)
	sw	$fp,52(sp)
	sw	gp,48(sp)
	move	$fp,sp

	sw	a0,64($fp) #preservo a0 y a1
	sw	a1,68($fp)

	sw	zero,24($fp) #cargo state = 0 en 24($fp)

	addu a0,$fp,32 #mi posiciòn de escritura es a 32($fp)
	move a1,zero 
	li	a2,5	#(4+1)*sizeof(char)
	
	jal	memset #llamada a memset. despues, va a venir la primer lectura de qty_read

	addu a1,$fp,32 #destino de lectura
	lw	a0,64($fp) #input fd
	li	a2,4 #quiero leer 4 bytes
	li v0,SYS_read
	
	syscall #leo
	
	sw	v0,40($fp) #cargo en qty_read, lo que leyó y vino en v0

loop_b64d: #aquí viene el ciclo de lectura
	lw	t1,40($fp) #cargo qty_read
	blez	t1,fin_ciclo #si qty_read <= 0  -> salto
	lw	t1,24($fp) #cargo state
	bnez	t1,fin_ciclo #si no es cero, termina

	addu a2,$fp,32 #destino (read_letters)
	lw	a0,64($fp) #fd in
	lw	a1,68($fp) #fd out
	lw	a3,40($fp) #qty_read
	
	jal	decode
	
	sw	v0,24($fp) #el resultado de decode se asigna a state

	addu	v0,$fp,32 #se repite el memset de antes
	move	a0,v0
	move	a1,zero
	li	a2,5	
	
	jal	memset


	addu a1,$fp,32 #destino de lectura (qty_read)
	lw	a0,64($fp) #input fd
	li	a2,4 #quiero leer 4 bytes
	li v0,SYS_read
	
	syscall
	
	sw	v0,40($fp)
	
	b loop_b64d
	
fin_ciclo:
	lw	v0,24($fp)
	move	sp,$fp
	lw	ra,56(sp)
	lw	$fp,52(sp)
	addu	sp,sp,64
	jr	ra

.end	base64_decode

.align 2
.ent decode    
.globl decode

decode:
    .frame  $fp, DECODE_SF_SZ, ra
    .set    noreorder
    .cpload t9
    .set    reorder
    subu    sp, sp, DECODE_SF_SZ
    .cprestore DECODE_GP_OFF                #Guardo el gp(global pointer) en el stack.
    sw ra, DECODE_RA_OFF(sp)                #Guardo el ra(return address) en el stack.
    sw $fp, DECODE_FP_OFF(sp)               #Guardo el $fp(file pointer) en el stack.

    move $fp, sp                            #Muevo el frame pointer a la base del stack.

    sw a0, DECODE_a0_OFF($fp)               #Guardo los argumentos (int infd, int outfd, unsigned char *read_letters, int count) en el ABA de la callee.
    sw a1, DECODE_a1_OFF($fp)
    sw a2, DECODE_a2_OFF($fp)
    sw a3, DECODE_a3_OFF($fp)

    sw s0, DECODE_S0_OFF($fp)				#Guardo los registros s0 y s1.
    sw s1, DECODE_S1_OFF($fp)

    move s0, zero 							#Regs[s0](i) <- 0.
    sw s0, DECODE_i_OFF($fp) 				#Inicializo la variable i en memoria.

	li s1, DECODED_GROUP_SZ 				#Regs[s1](len) <- DECODED_GROUP_SZ.
	sw s1, DECODE_LEN_OFF($fp) 				#Inicializo la variable len(Regs[s1]) en memoria.

for_decode:
    lw s0, DECODE_i_OFF($fp)                #Cargo el vlalor de i desde el stack.
	lw t0, DECODE_a3_OFF($fp) 				#Regs[t0] <- count
    beq s0, t0, write_dec					#If(i >= count): Goto write_dec.

    lw t1, DECODE_a2_OFF($fp) 				#Regs[t1] <- read_letters.  
    addu t1, s0, t1 						#Regs[t1] <- read_letters + i.
    lbu t2, (t1)  		                 	#Regs[t2] <- read_letters[i].

if_fill_char:

	la t3, letters + FILL_CHAR_POS 			#Regs[t3] <- letters + FILL_CHAR_POS 			
	lbu t4, 0(t3) 							#Regs[t4] <- '='.
    				
    addu t5, $fp, DECODE_INDEXES_OFF		#Regs[t5] <- indexes         
    addu t5, s0, t5							#Regs[t5] <- indexes + i

    bne t2, t4, if_is_upper                 #If(read_letters[i] != '='): Goto if_is_upper.
    subu s1, s1, 1                          #len--
    sb zero, 0(t5)                          #indexes[i] = 0.
    b end_for

if_is_upper:
    blt t2, MIN_VAL_UPP, if_is_lower        #Si read_letters[i] es menor que el minimo valor de las letras mayusculas: Goto if_is_lower.
    bgt t2, MAX_VAL_UPP, if_is_lower        #Si read_letters[i] es mayor que el máximo valor de las letras mayusculas: Goto if_is_lower.    
    subu t6, t2, DELTA_UPP                  #Regs[t6] <- read_letters[i] - DELTA_UPP

    sb t6, 0(t5)                            #indexes[i] <- Regs[t6] (read_letters[i] - DELTA_UPP).
    b end_for

if_is_lower:
    blt t2, MIN_VAL_LOW, if_is_digit        #Si read_letters[i] es menor que el minimo valor de las letras minúsculas: Goto if_is_digit.
    bgt t2, MAX_VAL_LOW, if_is_digit        #Si read_letters[i] es mayor que el máximo valor de las letras minúsculas: Goto if_is_digit.    
    subu t6, t2, DELTA_LOW                  #Regs[t6] <- read_letters[i] - DELTA_LOW

    sb t6, 0(t5)                            #indexes[i] <- Regs[t6] (read_letters[i] - DELTA_LOW).
    b end_for

if_is_digit:
    blt t2, MIN_VAL_DIGIT, if_is_sym_a      #Si read_letters[i] es menor que el minimo valor de las dígitos: Goto if_not_is_sym.
    bgt t2, MAX_VAL_DIGIT, if_is_sym_a      #Si read_letters[i] es mayor que el máximo valor de las dígitos: Goto if_not_is_sym.    
    addiu t6, t2, DELTA_NUM                 #Regs[t6] <- read_letters[i] - DELTA_NUM
 
    sb t6, 0(t5)                            #indexes[i] <- Regs[t6] (read_letters[i] - DELTA_NUM).
    b end_for

if_is_sym_a:
    la t3, letters + SYMBOL_A_POS			#Regs[t6] <- letters + SYMBOL_A_POS 
    lbu t6, 0(t3) 							#Regs[t6] <- letters[SYMBOL_A_POS]
    bne t2, t6, if_is_sym_b 				#If(read_letters[i] != letters[SYMBOL_A_POS]): Goto if_is_sym_b
    li t6, SYMBOL_A_POS 					#Regs[t6] <- SYMBOL_A_POS
    sb t6, 0(t5)                            #indexes[i] <- SYMBOL_A_POS
    b end_for

if_is_sym_b:
    la t3,letters + SYMBOL_B_POS			#Regs[t6] <- letters + SYMBOL_B_POS 
    lbu t6, 0(t3) 							#Regs[t6] <- letters[SYMBOL_B_POS]
    bne t2, t6, end_decode_error			#If(read_letters[i] != letters[SYMBOL_B_POS]): Goto end_decode_error
    li t6, SYMBOL_B_POS 					#Regs[t6] <- SYMBOL_B_POS
    sb t6, 0(t5)                            #indexes[i] <- SYMBOL_B_POS
    b end_for
    
end_for:
    addiu s0, s0, 1                         #Regs[s0] <- i + 1
    sw s0, DECODE_i_OFF($fp)                #Actualizo la variable i en el stack.
    b for_decode

write_dec:
    addiu t0, $fp, DECODE_INDEXES_OFF       #Regs[t0] <- indexes.
    addiu t1, $fp, DECODE_BUFF_OFF 			#Regs[t1] <- buff.	

	lbu t2, 0(t0)							#Regs[t2] <- indexes[0].
	sll t2, t2, 2 							#Regs[t2] <- indexes[0] << 2.

	addiu t3, t0, 1							#Regs[t3] <- indexes + 1.
	lbu t3, 0(t3)							#Regs[t3] <- indexes[1].
	li t4, DMASK_1 							#Regs[t4] <- 0x30
	and t4, t3, t4 							#Regs[t4] <- indexes[1] and 0x30.						
	srl t4, t4, 4 							#Regs[t4] <- (indexes[1] and 0x30) >> 4.						

	or t5, t2, t4 							#Regs[t5] <-  (indexes[0] << 2) | ((indexes[1] and 0x30) >> 4).						
	sb t5, 0(t1)							#buff[0] <- Regs[t5]


    li t2, DMASK_2 							#Regs[t2] <- DMASK_2.
    and t3, t3, t2							#Regs[t3] <- indexes[1] and DMASK_2. (Regs[t3] contiene indexes[1]).
    sll t3, t3, 4 							#Regs[t3] <- (indexes[1] & DMASK_2) << 4).
	addiu t4, t0, 2 						#Regs[t4] <- indexes + 2.
	lbu t4, 0(t4) 							#Regs[t4] <- indexes[2].
	li t5, DMASK_3 							#Regs[t5] <- DMASK_3.
	and t5, t4, t5 							#Regs[t5] <- indexes[2] & DMASK_3.
	srl t5, t5, 2 							#Regs[t5] <- (indexes[2] & DMASK_3)>>2.
	or t6, t3, t5 							#Regs[t6] <- (indexes[1] & DMASK_2) << 4) or ((indexes[2] & DMASK_3)>>2).

    addiu t1, t1, 1 			 			#Regs[t1] <- buff + 1.
	sb t6, 0(t1)                            #buff[1] <- (indexes[1] & DMASK_2) << 4) or ((indexes[2] & DMASK_3)>>2).
	
	li t2, DMASK_4 							#Regs[t2] <- DMASK_4
	and t3, t4, t2 							#Regs[t3] <- indexes[2] and DMASK_4. (Regs[t4] contiene indexes[2]).
	sll t3, t3, 6 							#Regs[t3] <- (indexes[2] and DMASK_4) << 6.
	
	addiu t5, t0, 3 						#Regs[t5] <- indexes + 3
	lbu t5, 0(t5) 							#Regs[t5] <- indexes[3]
	or t6, t3, t5 							#Regs[t6] <- ((indexes[2] and DMASK_4) << 6) or indexes[3].

    addiu t1, t1, 1 			 			#Regs[t1] <- buff + 2.
    sb t6, 0(t1)							#buff[2] <- ((indexes[2] and DMASK_4) << 6) or indexes[3].

	lw a0, DECODE_a1_OFF($fp) 				#Regs[a0] <- outfd.
	addiu a1, $fp, DECODE_BUFF_OFF			#Regs[a1] <- buff. Cargo la direccion inicial del array 'buff' en Regs[a1].
	move a2, s1 							#Regs[a2] <- Regs[s1] (len).

	li	v0, SYS_write 						#Write file.   
	syscall

	bnez a3, end_decode					    #Si hubo error de escritura (a3!=0): Goto end_decode. El error esta cargado en v0.
	li v0, SUCCESS 							#Si no, cargo SUCCESS en v0.
	b end_decode

end_decode_error:
    li v0, INVALID_CHARACTER                #Devuelvo un error porque se encontro un caracter invalido durante la decodificacion.

end_decode:
    lw s0, DECODE_S0_OFF($fp)               #Restauro el valor de Regs[s0].
    lw s1, DECODE_S1_OFF($fp)               #Restauro el valor de Regs[s1].

    lw ra, DECODE_RA_OFF(sp)                #Restauro el ra(return address).
    lw gp, DECODE_GP_OFF(sp)                #Restauro el gp(global pointer).
    lw $fp, DECODE_FP_OFF(sp)               #Restauro el $fp(file pointer).
    addiu sp, sp, DECODE_SF_SZ

    jr ra
.end decode

.align	2
.globl	base64_encode
.ent	base64_encode
base64_encode:
	.frame	$fp,64,ra
	.set	noreorder
	.cpload	t9
	.set	reorder
	subu	sp,sp,64
	.cprestore 16

	sw	ra,56(sp)
	sw	$fp,52(sp)
	sw	gp,48(sp)
	move	$fp,sp

	sw	a0,64($fp) #preservo a0 y a1
	sw	a1,68($fp)

	sw	zero,24($fp) #cargo state = 0 en 24($fp)

	addu a0,$fp,32 #mi posiciòn de escritura es a 32($fp)
	move a1,zero 
	li	a2,4	#sizeof(int)
	
	jal	memset #llamada a memset. despues, va a venir la primer lectura de qty_read

	addu a1,$fp,32 #destino de lectura
	lw	a0,64($fp) #input fd
	li	a2,3 #quiero leer 4 bytes
	li v0,SYS_read
	
	syscall #leo
	
	sw	v0,40($fp) #cargo en qty_read, lo que leyó y vino en v0

loop_b64e: #aquí viene el ciclo de lectura
	lw	t1,40($fp) #cargo qty_read
	blez	t1,finciclo #si qty_read <= 0  -> salto
	lw	t1,24($fp) #cargo state
	bnez	t1,finciclo #si no es cero, termina

	addu a2,$fp,32 #destino (read_letters)
	lw	a0,64($fp) #fd in
	lw	a1,68($fp) #fd out
	lw	a3,40($fp) #qty_read
	
	jal	encode
	
	sw	v0,24($fp) #el resultado de decode se asigna a state

	addu	v0,$fp,32 #se repite el memset de antes
	move	a0,v0
	move	a1,zero
	li	a2,4	
	
	jal	memset


	addu a1,$fp,32 #destino de lectura (qty_read)
	lw	a0,64($fp) #input fd
	li	a2,3 #quiero leer 4 bytes
	li v0,SYS_read
	
	syscall
	
	sw	v0,40($fp)
	
	b loop_b64e
	
finciclo:
	lw	v0,24($fp)
	move	sp,$fp
	lw	ra,56(sp)
	lw	$fp,52(sp)
	addu	sp,sp,64
	jr	ra

.end	base64_encode

