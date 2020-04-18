#define _CRT_SECURE_NO_WARNINGS

#include <iostream>
#include <fstream>

int main()
{
	FILE* output = fopen("W://hack.txt", "wb");

	int first_byte = 1;
	//29
	int last_byte = 19;
	int zero = 0;
	int enter = 13;
	//65175

	//65152
	for (int i = 0; i < 65152; ++i)
	{
		fwrite(&zero, 1, 1, output);
	}
	
	fwrite(&last_byte, 1, 1, output);
	fwrite(&first_byte, 1, 1, output);

    fwrite(&enter, 1, 1, output);

	return 0;
}
