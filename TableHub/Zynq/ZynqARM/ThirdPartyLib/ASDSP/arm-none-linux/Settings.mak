ARCH = arm-none-linux
CFG = Release
CC = arm-none-linux-gnueabi-gcc
CPP = arm-none-linux-gnueabi-g++
AR = arm-none-linux-gnueabi-ar
LD = arm-none-linux-gnueabi-g++
CC_OPTIONS = -c -O3 -Wall -fmessage-length=0 -ffast-math -funroll-loops -marm -march=armv7-a -mfpu=neon -fPIC -DPIC -mfloat-abi=softfp
CPP_OPTIONS = -c -O3 -Wall -fmessage-length=0 -ffast-math -funroll-loops -marm -march=armv7-a -mfpu=neon -fPIC -DPIC -mfloat-abi=softfp -fno-rtti
AR_OPTIONS = rcv
LD_OPTIONS = -marm -march=armv7-a -mfpu=neon -mfloat-abi=softfp -static
STD_LIBS =
ASDSP_EXT_DEFINE =
