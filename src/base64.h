#ifndef BASE64_H
#define BASE64_H

const char* errmsg[4] = {
    "Succeeded",
    "Falla en archivo de salida.Intente nuevamente\n",
    "Falla en archivo de entrada.Intente nuevamente\n",
};

/*Recibe dos file descriptors infd y outfd, 
codifica los leido desde infd a base64 
y lo escribe en el file descriptor outfd*/
extern int base64_encode(int infd, int outfd);

/*Recibe dos file descriptors infd y outfd, 
decodifica los leido desde infd en base64 
y lo escribe en el file descriptor outfd*/
extern int base64_decode(int infd, int outfd);

extern int encode(int infd, int outfd, unsigned char *read_letters, int tot_read);

extern int decode(int infd, int outfd, unsigned char *letters, int count);

extern void show_version();

extern void show_help();

#endif //BASE64_H
