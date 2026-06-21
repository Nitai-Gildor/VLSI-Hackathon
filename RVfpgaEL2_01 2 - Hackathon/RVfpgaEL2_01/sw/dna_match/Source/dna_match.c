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
#include <stdint.h>

// Updated Memory Map for the 2-bit packed accelerator
#define ACCELERATOR_REG_CTRL    0x80001300  // Bit 0: GO, Bit 31: DONE
#define ACCELERATOR_REG_QUERY   0x80001304  // 32-bit packed query sequence
#define ACCELERATOR_REG_REF     0x80001308  // 32-bit packed reference sequence
#define ACCELERATOR_REG_RESULT  0x8000130C  // 32-bit Result Score

#define READ_GPIO(dir) (*(volatile unsigned *)dir)
#define WRITE_GPIO(dir, value) { (*(volatile unsigned *)dir) = (value); }

#define NUM_OF_REFS 8

// Helper function to pack a 16-character DNA string into a 32-bit integer
// A = 00, C = 01, G = 10, T = 11
uint32_t pack_sequence(const char *seq) {
    uint32_t packed = 0;
    for (int i = 0; i < 16; i++) {
        uint32_t val = 0;
        if (seq[i] == 'C') val = 1;
        else if (seq[i] == 'G') val = 2;
        else if (seq[i] == 'T') val = 3;
        // 'A' defaults to 0
        
        // Shift the 2-bit value to its correct position (i * 2)
        packed |= (val << (i * 2));
    }
    return packed;
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

    // Pre-pack the query (Optimization: we only need to do this once)
    uint32_t packed_query = pack_sequence(query);

    // read time here
    int cyc_beg, cyc_end;

    pspMachinePerfMonitorEnableAll();
    pspMachinePerfCounterSet(D_PSP_COUNTER0, D_CYCLES_CLOCKS_ACTIVE);
    cyc_beg = pspMachinePerfCounterGet(D_PSP_COUNTER0);

    // Write the query to the accelerator just once
    WRITE_GPIO(ACCELERATOR_REG_QUERY, packed_query);

    for(int i=0; i<NUM_OF_REFS; i++)
    {
        // 1. Pack the current reference sequence
        uint32_t packed_ref = pack_sequence(references[i]);
        
        // 2. Load the reference into the accelerator
        WRITE_GPIO(ACCELERATOR_REG_REF, packed_ref);
        
        // 3. Set GO bit
        WRITE_GPIO(ACCELERATOR_REG_CTRL, 1);
        
        // 4. Poll for DONE bit (MSB)
        while ((READ_GPIO(ACCELERATOR_REG_CTRL) & 0x80000000) == 0);
        
        // 5. Read the resulting score
        score[i] = READ_GPIO(ACCELERATOR_REG_RESULT);
        
        // 6. Clear GO bit to reset state machine
        WRITE_GPIO(ACCELERATOR_REG_CTRL, 0);
    }

    // read timer here and print execution time
    cyc_end = pspMachinePerfCounterGet(D_PSP_COUNTER0);

    printf("Cycles = %d\n", cyc_end-cyc_beg);

    for(int i=0; i<NUM_OF_REFS; i++)
    {
        printf(
            "Reference %d score = %d\n",
            i,
            score[i]);
    }

    return 0;
}