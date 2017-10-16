#******************************************************************************
#
#	Description:	Rules.mak - GNU Makefile include
#
#	Copyright (C) 2016 -- ASDSP Ltd -- www.asdsp.com
#
#******************************************************************************

ifneq ($(OUT_EXT),)
	OUT_NAME = $(TARGET).$(OUT_EXT)
else
	OUT_NAME = $(TARGET)
endif

ALL_LIST = obj_dir $(OBJECTS)

CLEAN_LIST = $(OBJ_DIR)/*.$(OBJ_EXT)

ifndef LIBRARIES
	OUT_DIR =							# this forces to generate static libraries
endif

ifneq ($(OUT_DIR),)
	ALL_LIST	+= out_dir	$(OUT_DIR)/$(OUT_NAME)
	CLEAN_LIST	+= $(OUT_DIR)/$(OUT_NAME)
else
	ALL_LIST	+= lib_dir	$(LIB_DIR)/$(TARGET).$(LIB_EXT)
	CLEAN_LIST	+= $(LIB_DIR)/$(TARGET).$(LIB_EXT)
endif


#------------------------------------------------------------------------------
#	Targets
#------------------------------------------------------------------------------

all: $(ALL_LIST)

obj_dir:
	mkdir -p $(OBJ_DIR)

lib_dir:
	mkdir -p $(LIB_DIR)

out_dir:
	mkdir -p $(OUT_DIR)

clean :
	$(RM) $(CLEAN_LIST)


#------------------------------------------------------------------------------
#	Compiler Rules
#------------------------------------------------------------------------------

include $(TOOLS_DIR)/CC_Rules.mak


#------------------------------------------------------------------------------
#	Library rules
#------------------------------------------------------------------------------

include $(TOOLS_DIR)/AR_Rules.mak


#------------------------------------------------------------------------------
#	Linker rules
#------------------------------------------------------------------------------

include $(TOOLS_DIR)/LD_Rules.mak


#******************************************************************************
#
#	Copyright (C) 2016 -- ASDSP Ltd -- www.asdsp.com
#
#******************************************************************************
