#include<mips/regdef.h>
#include<sys/syscall.h>

.rdata
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

    .align  2
    .globl  decode
    .ent    decode
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
    beq s0, t0, write 						#bge s0, t0, write               		#If(i >= count): Goto write.

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

write:
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

