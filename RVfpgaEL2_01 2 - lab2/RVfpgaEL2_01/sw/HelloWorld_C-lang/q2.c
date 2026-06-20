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

void fibonacci(){
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

int main(void)
{
  pspMachinePerfMonitorEnableAll();
  pspMachinePerfCounterSet(D_PSP_COUNTER0, D_CYCLES_CLOCKS_ACTIVE);
  unsigned int cyc_beg, cyc_end, net_time;

  cyc_beg = pspMachinePerfCounterGet(D_PSP_COUNTER0);
  fibonacci();
  cyc_end = pspMachinePerfCounterGet(D_PSP_COUNTER0);

  net_time = cyc_end - cyc_beg;
  printfNexys("Net run time in cycles: %u\n", net_time);

}