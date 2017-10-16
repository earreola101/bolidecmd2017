ARCH = arm-none-eabi
CFG = Release
CC = arm-none-eabi-gcc
CPP = arm-none-eabi-g++
AR = arm-none-eabi-ar
LD = arm-none-eabi-g++
CC_OPTIONS = -c -O3 -Wall -fmessage-length=0 -ffast-math -funroll-loops -marm -march=armv7-a -mfpu=neon -fPIC -DPIC -mfloat-abi=hard
CPP_OPTIONS = -c -O3 -Wall -fmessage-length=0 -ffast-math -funroll-loops -marm -march=armv7-a -mfpu=neon -fPIC -DPIC -mfloat-abi=hard -fno-rtti
AR_OPTIONS = rcv
LD_OPTIONS = -marm -march=armv7-a -mfpu=neon -mfloat-abi=hard
STD_LIBS =
ASDSP_EXT_DEFINE =
