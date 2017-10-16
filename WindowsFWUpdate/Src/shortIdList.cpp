#include "shortIdList.h"


shortIdList::shortIdList()
{
	shortIdMap[0x0524d216325885c] = "5H";
	shortIdMap[0x1504d2163258854] = "7M";
	shortIdMap[0x0024d216325885c] = "11M - 23H - 27H";
	shortIdMap[0x0324d216325885c] = "12M";
	shortIdMap[0x1424d216325885c] = "13M - 14M - 26H";
	shortIdMap[0x14c4d2163258854] = "15M";
	//H
	shortIdMap[0x0404d216325885c] = "17M";
	shortIdMap[0x13c4d216325885c] = "18M";	
	shortIdMap[0x07c4d2163258854] = "19M - 16H";
	shortIdMap[0x13c4d2163258854] = "20M - 29M - 36M"; 
	shortIdMap[0x10c4d216325885c] = "21M"; 
	shortIdMap[0x17c4d2163258854] = "22M";
	//23 speaker hub
	shortIdMap[0x1184d2163258854] = "24H";
	shortIdMap[0x1024d216325885c] = "25H";

	shortIdMap[0x0024d2163258854] = "28M";
	shortIdMap[0x04c4d2163258854] = "31M";
	shortIdMap[0x0424d216325885c] = "32M";
	shortIdMap[0x1024d216325885c] = "33M";
	shortIdMap[0x10c4d2163258854] = "34M";
	shortIdMap[0x0024d2163258854] = "35M";
	//36S
	//37S

	shortIdMap[0x01c94490a61081c] = "101";
	shortIdMap[0x01294490a610814] = "102";
	shortIdMap[0x11cc186612cb014] = "103";
	shortIdMap[0x03881401029705c] = "104";
	shortIdMap[0x11460c01029705c] = "105";
	shortIdMap[0x04881401029705c] = "106";
	
	 

}

QString shortIdList::getShortID(uint64_t unique_id)
{
	return shortIdMap[unique_id];
}