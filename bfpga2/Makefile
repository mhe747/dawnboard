CC = arm-linux-gnueabihf-gcc
OBJS = bfpga2tool.o bfpga2_lib.o
CFLAGS = -Wall

all: $(OBJS)
	$(CC) $^ -o bfpga2tool -lm

gpio: gpio_tst.c gpio_lib.c gpio_lib.h
        $(CC) $^ -o gpio_tst -lm

clean:
	rm -f *.o *~ core bfpga2tool gpio_tst
