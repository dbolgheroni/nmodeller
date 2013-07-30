# Makefile for nmodeller

CC=gcc
CFLAGS=-shared

#LFLAGS=-L/usr/local/lib -lgdal
LFLAGS=-L/usr/local/lib -lgdal -lluajit-5.1

#IFLAGS=-I/usr/local/include -I/usr/local/include/lua-5.1
IFLAGS=-I/usr/local/include -I/usr/local/include/luajit-2.0

OFLAGS=-olgdal.so
RM=rm -f
TARGET=lgdal.c

bsd:
	$(CC) $(CFLAGS) $(IFLAGS) $(LFLAGS) $(OFLAGS) $(TARGET)
clean:
	$(RM) lgdal.so
