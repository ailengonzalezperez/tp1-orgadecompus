CC = gcc
CFLAGS = -o0 -g -Wall -pedantic -std=c99

OBJECTS = base64.o
EXEC = tp0

VALGRIND = valgrind --track-origins=yes --leak-check=full
VALGRIND-V = $(VALGRIND) -v

all: $(EXEC)

base64.o: base64.c base64.h
	$(CC) $(CFLAGS) -c base64.c -o base64.o

$(EXEC): $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) tp0.c -o $(EXEC) -lm

run: $(EXEC)
	./$(EXEC)

valgrind: $(EXEC)
	$(VALGRIND) ./$(EXEC)

valgrind-verb: $(EXEC)
	$(VALGRIND-V) ./$(EXEC)

clean:
	rm -f *.o $(EXEC)
