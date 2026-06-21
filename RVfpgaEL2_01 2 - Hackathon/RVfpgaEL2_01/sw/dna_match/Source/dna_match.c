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

#define MATCH       2
#define MISMATCH   -1

#define GAP_OPEN   -4
#define GAP_EXT    -1

#define MAX_LEN   32

#define NEG_INF  (-1000000)



#define NUM_OF_REFS 8

static int M[MAX_LEN][MAX_LEN];
static int I[MAX_LEN][MAX_LEN];
static int D[MAX_LEN][MAX_LEN];

static inline int max2(int a, int b)
{
    return (a > b) ? a : b;
}

static inline int max3(int a, int b, int c)
{
    int m = a;

    if(b > m) m = b;
    if(c > m) m = c;

    return m;
}

static inline int max4(int b,int c,int d)
{
    int m = 0;

    if(b > m) m = b;
    if(c > m) m = c;
    if(d > m) m = d;

    return m;
}

int smith_waterman_affine(
        const char *ref,
        const char *query)
{
    int rows = strlen(query) + 1;
    int cols = strlen(ref) + 1;

    int best_score = 0;

    // We only need 1D arrays for the row above us
int M_prev[MAX_LEN] = {0};
int I_prev[MAX_LEN] = {NEG_INF};

// Initialize I_prev to NEG_INF here...

for(int i = 1; i < rows; i++) {
    int m_left = 0;       // Corresponds to M[i][j-1]
    int d_left = NEG_INF; // Corresponds to D[i][j-1]
    int m_diag = 0;       // Corresponds to M[i-1][j-1]
    
    for(int j = 1; j < cols; j++) {
        int s = (query[i-1] == ref[j-1]) ? MATCH : MISMATCH;

        // 1. Read the "up" values from our 1D row buffer ONLY ONCE
        int m_up = M_prev[j];
        int i_up = I_prev[j];

        // 2. Calculate current cell using our FAST local registers
        int i_curr = max2(m_up + GAP_OPEN, i_up + GAP_EXT);
        int d_curr = max2(m_left + GAP_OPEN, d_left + GAP_EXT);
        int m_curr = max4( m_diag + s, i_curr, d_curr);

        if(m_curr > best_score) best_score = m_curr;

        // 3. Prepare for the NEXT column (j+1)
        // The current cell becomes the "left" cell for the next iteration
        m_left = m_curr;
        d_left = d_curr;

        // 4. Update the 1D arrays for the NEXT row (i+1)
        // Before we overwrite M_prev[j], we must save it to become the 
        // diagonal for the next column!
        m_diag = M_prev[j]; 
        M_prev[j] = m_curr;
        I_prev[j] = i_curr;
    }
}

    return best_score;
}

int main(void)
{
    const char *query =
        "ACGTCGTACGTACGTA";

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


    // read time here
   int cyc_beg, cyc_end;

   pspMachinePerfMonitorEnableAll();
   pspMachinePerfCounterSet(D_PSP_COUNTER0, D_CYCLES_CLOCKS_ACTIVE);
   cyc_beg = pspMachinePerfCounterGet(D_PSP_COUNTER0);


    for(int i=0;i<NUM_OF_REFS;i++)
    {
        score[i] =
            smith_waterman_affine(
                references[i],
                query);

    }

   
    // read timer here and print execution time
   cyc_end = pspMachinePerfCounterGet(D_PSP_COUNTER0);

   printf("Cycles = %d\n", cyc_end-cyc_beg);

    for(int i=0;i<NUM_OF_REFS;i++)
    {
        printf(
            "Reference %d score = %d\n",
            i,
            score[i]);
    }

    return 0;
}
