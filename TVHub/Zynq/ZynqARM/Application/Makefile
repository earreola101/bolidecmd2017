CC=arm-xilinx-linux-gnueabi-g++
CXX = arm-xilinx-linux-gnueabi-g++
AS = arm-xilinx-linux-gnueabi-gcc
AR = arm-xilinx-linux-gnueabi-ar
LD = arm-xilinx-linux-gnueabi-g++

ASOPT   = -c -x assembler-with-cpp -mfloat-abi=softfp -mfpu=neon -march=armv7-a
COPT    = -c -O3 -g -mfloat-abi=softfp -mfpu=neon -march=armv7-a
DEFINE  = -DLINUX -DARM -DRELEASE
CFLAGS  = $(COPT) $(DEFINE)
ASFLAGS = $(ASOPT) $(DEFINE)
LDFLAGS = 

INC = \
	-I./ \
	-I../CustomDriver \
	-I../OpenSource \
	-I../ThirdPartyLib \
	-I../UnitTest \


SRC_CPP =	utility.cpp \
			tv_hub_app.cpp \
			../CustomDriver/cs2000.cpp \
			../CustomDriver/spi.cpp


SRC_C = 	byte_queue.c \
			circular_buffer.c \
 			command_gen_dec.c \
 			command_handler_tv_hub.c \
			command_queue.c \
			fw_update_tv_hub.c \
			packet_manager.c \
			send_receive_tv_hub.c \
			tv_hub_mediator.c \
			../CustomDriver/gain_module.c \
			../CustomDriver/serial.c \
			../CustomDriver/tdm_bus.c \
			../CustomDriver/version_module.c \


OBJSc = $(SRC_C:.c=.o)
OBJScpp = $(SRC_CPP:.cpp=.o)

OUT := tv_hub_app

OUT_FOLDER := ../../Build/app/

LD_LIBS := \
	-lpthread

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
