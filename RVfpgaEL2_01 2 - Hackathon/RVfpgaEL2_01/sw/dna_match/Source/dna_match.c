#if defined(D_NEXYS_A7)
   #include <bsp_printf.h>
   #include <bsp_mem_map.h>
   #include <bsp_version.h>
#else
   PRE_COMPILED_MSG("no platform was defined")
#endif
#include <psp_api.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define NUM_OF_REFS 8

#define ACCELERATOR_REG_CTRL      0x80001300  
#define ACCELERATOR_REG_QUERY     0x80001304  
#define ACCELERATOR_REG_REF_BASE  0x80001308  
#define ACCELERATOR_REG_RES_BASE  0x80001328
#define ACCELERATOR_REG_LEN_0     0x80001348
#define ACCELERATOR_REG_LEN_1     0x8000134C

#define READ_GPIO(dir) (*(volatile unsigned *)(dir))
#define WRITE_GPIO(dir, value) { (*(volatile unsigned *)(dir)) = (value); }

// Pure CPU register bitwise extraction
static inline uint32_t pack_sequence(const char *seq) {
    return (((seq[0]  >> 1) & 3))       | (((seq[1]  >> 1) & 3) << 2)  |
           (((seq[2]  >> 1) & 3) << 4)  | (((seq[3]  >> 1) & 3) << 6)  |
           (((seq[4]  >> 1) & 3) << 8)  | (((seq[5]  >> 1) & 3) << 10) |
           (((seq[6]  >> 1) & 3) << 12) | (((seq[7]  >> 1) & 3) << 14) |
           (((seq[8]  >> 1) & 3) << 16) | (((seq[9]  >> 1) & 3) << 18) |
           (((seq[10] >> 1) & 3) << 20) | (((seq[11] >> 1) & 3) << 22) |
           (((seq[12] >> 1) & 3) << 24) | (((seq[13] >> 1) & 3) << 26) |
           (((seq[14] >> 1) & 3) << 28) | (((seq[15] >> 1) & 3) << 30);
}

int main(void)
{
    const char *query = "ACGTCGTACGTACGTA";
    int score[NUM_OF_REFS]; 

    const char *references[] =
    {
        "ACGTACGTACGTACGT", "ACGTTCGTACGTACGT", "ACGTACGGACGTACGT", "TTTTTTTTTTTTTTTT",
        "ACGTACGTTCGTACGT", "ACGTACGTACGTACGA", "ACGTTTGTACGTACGT", "ACGTACGTGCGTACGT"
    };

    int cyc_beg, cyc_end;
    pspMachinePerfMonitorEnableAll();
    pspMachinePerfCounterSet(D_PSP_COUNTER0, D_CYCLES_CLOCKS_ACTIVE);
    
    // =========================================================
    // TIMED EXECUTION BLOCK START
    // =========================================================
    cyc_beg = pspMachinePerfCounterGet(D_PSP_COUNTER0);

    WRITE_GPIO(ACCELERATOR_REG_QUERY, pack_sequence(query));

    WRITE_GPIO(ACCELERATOR_REG_REF_BASE + 0x00, pack_sequence(references[0]));
    WRITE_GPIO(ACCELERATOR_REG_REF_BASE + 0x04, pack_sequence(references[1]));
    WRITE_GPIO(ACCELERATOR_REG_REF_BASE + 0x08, pack_sequence(references[2]));
    WRITE_GPIO(ACCELERATOR_REG_REF_BASE + 0x0C, pack_sequence(references[3]));
    WRITE_GPIO(ACCELERATOR_REG_REF_BASE + 0x10, pack_sequence(references[4]));
    WRITE_GPIO(ACCELERATOR_REG_REF_BASE + 0x14, pack_sequence(references[5]));
    WRITE_GPIO(ACCELERATOR_REG_REF_BASE + 0x18, pack_sequence(references[6]));
    WRITE_GPIO(ACCELERATOR_REG_REF_BASE + 0x1C, pack_sequence(references[7]));

    // Pack Sequence Lengths (max 16 requires 5 bits)
    uint32_t len_pack_0 = strlen(query) | 
                          (strlen(references[0]) << 5)  | 
                          (strlen(references[1]) << 10) | 
                          (strlen(references[2]) << 15) | 
                          (strlen(references[3]) << 20) | 
                          (strlen(references[4]) << 25);
                          
    uint32_t len_pack_1 = strlen(references[5]) | 
                          (strlen(references[6]) << 5)  | 
                          (strlen(references[7]) << 10);

    WRITE_GPIO(ACCELERATOR_REG_LEN_0, len_pack_0);
    WRITE_GPIO(ACCELERATOR_REG_LEN_1, len_pack_1);

    WRITE_GPIO(ACCELERATOR_REG_CTRL, 1);

    while ((READ_GPIO(ACCELERATOR_REG_CTRL) & 0x80000000) == 0);

    // Read only TWO registers from the Wishbone bus
    uint32_t packed_res_0 = READ_GPIO(ACCELERATOR_REG_RES_BASE + 0x00);
    uint32_t packed_res_1 = READ_GPIO(ACCELERATOR_REG_RES_BASE + 0x04);

    // Unpack the 6-bit values strictly using CPU registers
    score[0] = (packed_res_0      ) & 0x3F;
    score[1] = (packed_res_0 >>  6) & 0x3F;
    score[2] = (packed_res_0 >> 12) & 0x3F;
    score[3] = (packed_res_0 >> 18) & 0x3F;
    score[4] = (packed_res_0 >> 24) & 0x3F;

    score[5] = (packed_res_1      ) & 0x3F;
    score[6] = (packed_res_1 >>  6) & 0x3F;
    score[7] = (packed_res_1 >> 12) & 0x3F;

    WRITE_GPIO(ACCELERATOR_REG_CTRL, 0);

    cyc_end = pspMachinePerfCounterGet(D_PSP_COUNTER0);
    // =========================================================
    // TIMED EXECUTION BLOCK END
    // =========================================================

    printf("Cycles = %d\n", cyc_end-cyc_beg);

    for(int i=0; i<NUM_OF_REFS; i++) {
        printf("Reference %d score = %d\n", i, score[i]);
    }

    return 0;
}