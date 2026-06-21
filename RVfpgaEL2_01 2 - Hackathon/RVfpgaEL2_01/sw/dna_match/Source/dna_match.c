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

// Expanded Memory Map for 8-core design
#define ACCELERATOR_REG_CTRL      0x80001300  
#define ACCELERATOR_REG_QUERY     0x80001304  

#define ACCELERATOR_REG_REF_BASE  0x80001308  
#define ACCELERATOR_REG_RES_BASE  0x80001328  

// Macro fix included to ensure pointer math resolves correctly
#define READ_GPIO(dir) (*(volatile unsigned *)(dir))
#define WRITE_GPIO(dir, value) { (*(volatile unsigned *)(dir)) = (value); }

#define NUM_OF_REFS 8

// OPTIMIZATION 1: Global Lookup Table 
// Instantly returns the 2-bit value for any ASCII character
static const uint32_t dna_lut[256] = {
    ['A'] = 0, ['C'] = 1, ['G'] = 2, ['T'] = 3
};

// OPTIMIZATION 2: Fully Unrolled Packing
// Forces the RISC-V compiler to execute a straight line of loads and shifts.
// Zero branch penalties. Zero loop counters.
static inline uint32_t pack_sequence(const char *seq) {
    return (dna_lut[(uint8_t)seq[0]]) |
           (dna_lut[(uint8_t)seq[1]] << 2) |
           (dna_lut[(uint8_t)seq[2]] << 4) |
           (dna_lut[(uint8_t)seq[3]] << 6) |
           (dna_lut[(uint8_t)seq[4]] << 8) |
           (dna_lut[(uint8_t)seq[5]] << 10) |
           (dna_lut[(uint8_t)seq[6]] << 12) |
           (dna_lut[(uint8_t)seq[7]] << 14) |
           (dna_lut[(uint8_t)seq[8]] << 16) |
           (dna_lut[(uint8_t)seq[9]] << 18) |
           (dna_lut[(uint8_t)seq[10]] << 20) |
           (dna_lut[(uint8_t)seq[11]] << 22) |
           (dna_lut[(uint8_t)seq[12]] << 24) |
           (dna_lut[(uint8_t)seq[13]] << 26) |
           (dna_lut[(uint8_t)seq[14]] << 28) |
           (dna_lut[(uint8_t)seq[15]] << 30);
}

int main(void)
{
    const char *query = "ACGTCGTACGTACGTA";
    int score[NUM_OF_REFS]; 

    const char *references[] =
    {
        "ACGTACGTACGTACGT",
        "ACGTTCGTACGTACGT",
        "ACGTACGGACGTACGT",
        "TTTTTTTTTTTTTTTT",
        "ACGTACGTTCGTACGT",
        "ACGTACGTACGTACGA",
        "ACGTTTGTACGTACGT",
        "ACGTACGTGCGTACGT"
    };

    int cyc_beg, cyc_end;

    pspMachinePerfMonitorEnableAll();
    pspMachinePerfCounterSet(D_PSP_COUNTER0, D_CYCLES_CLOCKS_ACTIVE);
    
    // Start timer! (Hackathon rules usually dictate the entire workload is timed)
    cyc_beg = pspMachinePerfCounterGet(D_PSP_COUNTER0);

    // Write the query
    WRITE_GPIO(ACCELERATOR_REG_QUERY, pack_sequence(query));

    // OPTIMIZATION 3: Fully unrolled loop for writing references
    WRITE_GPIO(ACCELERATOR_REG_REF_BASE + 0x00, pack_sequence(references[0]));
    WRITE_GPIO(ACCELERATOR_REG_REF_BASE + 0x04, pack_sequence(references[1]));
    WRITE_GPIO(ACCELERATOR_REG_REF_BASE + 0x08, pack_sequence(references[2]));
    WRITE_GPIO(ACCELERATOR_REG_REF_BASE + 0x0C, pack_sequence(references[3]));
    WRITE_GPIO(ACCELERATOR_REG_REF_BASE + 0x10, pack_sequence(references[4]));
    WRITE_GPIO(ACCELERATOR_REG_REF_BASE + 0x14, pack_sequence(references[5]));
    WRITE_GPIO(ACCELERATOR_REG_REF_BASE + 0x18, pack_sequence(references[6]));
    WRITE_GPIO(ACCELERATOR_REG_REF_BASE + 0x1C, pack_sequence(references[7]));

    // Fire all 8 cores simultaneously
    WRITE_GPIO(ACCELERATOR_REG_CTRL, 1);

    // Wait for them ALL to finish
    while ((READ_GPIO(ACCELERATOR_REG_CTRL) & 0x80000000) == 0);

    // Fully unrolled loop for reading results
    score[0] = READ_GPIO(ACCELERATOR_REG_RES_BASE + 0x00);
    score[1] = READ_GPIO(ACCELERATOR_REG_RES_BASE + 0x04);
    score[2] = READ_GPIO(ACCELERATOR_REG_RES_BASE + 0x08);
    score[3] = READ_GPIO(ACCELERATOR_REG_RES_BASE + 0x0C);
    score[4] = READ_GPIO(ACCELERATOR_REG_RES_BASE + 0x10);
    score[5] = READ_GPIO(ACCELERATOR_REG_RES_BASE + 0x14);
    score[6] = READ_GPIO(ACCELERATOR_REG_RES_BASE + 0x18);
    score[7] = READ_GPIO(ACCELERATOR_REG_RES_BASE + 0x1C);

    // Reset state machine
    WRITE_GPIO(ACCELERATOR_REG_CTRL, 0);

    cyc_end = pspMachinePerfCounterGet(D_PSP_COUNTER0);

    // Stop timer before printing
    printf("Cycles = %d\n", cyc_end-cyc_beg);

    for(int i=0; i<NUM_OF_REFS; i++)
    {
        printf("Reference %d score = %d\n", i, score[i]);
    }

    return 0;
}