#include "base64.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>

#define BYTE_SZ 8
#define GROUP_SZ 6.0
#define SYMBOL_POS 62
#define FILL_CHAR_POS 64
#define ENCODED_GROUP_SZ 4
#define DECODED_GROUP_SZ 3
#define NEW_LINE '\n'
#define MAX_LEN 76

#define MASK 0x3F
#define DMASK_1 0x30
#define DMASK_2 0xf
#define DMASK_3 0x3c
#define DMASK_4 0x3

#define DELTA_UPP 65
#define DELTA_LOW 71
#define DELTA_NUM 4
#define DELTA_SYM 18

static const char letters[] = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O',
'P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k',
'l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5',
'6','7','8','9','+','/','='};

typedef enum error { ERROR =-1, SUCCESS, INVALID_CHARACTER, IO_ERROR, MEMORY_ERROR} Error_t;

int encode(int infd,int outfd, unsigned char *read_letters, int tot_read){
    int read_bytes = 0;
    unsigned int index = 0, shift_count = 0;
    int max_group_qty = (DECODED_GROUP_SZ * BYTE_SZ) / GROUP_SZ;
    int group_qty = (int)ceil((double)((tot_read * BYTE_SZ) / GROUP_SZ));

    //Inicializo el array 'encoded_chars' con el caracter de relleno:
    unsigned char encoded_chars[max_group_qty + 1];
    memset(&encoded_chars, letters[FILL_CHAR_POS], (max_group_qty)*sizeof(char));

    for(int i = 0; i < sizeof(int); ++i){
        read_bytes = read_bytes | (read_letters[i] << (sizeof(int) -1 -i)*BYTE_SZ);
    }

    for (int j = 0; j < group_qty; ++j){
        //Ahora aplico operaciones logicas y obtengo un index
        //para cada grupo de 6 bits:
        shift_count = (max_group_qty - j - 1)*GROUP_SZ + BYTE_SZ;
        index = (read_bytes >> shift_count) & MASK;
        //Uso el index para obtener un caracter del
        //archivo de caracteres posibles:
        encoded_chars[j] = letters[index];
    }
    int state = SUCCESS;
    if(write(outfd, encoded_chars, max_group_qty) == ERROR){
      	state = errno;
    }
    return state;
}

/*bool issymbol(unsigned char *c, char *index){
    for (int i = SYMBOL_POS; letters[i] && i < FILL_CHAR_POS; ++i){
        if (*c == letters[i]){
            *index = i;
            return true;
        }
    }
    return false;
}*/
/*
int decode(int infd, int outfd, unsigned char *read_letters, int count){
    char indexes[ENCODED_GROUP_SZ + 1] = {0};
    char buff[DECODED_GROUP_SZ + 1] = {0};

    //Esto es para que si se codifico un caracter nulo
    //en el medio de los otros caracteres, este se copie
    //al archivo decodificado.
    int len = DECODED_GROUP_SZ;

    for (int i = 0; i < count; ++i) {
        //Si no, tenemos que buscar el índice de la letra.
        //en b64 y guardar su posición.
        if (read_letters[i] == letters[FILL_CHAR_POS]){
            //Si la letra leida es el caracter de relleno,
            //llenamos con 0 la posicion de ese caracter.
            len--;
            indexes[i] =  0;
            continue;
        }
        if(isupper(read_letters[i])){
            indexes[i] = read_letters[i] - DELTA_UPP;
            continue;
        }
        if(islower(read_letters[i])){
            indexes[i] = read_letters[i] - DELTA_LOW;
            continue;
        }
        if(isdigit(read_letters[i])){
            indexes[i] = read_letters[i] + DELTA_NUM;
            continue;
        }
        if(!issymbol(read_letters + i, indexes + i)){
            return INVALID_CHARACTER;
        }

    }

    //Teniendo los números asociados se hace la decodificación en sí misma
    //relacionando los valores en b64 y ascii
    //A considerar: 0x30 = 48 0x3c = 60  0xf= 15 0x3 = 3
    //Se encuentran explicados los cálculos en el informe
    buff[0] = (indexes[0] << 2) | ((indexes[1] & DMASK_1) >> 4);
    buff[1] = ((indexes[1] & DMASK_2) << 4) | ((indexes[2] & DMASK_3) >> 2);
    buff[2] = ((indexes[2] & DMASK_4) << 6) | indexes[3];

    if(write(outfd, buff, len) == ERROR){
       return errno;
    }
    return SUCCESS;
}*/

int base64_encode(int infd, int outfd){
    int state = SUCCESS;
    unsigned char read_letters[sizeof(int)];
    memset(&read_letters, '\0', sizeof(int));

    //Leo de a 3 bytes y codifico:
    int qty_read = read(infd, read_letters, DECODED_GROUP_SZ);
    while((qty_read > 0) && (state == SUCCESS)){ 
        state = encode(infd, outfd, read_letters, qty_read);
        memset(&read_letters, '\0', sizeof(int));
        qty_read = read(infd, read_letters, DECODED_GROUP_SZ);
    }
    return state;
}

int base64_decode(int infd, int outfd){
    int state = SUCCESS;
    unsigned char read_letters[ENCODED_GROUP_SZ + 1];
    memset(read_letters, '\0', (ENCODED_GROUP_SZ + 1)*sizeof(char));

    //Inicializo el array de caracteres leidos con el caractere
    //de relleno por si no se completa la cantidad de bytes esperados.
    //Esto solo agrega un '\0' al resultado decodificado.
    int qty_read = read(infd, read_letters, ENCODED_GROUP_SZ);
    while((qty_read > 0) && (state==SUCCESS)){
        state = decode(infd, outfd, read_letters, qty_read);
        memset(read_letters, '\0', (ENCODED_GROUP_SZ + 1)*sizeof(char));
        qty_read = read(infd, read_letters, ENCODED_GROUP_SZ);
    }
    return state;
}

