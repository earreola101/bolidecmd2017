#******************************************************************************
#
#	Description:	AR_Rules.mak - Archiver Rules Makefile include
#
#	Copyright (C) 2016 -- ASDSP Ltd -- www.asdsp.com
#
#******************************************************************************

ifneq ($(findstring msvc, $(ARCH)),)

$(LIB_DIR)/$(TARGET).$(LIB_EXT) : $(OBJECTS)
	$(AR) $(AR_OPTIONS) /out:$(LIB_DIR)/$(TARGET).$(LIB_EXT) $(OBJECTS)

else

$(LIB_DIR)/$(TARGET).$(LIB_EXT) : $(OBJECTS)
	$(AR) $(AR_OPTIONS) $(LIB_DIR)/$(TARGET).$(LIB_EXT) $(OBJECTS)

endif

#******************************************************************************
#
#	Copyright (C) 2016 -- ASDSP Ltd -- www.asdsp.com
#
#******************************************************************************
