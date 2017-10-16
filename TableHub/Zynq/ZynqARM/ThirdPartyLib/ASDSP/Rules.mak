#******************************************************************************
#
#	Description:	Rules.mak - GNU Makefile include
#
#	Copyright (C) 2003-2011 -- ASDSP S.r.l. -- www.asdsp.com
#
#******************************************************************************

ifndef SRC_DIR
	SRC_DIR = .
endif

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

ifeq ($(CC),cl6x)

$(OBJ_DIR)/%.$(OBJ_EXT): $(SRC_DIR)/%.c
	$(CC) $(CC_OPTIONS) $(INCLUDES) $(DEFINES) $(SRC_DIR)/$*.c 

$(OBJ_DIR)/%.$(OBJ_EXT): $(SRC_DIR)/%.cpp
	$(CC) $(CPP_OPTIONS) $(INCLUDES) $(DEFINES) $(SRC_DIR)/$*.cpp

else ifneq ($(findstring msvc, $(ARCH)),)

$(OBJ_DIR)/%.$(OBJ_EXT): $(SRC_DIR)/%.c
	$(CC) $(CC_OPTIONS) $(INCLUDES) $(DEFINES) $(SRC_DIR)/$*.c

$(OBJ_DIR)/%.$(OBJ_EXT): $(SRC_DIR)/%.cpp
	$(CC) $(CPP_OPTIONS) $(INCLUDES) $(DEFINES) $(SRC_DIR)/$*.cpp

else

$(OBJ_DIR)/%.$(OBJ_EXT): $(SRC_DIR)/%.c
	$(CC) $(CC_OPTIONS) $(INCLUDES) $(DEFINES) -o $@ $(SRC_DIR)/$*.c

$(OBJ_DIR)/%.$(OBJ_EXT): $(SRC_DIR)/%.cpp
	$(CPP) $(CPP_OPTIONS) $(INCLUDES) $(DEFINES) -o $@ $(SRC_DIR)/$*.cpp

endif


#------------------------------------------------------------------------------
#	Library rules
#------------------------------------------------------------------------------

ifneq ($(findstring msvc, $(ARCH)),)

$(LIB_DIR)/$(TARGET).$(LIB_EXT) : $(OBJECTS)
	$(AR) $(AR_OPTIONS) /out:$(LIB_DIR)/$(TARGET).$(LIB_EXT) $(OBJECTS)

else

$(LIB_DIR)/$(TARGET).$(LIB_EXT) : $(OBJECTS)
	$(AR) $(AR_OPTIONS) $(LIB_DIR)/$(TARGET).$(LIB_EXT) $(OBJECTS)

endif


#------------------------------------------------------------------------------
#	Linker rules
#------------------------------------------------------------------------------

ifneq ($(findstring msvc, $(ARCH)),)

$(OUT_DIR)/$(OUT_NAME) :  $(OBJECTS) $(LIBRARIES)
	$(LD) $(LD_OPTIONS) /pdb:"$(OUT_DIR)/$(TARGET).pdb" /out:"$(OUT_DIR)/$(OUT_NAME)" $(OBJECTS) $(LIBRARIES) $(STD_LIBS)

else

$(OUT_DIR)/$(OUT_NAME) : $(OBJECTS) $(LIBRARIES) $(LD_CMD_FILE)
	$(LD) $(LD_OPTIONS) -o $(OUT_DIR)/$(OUT_NAME) $(OBJECTS) $(LIBRARIES) $(STD_LIBS) $(LD_CMD_FILE)

endif

#******************************************************************************
#
#	Copyright (C) 2003-2011 -- ASDSP S.r.l. -- www.asdsp.com
#
#******************************************************************************
