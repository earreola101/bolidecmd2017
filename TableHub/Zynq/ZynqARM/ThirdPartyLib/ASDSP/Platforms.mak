#******************************************************************************
#
#	Description:	Platforms.mak - GNU Makefile include
#
#	Copyright (C) 2003-2014 -- ASDSP S.r.l. -- www.asdsp.com
#
#******************************************************************************

ifndef ARCH								#--------------------------------------------	Default ARCH definition
ifeq ($(TERM), cygwin)
	ARCH = gnu
else
	ARCH = mac
endif
endif

ifndef CFG
	CFG = Release
endif

ifeq ($(CFG), Release)
	OBJ_DIR = $(ARCH)/obj
	LIB_DIR = $(ARCH)/lib
	OUT_DIR = $(ARCH)/bin
else
	OBJ_DIR = $(ARCH)/$(CFG)
	LIB_DIR = $(ARCH)/$(CFG)
	OUT_DIR = $(ARCH)/$(CFG)
endif

OBJ_EXT = o
LIB_EXT = a
OUT_EXT =

ifndef TOOLS_INC_DIR
	TOOLS_INC_DIR = $(TOOLS_DIR)/include
	TOOLS_SRC_DIR = $(TOOLS_DIR)/src
	TOOLS_LIB_DIR = $(TOOLS_DIR)/$(LIB_DIR)
	
	TOOLS_INC = -I$(TOOLS_INC_DIR) -I$(TOOLS_SRC_DIR)
endif

ifndef RELEASE_DIR
	RELEASE_DIR = ~/Shared/Demo/Release
endif

ifneq ($(findstring gnu, $(ARCH)),)					#--------------------------------------------	Linux GCC / CygWin GCC

	# Build tools
	ifeq ($(CC), cc)								# Default GNU-make CC definition
		CC = gcc
		AR = ar
		LD = g++
		CPP = g++
	endif
	
else ifneq ($(findstring mac, $(ARCH)),)			#--------------------------------------------	Mac OS/X GCC

	# Build tools

	CC = gcc
	AR = ar
	LD = g++
	CPP = g++
	
	CC_OPTIONS += -Wno-parentheses -Wno-logical-op-parentheses -Wno-tautological-constant-out-of-range-compare

else ifneq ($(findstring ios6, $(ARCH)),)			#--------------------------------------------	iPhone iOS 6

	# Build tools

	IOS_DEV_ROOT = /Applications/Xcode4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer

	CC = $(IOS_DEV_ROOT)/usr/bin/gcc
	AR = $(IOS_DEV_ROOT)/usr/bin/ar
	LD = $(IOS_DEV_ROOT)/usr/bin/g++
	CPP = $(IOS_DEV_ROOT)/usr/bin/g++

	# Compiler options

	CC_OPTIONS += -marm -mthumb -mfpu=neon -mcpu=cortex-a8 -mtune=cortex-a8 \
				  -fmodulo-sched -fivopts -fno-math-errno -funsafe-math-optimizations \
				  -ffast-math -fno-trapping-math -fno-short-enums -fPIC \
				  -fomit-frame-pointer -ftree-vectorize -ffunction-sections \
				  -funwind-tables -fstack-protector -Wdisabled-optimization \
				  -Wpointer-arith -Wcast-qual -Wno-unused -fsingle-precision-constant \
				  -mfloat-abi=softfp -funswitch-loops -finline-functions -finline-limit=300 -ftree-loop-linear

	IOS_SDK = $(IOS_DEV_ROOT)/SDKs/iPhoneOS6.1.sdk
	
	CC_OPTIONS += -isysroot $(IOS_SDK)

else ifneq ($(findstring ios7, $(ARCH)),)			#--------------------------------------------	iPhone iOS 7

	# Build tools
	
	IOS_DEV_ROOT = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
	
	ifeq ($(ARCH), ios7_x86)
		IOS_SDK_TYPE = iphonesimulator
	else
		IOS_SDK_TYPE = iphoneos
	endif
	
	CC = xcrun --sdk $(IOS_SDK_TYPE) gcc
	AR = xcrun --sdk $(IOS_SDK_TYPE) ar
	LD = xcrun --sdk $(IOS_SDK_TYPE) clang++
	CPP = xcrun --sdk $(IOS_SDK_TYPE) clang++

	# Compiler options

	CC_OPTIONS += -Wno-parentheses -Wno-logical-op-parentheses -Wno-tautological-constant-out-of-range-compare

