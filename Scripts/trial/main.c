#include <stdio.h>

int main()
{
	float f = 270;
	printf("%03d:\t%f\n",0,f);
	for(int i = 0; i < 150; i++)
	{
		f -= (float)(2*1) - (float)2 * 0.1f;
		printf("%03d:\t%f\n",i+1,f);
	}
	return 0;
}
