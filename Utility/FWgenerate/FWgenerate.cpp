#include <stdio.h>
#include <cstdlib>
#include <string.h>
#include <stdlib.h>
#include "md5.h"

#define FW_UPDATE_MAX_SIZE					(0x400000)
unsigned char fw_ram_loc[FW_UPDATE_MAX_SIZE];
int main(int argc, char* argv[])
{
	if(argc != 6)
	{

		printf("Usage\n");
		printf("FWgenerate.exe ver0 ver1 ver2 ver3 file_path");
		getchar();
		return 0;
	}
	int ver0 = atoi(argv[1]);
	int ver1 = atoi(argv[2]);
	int ver2 = atoi(argv[3]);
	int ver3 = atoi(argv[4]);
	char * fileIn = argv[5];
	char fileOut[200];
	char strAux[200];
	printf("Generating FW update file :\n");
	printf("Version 0: %d\n", ver0);
	printf("Version 1: %d\n", ver1);
	printf("Version 2: %d\n", ver2);
	printf("Version 3: %d\n", ver3);
	printf("File name: %s\n",fileIn);
	strcpy(fileOut, fileIn);
	sprintf(strAux,".%d_%d_%d_%d.md5",ver0,ver1,ver2,ver3);
	strcat(fileOut,strAux); 
	printf("Output file: %s\n",fileOut);

	FILE * fidIn = fopen(fileIn,"rb");
	FILE * fidOut = 0;
//	FILE * fidOut = fopen(fileOut,"wb");
	
	int indexW=0;
	while(1)
	{
		int res = fread(&fw_ram_loc[indexW],sizeof(char),1,fidIn);
		
//		if(res>0)
//			fwrite(buf,sizeof(char),res,fidOut);
//		else
//			break;
		if(res<=0)
			break;
		//printf("%d: %x\n",indexW,fw_ram_loc[indexW]);
		indexW++;
	}

	memcpy(&fw_ram_loc[indexW],&ver0,sizeof(ver0));
	indexW+=sizeof(ver0);
	memcpy(&fw_ram_loc[indexW],&ver1,sizeof(ver1));
	indexW+=sizeof(ver1);
	memcpy(&fw_ram_loc[indexW],&ver2,sizeof(ver2));
	indexW+=sizeof(ver2);
	memcpy(&fw_ram_loc[indexW],&ver3,sizeof(ver3));
	indexW+=sizeof(ver3);
	
//	fwrite(&ver0,sizeof(ver0),1,fidOut);
//	fwrite(&ver1,sizeof(ver1),1,fidOut);
//	fwrite(&ver2,sizeof(ver2),1,fidOut);
//	fwrite(&ver3,sizeof(ver3),1,fidOut);
//	fclose(fidOut);

	printf("version done\n");
	
	MD5 md5;
	char * md5Computed;
	md5Computed = md5.digestMemory(fw_ram_loc, indexW);
	for(int i=0; i<MD5_LENGTH; i++)
		printf("%d: %x\n",i, md5Computed[i]);
	
	fidOut = fopen(fileOut, "wb");

	fwrite(fw_ram_loc,1,indexW,fidOut);
	int res = fwrite(md5Computed,1,MD5_LENGTH,fidOut);
	fclose;
	printf("md5 done %d\n", res);

    return 0;
}