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
#include <stdint.h>

#define ACCELERATOR_REG_CTRL		0x80001300	// 
#define ACCELERATOR_REG_A		0x80001304	//
#define ACCELERATOR_REG_B		0x80001308	// 
#define ACCELERATOR_REG_C		0x8000130C	//  
#define ACCELERATOR_REG_D	        0x80001310	//
#define ACCELERATOR_REG_RESULT	        0x80001314	//

#define READ_GPIO(dir) (*(volatile unsigned *)dir)
#define WRITE_GPIO(dir, value) { (*(volatile unsigned *)dir) = (value); }

//#define VIVADO_SIMULATOR


const uint8_t MATRIX1[8][8] = {
    { 53, 24, 92, 10, 49, 99, 15, 72 },
    { 30, 69, 88, 77, 45, 65, 16, 81 },
    { 24,  6, 55, 26, 31, 48, 37, 12 },
    {  4, 71, 98, 82, 59, 39, 79, 97 },
    { 96, 40, 14, 95, 50, 29, 66, 17 },
    {  2, 94, 33, 61, 91, 88, 78, 54 },
    { 60, 35, 73, 62, 57, 18, 47, 85 },
    { 20, 11, 21, 83, 38, 44, 64, 91 }
};

const uint8_t MATRIX2[8][8] = {
    { 30, 66, 84, 88, 13, 49, 19, 93 },
    { 28, 31, 67, 14, 79, 17, 27, 45 },
    { 50, 56, 47, 24, 34, 57, 70, 82 },
    {  8, 60, 54, 76, 80, 33, 40, 95 },
    {  4, 75, 22, 29, 59, 41, 64, 29 },
    { 95, 12, 71, 53, 14, 38, 22, 16 },
    {  7, 37, 68, 41, 61, 12, 58, 55 },
    { 99, 65, 25, 20, 46, 91, 32, 68 }
};


// Pack 4 numbers into register
uint32_t pack_col(uint8_t b3, uint8_t b2, uint8_t b1, uint8_t b0) {
    return ((uint32_t)(uint8_t)b3 << 24) | 
           ((uint32_t)(uint8_t)b2 << 16) | 
           ((uint32_t)(uint8_t)b1 << 8)  | 
           ((uint32_t)(uint8_t)b0);
}


int main ( void )
{
   int reg_a_value, reg_b_value, reg_c_value, reb_d_value, reg_status_value;
   int results[8][8] = {0};
   int cyc_beg, cyc_end; //For clock 
   

//#ifndef VIVADO_SIMULATOR

   pspMachinePerfMonitorEnableAll();

   pspMachinePerfCounterSet(D_PSP_COUNTER0, D_CYCLES_CLOCKS_ACTIVE);
   cyc_beg = pspMachinePerfCounterGet(D_PSP_COUNTER0);

//#endif

   for (int i=0; i < 8; i++) {

      //Load matrix 1 row
      uint32_t val_A = *((uint32_t*)&MATRIX1[i][0]);
      uint32_t val_C = *((uint32_t*)&MATRIX1[i][4]);

      for (int j=0; j < 8; j++){
        uint32_t val_B = pack_col(MATRIX2[3][j], MATRIX2[2][j], MATRIX2[1][j], MATRIX2[0][j]);
        uint32_t val_D = pack_col(MATRIX2[7][j], MATRIX2[6][j], MATRIX2[5][j], MATRIX2[4][j]);
        

        WRITE_GPIO(ACCELERATOR_REG_A, val_A);
        WRITE_GPIO(ACCELERATOR_REG_B, val_B);
        WRITE_GPIO(ACCELERATOR_REG_C, val_C);
        WRITE_GPIO(ACCELERATOR_REG_D, val_D);

        // Set GO bit
        WRITE_GPIO(ACCELERATOR_REG_CTRL, 1);

        // Poll for DONE
        while ((READ_GPIO(ACCELERATOR_REG_CTRL) & 0x80000000) == 0);

        results[i][j] = READ_GPIO(ACCELERATOR_REG_RESULT);

        // Delete GO
        WRITE_GPIO(ACCELERATOR_REG_CTRL, 0);
      }
    }

   
#ifndef VIVADO_SIMULATOR   
   cyc_end = pspMachinePerfCounterGet(D_PSP_COUNTER0);
    
   printf("Cycles = %d", cyc_end-cyc_beg);

    // Print result matrix
    printf("\nResult Matrix:\n");
    for (int i = 0; i < 8; i++) {
        printf("[");
        for (int j = 0; j < 8; j++) {
            printf("%d", results[i][j]);
            if (j < 7) printf(", ");
        }
        printf("]\n");
    }

#endif 
    return(0);
}