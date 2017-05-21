#include "base64.h"
#include <stdbool.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/stat.h>


#define ERROR_ACTION 1
#define BUFF_SZ 100

int print_file(char *fname){
    char buff[BUFF_SZ + 1];
    FILE *file = fopen(fname, "r+");

    while(!feof(file)){
        memset(buff, '\0',(BUFF_SZ + 1)*sizeof(char));
        fread(buff, sizeof(char), BUFF_SZ, file);
        printf("%s",buff);
    }
    fclose(file);
    return EXIT_SUCCESS;
}

bool free_mem(FILE* input, FILE* output){
    return (fclose(input) != EOF) && (fclose(output) != EOF);
}

void show_help(){
		printf("Usage: \n \
		tp0 -h \n \
		tp0 -V \n \
		tp0 [options] \n \
		Options: \n \
		-V, --version Print version and quit.\n \
		-h, --help Print this information.\n \
		-i, --input Location of the input file.\n \
		-o, --output Location of the output file.\n \
		-a, --action Program action: encode (default) or decode.\n \
		Examples:\n \
		tp0 -a encode -i ~/input -o ~/output\n \
		tp0 -a decode \n");
}

void show_version(){
	printf("Organizacion de Computadoras - TP0 \n \
			Encoder/Decoder Base64 - v2.0 \n \
			Group Members:\n \
			Gonzalez Perez, Ailen Padron: 97043\n \
			Mariotti, Maria Eugenia Padron: 96260\n \
			Raña, Cristian Ezequiel Padron: 95457\n");
}

int main(int argc, char* argv[]){
	
	bool help, version, output, input, decode; //To know what to do
	help = version = output = input = decode = false; //They all start in false
	char *input_file, *output_file;
	input_file = output_file = NULL; //To save the file names. If 0 -> standar
	int fd_input, fd_output;
	fd_input = 0; //file descriptor de stdin es 0. Chequear si funciona
	fd_output = 1; // file descriptor de stdout es 1. Chequear si funciona

	for (int i=0; i<argc; i++){
		char *arg = argv[i];
		if (strcmp(arg,"-v")==0 || strcmp(arg,"--version")==0){
				version = true;
		}
		if (strcmp(arg,"-h")==0 || strcmp(arg,"--help")==0){
				help = true;
		}
		if (strcmp(arg,"-o")==0 || strcmp(arg,"--output")==0){
				output_file = argv[++i];
				if (strcmp(output_file,"-")!=0)
					output = true; // - es std. No debo hacer el open
		}
		if (strcmp(arg,"-i")==0 || strcmp(arg,"--input")==0){
				input_file = argv[++i];
				if (strcmp(input_file,"-")!=0)
					input = true; // - es std. No debo hacer el open
		}
		if (strcmp(arg,"-a")==0 || strcmp(arg,"--action")==0){
				if (strcmp(argv[++i],"decode")==0)
					decode = true;
		}
	}

	int exit = 0;
	
	if (help) {
		show_help();
		return exit; //show and quit
	}
	if (version) {
		show_version();
		return exit; //show and quit
	}
	if (input){ //si hay input, lo abro
		fd_input = open(input_file, O_RDONLY); //obtengo el fd	de input (sólo lectura)	
	}	
	if (output){
		fd_output = open(output_file, O_WRONLY|O_CREAT, S_IRWXU); //obtengo el fd	(podría leer y escribir)
																//chequear si tercer campo hace falta
		
	}
	if (fd_output == -1 || fd_input == -1){ //
		printf("Falla en apertura de archivos. Intente nuevamente. \n");
		return errno;
	}
		
	if (decode){
		exit = base64_decode(fd_input,fd_output);  //Chequear si devuelven un código de error
	}
	else{
		exit = base64_encode(fd_input,fd_output);//Chequear si devuelven un código de error
	}
	/*VERIFICAR SI FALTARÍA ALGÚN FREE*/
	close(fd_input);
	close(fd_output);
	return exit;
}



