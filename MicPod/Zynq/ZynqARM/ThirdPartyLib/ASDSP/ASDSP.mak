#******************************************************************************
#
#	Description:	ASDSP.mak - GNU Makefile
#
#	Copyright (C) 2016 -- ASDSP Ltd -- www.asdsp.com
#
#******************************************************************************

TARGET = ASDSP

#--------------------------------------
#	Multi Platform Build Options
#--------------------------------------

TOOLS_DIR = .

include $(TOOLS_DIR)/Platforms.mak


#--------------------------------------
#	Directories
#--------------------------------------

SRC_DIR = src
INC_DIR = include

INCLUDES = $(TOOLS_INC)


#--------------------------------------
#	Preprocessor defines
#--------------------------------------

DEFINES = $(ASDSP_EXT_DEFINE)


#--------------------------------------
#	Object list
#--------------------------------------

OBJECTS = \
	$(OBJ_DIR)/CmdLine.$(OBJ_EXT) \
	$(OBJ_DIR)/CmdParser.$(OBJ_EXT) \
	$(OBJ_DIR)/PCM_File.$(OBJ_EXT) \
	$(OBJ_DIR)/Probe.$(OBJ_EXT) \
	$(OBJ_DIR)/TextOut.$(OBJ_EXT) \
	$(OBJ_DIR)/SignalGenerator.$(OBJ_EXT)\

ifneq ($(findstring _COARSE_INVERSE_=1, $(ASDSP_EXT_DEFINE)),)
	OBJECTS += $(OBJ_DIR)/CoarseInverse.$(OBJ_EXT)
endif
ifneq ($(findstring _COARSE_LOG2_=1, $(ASDSP_EXT_DEFINE)),)
	OBJECTS += $(OBJ_DIR)/CoarseLog2.$(OBJ_EXT)
endif
ifneq ($(findstring _COARSE_SIN_=1, $(ASDSP_EXT_DEFINE)),)
	OBJECTS += $(OBJ_DIR)/CoarseSin.$(OBJ_EXT)
endif

#--------------------------------------
#	Library Target List and Rules
#--------------------------------------

include LibTargets.mak

include CC_Rules.mak

DAM_SRC_DIR = $(TOOLS_DIR)/SHARC/ADSP-21489

$(OBJ_DIR)/DMA_SDRAM.$(OBJ_EXT): $(DAM_SRC_DIR)/DMA_SDRAM.cpp
	$(CPP) $(CPP_OPTIONS) $(INCLUDES) $(DEFINES) -o $@ $(DAM_SRC_DIR)/DMA_SDRAM.cpp

include AR_Rules.mak


#--------------------------------------
#	Additional Targets
#--------------------------------------

SETTINGS = $(RELEASE_DIR)/$(ARCH)/Settings.mak

release:
	mkdir -p $(RELEASE_DIR)/$(LIB_DIR)
	cp $(LIB_DIR)/$(TARGET).$(LIB_EXT)		$(RELEASE_DIR)/$(LIB_DIR)
	cp $(INC_DIR)/ASDSP_Ver.h				$(RELEASE_DIR)
	cp *.mak								$(RELEASE_DIR)
	echo ARCH = $(ARCH)									>  $(SETTINGS)
	echo CFG = $(CFG)									>> $(SETTINGS)
	echo CC = $(CC)										>> $(SETTINGS)
	echo CPP = $(CPP)									>> $(SETTINGS)
	echo AR = $(AR)										>> $(SETTINGS)
	echo LD = $(LD)										>> $(SETTINGS)
	echo CC_OPTIONS	 = $(CC_OPTIONS)					>> $(SETTINGS)
	echo CPP_OPTIONS = $(CPP_OPTIONS)					>> $(SETTINGS)
	echo AR_OPTIONS = $(AR_OPTIONS)						>> $(SETTINGS)
	echo LD_OPTIONS = $(LD_OPTIONS)						>> $(SETTINGS)
	echo STD_LIBS	= $(STD_LIBS)						>> $(SETTINGS)
	echo ASDSP_EXT_DEFINE	= $(ASDSP_EXT_DEFINE)		>> $(SETTINGS)


ESCROW_TOOLS_DIR = $(ESCROW_DIR)/ASDSP/Tools

escrow:
	mkdir -p $(ESCROW_TOOLS_DIR)/$(SRC_DIR)
	mkdir -p $(ESCROW_TOOLS_DIR)/$(INC_DIR)
	cp Makefile						$(ESCROW_TOOLS_DIR)
	cp *.mak						$(ESCROW_TOOLS_DIR)
	cp ASDSP.dep					$(ESCROW_TOOLS_DIR)
	cp $(SRC_DIR)/*.cpp				$(ESCROW_TOOLS_DIR)/$(SRC_DIR)
	cp $(INC_DIR)/*.hpp				$(ESCROW_TOOLS_DIR)/$(INC_DIR)
	cp $(INC_DIR)/*.h				$(ESCROW_TOOLS_DIR)/$(INC_DIR)


#--------------------------------------
#	Dependencies
#--------------------------------------

include $(TARGET).dep


#******************************************************************************
#
#	Copyright (C) 2016 -- ASDSP Ltd -- www.asdsp.com
#
#******************************************************************************