else ifneq ($(findstring ios8, $(ARCH)),)			#--------------------------------------------	iPhone iOS 8

	# Build tools
	
	IOS_DEV_ROOT = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
	
	ifeq ($(ARCH), ios8_x64)
		IOS_SDK_TYPE = iphonesimulator
	else
		IOS_SDK_TYPE = iphoneos
	endif
	
	CC = xcrun --sdk $(IOS_SDK_TYPE) gcc
	AR = xcrun --sdk $(IOS_SDK_TYPE) ar
	LD = xcrun --sdk $(IOS_SDK_TYPE) clang++
	CPP = xcrun --sdk $(IOS_SDK_TYPE) clang++

	# Compiler options

	CC_OPTIONS += -Wno-parentheses -Wno-logical-op-parentheses -Wno-tautological-constant-out-of-range-compare

endif

ifneq ($(findstring gcc, $(CC)),)					#--------------------------------------------	Any GNU GCC-like compiler
	
	ifneq ($(findstring ios, $(ARCH)),)				# iPhone iOS 6, iOS 7
		ifndef CODE_GEN
			CODE_GEN = -arch armv7s
		endif
	endif

	# Compiler options
	CC_OPTIONS := -c -O3 -Wall $(CODE_GEN) $(CC_OPTIONS)

	CPP_OPTIONS = $(CC_OPTIONS) -fno-rtti


	# Archiver options

	ifneq ($(findstring mac, $(ARCH)),)						# Mac OS/X GCC
		ifneq ($(findstring -arch, $(CC_OPTIONS)),)
			AR = libtool									# univeral binaries
			
			AR_OPTIONS = -o
		else
			AR_OPTIONS = rcv -s
		endif
	else
		AR_OPTIONS = rcv
	endif

	# Linker options
	ifneq ($(findstring ios, $(ARCH)),)						# iPhone iOS 6, iOS 7
		LD_OPTIONS += $(CODE_GEN)
	endif
	ifneq ($(findstring ios6, $(ARCH)),)					# iPhone iOS 6
		LD_OPTIONS += -isysroot $(IOS_SDK)
	endif

	# Stardard C Libraries
	
	STD_LIBS +=
	
	# File extensions
	ifneq ($(findstring arm,$(ARCH)),)
		OUT_EXT =
	else ifeq ($(TERM), cygwin)
		OUT_EXT = exe
	else
		OUT_EXT =
	endif

endif

ifneq ($(findstring msvc, $(ARCH)),)	#-------------------------------------------- MS Visual Studio

	# Build tools

	CC = cl.exe
	AR = lib.exe
	LD = link.exe
	CPP = cl.exe

	# Compiler options
	
	ifneq ($(findstring arm, $(ARCH)),)
		CC_OPTIONS += /Ox /nologo /DWINAPI_FAMILY=WINAPI_FAMILY_PHONE_APP /Fo"$(OBJ_DIR)/" /Fd"$(OBJ_DIR)/" /FR"$(OBJ_DIR)/" /c
	else	
		ifeq ($(CFG), Release)
			ifndef CODE_GEN
				CODE_GEN = /MT /O2 /Ob2 /Oi /Ot /GF /Gy /EHsc 
			endif
	
			CC_OPTIONS += /nologo $(CODE_GEN) /D "WIN32" /D "NDEBUG" /D "_LIB" /D "_VC80_UPGRADE=0x0600" /D "_MBCS" /W3 /D _CRT_SECURE_NO_WARNINGS /Fo"$(OBJ_DIR)/" /Fd"$(OBJ_DIR)/" /FR"$(OBJ_DIR)/" /c /TP /errorReport:prompt
		else ifeq ($(CFG), Debug)
			ifndef CODE_GEN
				CODE_GEN = /MTd /Od /Gm /EHsc /RTC1
			endif
	
			CC_OPTIONS += /nologo $(CODE_GEN) /D "WIN32" /D "_DEBUG" /D "_LIB" /D "_VC80_UPGRADE=0x0600" /D "_MBCS" /W3 /D _CRT_SECURE_NO_WARNINGS /Fo"$(OBJ_DIR)/" /Fd"$(OBJ_DIR)/" /FR"$(OBJ_DIR)/" /Zi /c /TP /errorReport:prompt
		endif
	endif

	# Archiver options
	ifneq ($(findstring arm, $(ARCH)),)
		AR_OPTIONS = /MACHINE:ARM /NOLOGO /SUBSYSTEM:NATIVE
	else
		AR_OPTIONS = /nologo
	endif

	ifneq ($(findstring arm, $(ARCH)),)
		MACHINE = ARM
	else ifneq ($(findstring x64, $(ARCH)),)
		MACHINE = x64
	else
		MACHINE = x86
	endif

	# Linker options
	ifneq ($(findstring arm, $(ARCH)),)
		LD_OPTIONS += /nologo /machine:$(MACHINE)
	else
		LD_OPTIONS += /nologo /subsystem:console /machine:$(MACHINE) /DYNAMICBASE:NO /ERRORREPORT:PROMPT
	endif

	ifeq ($(CFG), Debug)
		LD_OPTIONS += /debug
	endif
	
	# Stardard C Libraries

	STD_LIBS = 

	# File extensions
	OBJ_EXT = obj
	LIB_EXT = lib
	OUT_EXT = exe

