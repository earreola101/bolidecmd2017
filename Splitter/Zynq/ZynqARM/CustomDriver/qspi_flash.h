#ifndef QSPI_FLASH_H__
#define QSPI_FLASH_H__

#include "xqspips.h"		/* QSPI device driver */
#include <stdio.h>


/*
 * The following constants specify the page size, sector size, and number of
 * pages and sectors for the FLASH.  The page size specifies a max number of
 * bytes that can be written to the FLASH with a single transfer.
 */
#define SECTOR_SIZE		0x10000
#define NUM_SECTORS		0x100
#define NUM_PAGES		0x10000
#define PAGE_SIZE		256

int qspi_flash_init();
void qspi_flash_erase(uint32_t Address, uint32_t ByteCount);
void qspi_flash_write(uint32_t Address, uint32_t ByteCount, uint8_t *buf);
void qspi_flash_erase_all();
#endif
