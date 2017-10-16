#******************************************************************************
#
#	Description:	CC_Rules.mak - Compiler Rules Makefile include
#
#	Copyright (C) 2016 -- ASDSP Ltd -- www.asdsp.com
#
#******************************************************************************

ifndef SRC_DIR
	SRC_DIR = .
endif

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

#******************************************************************************
#
#	Copyright (C) 2016 -- ASDSP Ltd -- www.asdsp.com
#
#******************************************************************************
