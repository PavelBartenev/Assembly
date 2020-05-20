#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <iostream>

const char Insert_symbol = 0xEB;

const int Insert_place = 15;

const int Right_hash = 189041;

int main()
{
	FILE* code = fopen("W:\\PIUPIU.com", "r");
	FILE* patch = fopen("W:\\PIUPATCH.com", "wb");

	fseek(code, 0, SEEK_END);
	int file_size = ftell(code);
	fseek(code, 0, SEEK_SET);

	char* buffer = (char*)calloc(file_size, sizeof(char));

	if (!buffer)
		return 1;

	fread(buffer, sizeof(char), file_size, code);

	int hash = 0;

	for (int i = 0; i < file_size; ++i)
		hash += buffer[i] * i;
	
	if (hash != Right_hash)
	{
		printf("Wrong file\n");
		return 2;
	}

    buffer[Insert_place] = Insert_symbol;
	
	fwrite(buffer, sizeof(char), file_size, patch);

	free(buffer);

	return 0;
}
