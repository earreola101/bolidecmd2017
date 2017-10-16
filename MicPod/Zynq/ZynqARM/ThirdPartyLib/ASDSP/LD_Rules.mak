#******************************************************************************
#
#	Description:	LD_Rules.mak - Linker Rules Makefile include
#
#	Copyright (C) 2016 -- ASDSP Ltd -- www.asdsp.com
#
#******************************************************************************

ifneq ($(findstring msvc, $(ARCH)),)

$(OUT_DIR)/$(OUT_NAME) : $(OBJECTS) $(LIBRARIES)
	$(LD) $(LD_OPTIONS) /pdb:"$(OUT_DIR)/$(TARGET).pdb" /out:"$(OUT_DIR)/$(OUT_NAME)" $(OBJECTS) $(LIBRARIES) $(STD_LIBS)

else

$(OUT_DIR)/$(OUT_NAME) : $(OBJECTS) $(LIBRARIES) $(LD_CMD_FILE)
	$(LD) $(LD_OPTIONS) -o $(OUT_DIR)/$(OUT_NAME) $(OBJECTS) $(LIBRARIES) $(STD_LIBS) $(LD_CMD_FILE)

endif

#******************************************************************************
#
#	Copyright (C) 2016 -- ASDSP Ltd -- www.asdsp.com
#
#******************************************************************************
