CC = arm-linux-gnueabihf-gcc
OBJS = bfpga2tool.o bfpga2_lib.o
CFLAGS = -Wall

all: $(OBJS)
	$(CC) $^ -o bfpga2tool -lm

clean:
	rm -f *.o *~ core bfpga2tool