endif

ifneq ($(findstring C6, $(ARCH)),)		#-------------------------------------------- TI C6x

	# Build tools

	CC = cl6x
	AR = ar6x
	LD = cl6x
	CPP = cl6x

	# Compiler options
	
	ifndef CODE_GEN
		CODE_GEN = --abi=eabi --symdebug:none
	endif
	
	ifeq ($(ARCH), C674x)
		CC_OPTIONS += -O3 -mv6740 $(CODE_GEN) -fr"$(OBJ_DIR)"
	else
		CC_OPTIONS += -O3 -mv6400+ $(CODE_GEN) -fr"$(OBJ_DIR)"
	endif
	
	# Archiver options
	AR_OPTIONS = -r

	# Linker options
	LD_OPTIONS += -z -q -c -x -w
ifdef TARGET
	LD_OPTIONS += -m $(OUT_DIR)/$(TARGET).map
endif

	# Stardard C Libraries
	ifeq ($(ARCH), C674x)
		RTS_LIB = rts6740
	else
		RTS_LIB = rts64plus
	endif
	
	ifneq ($(findstring --abi=eabi, $(CC_OPTIONS)),)
		STD_LIBS += -l $(RTS_LIB)_elf.lib
	else
		STD_LIBS += -l $(RTS_LIB).lib
	endif
	
	# File extensions
	OBJ_EXT = obj
	LIB_EXT = lib
	OUT_EXT = out
	
	ifeq ($(ARCH), C674x)
		LD_CMD_FILE = $(TOOLS_DIR)/C674xLink.cmd
	else
		LD_CMD_FILE = $(TOOLS_DIR)/C64x+Link.cmd
	endif

endif

ifeq ($(ARCH), pnx1500)					#-------------------------------------------- PNX 1500

	# Build tools
	CC = tmcc
	AR = tmar
	LD = tmc++
	CPP = tmc++
endif
ifeq ($(ARCH), pnx1700)					#-------------------------------------------- PNX 1700

	# Build tools
	CC = tmcc
	AR = tmar
	LD = tmc++
	CPP = tmc++
endif

ifeq ($(CC), tmcc)						#-------------------------------------------- Any TCS 

	# Compiler options
	CC_OPTIONS += -c -B -O5 -Xalign -target $(ARCH) -tm32v2_opt -el

	# Archiver options
	AR_OPTIONS = rcv

	# Linker options
	LD_OPTIONS += -host $(HOST) -target $(ARCH) -tm32v2_opt -el

	# Stardard C Libraries
	STD_LIBS +=

	ifndef HOST
		HOST = WinNT
	endif

endif

#------------------------------------------------------------------------------

ifndef CPP_OPTIONS 
	CPP_OPTIONS = $(CC_OPTIONS)
endif

#------------------------------------------------------------------------------

RM = rm -Rf

#------------------------------------------------------------------------------
#	ASDSP Tools Dependencies
#------------------------------------------------------------------------------

ASDSP_DEPS += \
	$(TARGET).mak \
	$(TOOLS_INC_DIR)/ASDSP.h\
	$(TOOLS_INC_DIR)/ASDSP_Ver.h\
	$(TOOLS_INC_DIR)/TextOut.h\
	$(TOOLS_INC_DIR)/PCM_File.h\
	$(TOOLS_INC_DIR)/CmdLine.h\
	$(TOOLS_INC_DIR)/CmdParser.h\
	$(TOOLS_INC_DIR)/Probe.h\
	$(TOOLS_INC_DIR)/CoarseInverse.h\
	$(TOOLS_INC_DIR)/CoarseLog2.h\
	$(TOOLS_INC_DIR)/CoarseSin.hpp\


#******************************************************************************
#
#	Copyright (C) 2003-2014 -- ASDSP S.r.l. -- www.asdsp.com
#
#******************************************************************************
