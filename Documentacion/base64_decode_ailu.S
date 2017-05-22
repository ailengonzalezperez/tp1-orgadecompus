.align 2
.ent base64_decode
.globl base64_decode

base64_decode:	.frame $fp,SF_BASE64_SIZE,ra
				.set noreorder
				.cpload t9
				.set reorder
				
				subu sp,sp,SF_BASE64_SIZE
				sw ra,40(sp)
				.cprestore 16
				sw $fp,32(sp)
				sw gp,36(sp)

				sw a0,52(sp)
				sw a1,56(sp) #Preservo a0 y a1, que tienen los fd
	
				sw zero,16(sp) #state a 16($fp) = 0		
				move $fp,sp
				
				addu v0,$fp,20 
				move a0,v0 #va a escribir a 20 de fp
				move a1,zero
				li a2,5 #(4+1)*sizeof(char)
				
				la t9,memset #llamada a memset
				jal ra,t9
				
				addu t0,$fp,20 
				move a1,t0 #destino de lectura
				lw a0,52($fp) #origen lectura
				li a2,4 #vamos a leer 4 bytes
				li v0,SYS_read
			
				syscall
				
				sw v0,24($fp) #lo guardo en qty_read

				ciclo_while:	lw t1,24($fp) #cargo qty_read en t1
								blez t1,fin_ciclo
								lw t1,16($fp) #cargo tn t1 a state
								bnez t1,fin_ciclo
								
								lw a0,52($fp) #cargo infd en a0
								lw a1,56($fp) #cargo outfd en a1
								lw a2,20($fp) #a2 va read_letters
								lw a3,24($fp) #a3 lleva qty_read
								
								
								jal decoder #va a devolver en v0, a state
								
								sw v0,16($fp) #guardo el nuevo state
								
								
								addu v0,$fp,20 
								move a0,v0 #va a escribir a 20 de fp
								move a1,zero
								li a2,5
				
								la t9,memset #llamada a memset
								jal ra,t9
								
								addu v0,$fp,20  #nuevo valor para qty_read
								move a1,v0 #destino de lectura
								lw a0,52($fp) #origen lectura
								li a2,4 #vamos a leer 4 bytes
								li v0,SYS_read
			
								syscall
				
								sw v0,24($fp) #lo guardo en qty_read
								
								b ciclo_while
								
				fin_ciclo:		lw v0,16($fp) #return value
								
								move sp,$fp
								lw ra,40(sp)
								lw gp,36(sp)
								lw $fp,32(sp)
								
								addu sp,sp,SF_BASE64_SIZE
	
								j ra
.end base64_decode
						
