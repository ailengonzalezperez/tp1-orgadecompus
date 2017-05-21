#ifndef BASE64_H
#define BASE64_H

/*Recibe dos file descriptors infd y outfd, 
codifica los leido desde infd a base64 
y lo escribe en el file descriptor outfd*/
int base64_encode(int infd, int outfd);

/*Recibe dos file descriptors infd y outfd, 
decodifica los leido desde infd en base64 
y lo escribe en el file descriptor outfd*/
int base64_decode(int infd, int outfd);

//extern int concantenate_binary_to_int(unsigned char *characters);

extern int issymbol(unsigned char *c, char *index);

//extern int encode(int infd, int outfd, unsigned char *read_letters, int tot_read);

extern int decode(int infd, int outfd, unsigned char *letters, int count);

//extern int decode_text(int infd, int outfd);

//extern int encode_text(int infd, int outfd);

#endif //BASE64_H
