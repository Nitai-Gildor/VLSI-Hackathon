#if defined(D_NEXYS_A7)
   #include <bsp_printf.h>
   #include <bsp_mem_map.h>
   #include <bsp_version.h>
#else
   PRE_COMPILED_MSG("no platform was defined")
#endif
#include <psp_api.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

int main(void)
{
  
   uartInit();

   int num1 = 0, num2 = 1, temp = 0;
   printfNexys("%d\n", num1);
   printfNexys("%d\n", num2);
   
   for (int i=0;i<10;i++){
       temp = num2;
       num2 = num1 + num2;
       num1 = temp;
       printfNexys("%d\n", num2); 
   }
   printfNexys("Number of students: 2\n");
   printfNexys("Itamar Morag: 316526557\n");
   printfNexys("Nitai Gildor: 318657780\n"); 
   

}