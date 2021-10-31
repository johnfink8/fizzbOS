#include "string.h"
#include "kernel.h"
#define WHITE_TEXT 0x0F 
/*
Color codes: 
Dec	Hex	Binary	Color
0	0	0000	Black	
1	1	0001	Blue	
2	2	0010	Green	
3	3	0011	Cyan	
4	4	0100	Red	
5	5	0101	Magenta	
6	6	0110	Brown	
7	7	0111	Light Gray	
8	8	1000	Dark Gray	
9	9	1001	Light Blue	
10	A	1010	Light Green	
11	B	1011	Light Cyan	
12	C	1100	Light Red	
13	D	1101	Light Magenta	
14	E	1110	Yellow	
15	F	1111	White	
*/
#define SCREEN_WIDTH 80
#define SCREEN_HEIGHT 25

char buffer[32];

unsigned int line = 0;
unsigned int position = 0;

/* Technically this is a kernel, I think  */
void kernel_main() 
{
	unsigned long num=1;
	print_primitive("Holy shit it's starting",0);
	clear_screen();
	line++;
	while(1){
		fizzbuzz_calc(num);
		num++;
	}

};
void fizzbuzz_calc(unsigned long num){
	if (!(num%3)){
		print_prim_p("Fizz");
	}
	if (!(num%5)){
		print_prim_p("Buzz");
	}
	if ((num%3) && (num%5)){
		itoa(num, buffer, 32, 10);
		print_prim_p(buffer);
	}
	for (int i=position; i<SCREEN_WIDTH; i++){
		print_prim_p(" ");
	}
	line++;
	position=0;
}

void clear_screen()
{
	char *video = (char *) 0xb8000;
	unsigned int i=0;
	while(i < (SCREEN_WIDTH*SCREEN_HEIGHT*2))
	{
		video[i]=' ';
		i++;
		video[i]=WHITE_TEXT;
		i++;
	};
};

unsigned int print_primitive(char *message, unsigned int line)
{
	char *video = (char *) 0xb8000;
	unsigned int i=0;

	i=(line*SCREEN_WIDTH*2);

	while(*message!=0)
	{
		if(*message=='\n') // check for a new line
		{
			line++;
			i=(line*SCREEN_WIDTH*2);
			*message++;
		} else {
			video[i]=*message;
			*message++;
			i++;
			video[i]=WHITE_TEXT;
			i++;
		};
	};

	return(1);
}

/* print function with persistent "cursor" position # */
unsigned int print_prim_p(char *message)
{
	char *video = (char *) 0xb8000;
	unsigned int i=0;

	if (position > SCREEN_WIDTH){
		position=0;
		line++;
	}
	if (line > SCREEN_HEIGHT){
		// wrap lines back to the top I guess
		line=0;
	}

	i=(line*SCREEN_WIDTH*2) + (position*2);

	while(*message)
	{

		video[i++]=*message++;
		video[i++]=WHITE_TEXT;
		position++;

	}

	return 0;
}