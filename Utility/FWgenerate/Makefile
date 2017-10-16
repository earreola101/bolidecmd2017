CC=gcc
CXX = g++
AS = gcc
AR = ar
LD = g++

ASOPT   = -c -x assembler-with-cpp 
COPT    = -c
DEFINE  = 
CFLAGS  = $(COPT) $(DEFINE)
ASFLAGS = $(ASOPT) $(DEFINE)
LDFLAGS = 

INC = \
	-I./

SRC_CPP =	FWgenerate.cpp 


SRC_C = 	

OBJSc = $(SRC_C:.c=.o)
OBJScpp = $(SRC_CPP:.cpp=.o)

OUT := FWgenerate

OUT_FOLDER := ./

LD_LIBS := -lstdc++

LIBS_PATH := 


all: $(SRC_C) $(SRC_CPP) $(OUT)

$(OUT): $(OBJSc) $(OBJScpp)
	$(LD) $(LDFLAGS) $(OBJScpp) $(OBJSc) $(LIBS_PATH) $(LD_LIBS) $(INC) -o $(OUT_FOLDER)$(OUT)

.cpp.o:
	$(CXX) $(INC) $(CFLAGS) $< -o $@

.c.o:
	$(CC) $(INC) $(CFLAGS) $< -o $@


clean:
	rm -rf $(OBJSc) $(OBJScpp) *o $(OUT)

cleanlink: 
	rm -rf $(OBJSc) $(OBJScpp) *o $(OUT)
