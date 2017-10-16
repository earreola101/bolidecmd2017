#******************************************************************************
#
#	Description:	LibTargets.mak - Library Target List Makefile include
#
#	Copyright (C) 2016 -- ASDSP Ltd -- www.asdsp.com
#
#******************************************************************************

ALL_LIST = \
	obj_dir $(OBJECTS) \
	lib_dir	$(LIB_DIR)/$(TARGET).$(LIB_EXT)


CLEAN_LIST = $(OBJ_DIR)/*.$(OBJ_EXT) \
			 $(LIB_DIR)/$(TARGET).$(LIB_EXT)


#------------------------------------------------------------------------------
#	Targets
#------------------------------------------------------------------------------

all: $(ALL_LIST)

obj_dir:
	mkdir -p $(OBJ_DIR)

lib_dir:
	mkdir -p $(LIB_DIR)

clean :
	$(RM) $(CLEAN_LIST)


#******************************************************************************
#
#	Copyright (C) 2016 -- ASDSP Ltd -- www.asdsp.com
#
#******************************************************************************
