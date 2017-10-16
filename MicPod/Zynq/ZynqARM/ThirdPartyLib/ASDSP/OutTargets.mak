#******************************************************************************
#
#	Description:	OutTargets.mak - Executable Target List Makefile include
#
#	Copyright (C) 2016 -- ASDSP Ltd -- www.asdsp.com
#
#******************************************************************************

ifneq ($(OUT_EXT),)
	OUT_NAME = $(TARGET).$(OUT_EXT)
else
	OUT_NAME = $(TARGET)
endif

ALL_LIST = obj_dir $(OBJECTS) out_dir	$(OUT_DIR)/$(OUT_NAME)

CLEAN_LIST = $(OBJ_DIR)/*.$(OBJ_EXT)  $(OUT_DIR)/$(OUT_NAME)


#------------------------------------------------------------------------------
#	Targets
#------------------------------------------------------------------------------

all: $(ALL_LIST)

obj_dir:
	mkdir -p $(OBJ_DIR)

out_dir:
	mkdir -p $(OUT_DIR)

clean :
	$(RM) $(CLEAN_LIST)


#******************************************************************************
#
#	Copyright (C) 2016 -- ASDSP Ltd -- www.asdsp.com
#
#******************************************************************************
