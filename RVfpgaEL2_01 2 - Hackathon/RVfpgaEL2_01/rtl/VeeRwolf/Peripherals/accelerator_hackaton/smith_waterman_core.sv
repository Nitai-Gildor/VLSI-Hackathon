module smith_waterman_core (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         go,
    input  logic [31:0]  query_seq,
    input  logic [31:0]  ref_seq,
    
    // NEW: Dynamic boundaries
    input  logic [4:0]   query_len,
    input  logic [4:0]   ref_len,
    
    output logic [31:0]  score,
    output logic         done
);
    // Unpack 32-bit registers into 16x 2-bit characters
    logic [1:0] q_arr [1:16];
    logic [1:0] r_arr [1:16];
    
    always_comb begin
        for (int i = 0; i < 16; i++) begin
            q_arr[i+1] = query_seq[i*2 +: 2];
            r_arr[i+1] = ref_seq[i*2 +: 2];
        end
    end

    localparam signed [31:0] MATCH    = 2;
    localparam signed [31:0] MISMATCH = -1;
    localparam signed [31:0] GAP_OPEN = -4;
    localparam signed [31:0] GAP_EXT  = -1;
    localparam signed [31:0] NEG_INF  = -1000000;

    typedef enum logic [1:0] {IDLE, CALC, COMPLETE} state_t;
    state_t state;
    
    logic signed [31:0] M_prev [1:16];
    logic signed [31:0] I_prev [1:16];

    logic [4:0] row, col;
    logic signed [31:0] best_score;
    logic signed [31:0] m_left, d_left, m_diag;

    logic signed [31:0] s;
    logic signed [31:0] m_up, i_up;
    logic signed [31:0] i_curr_c1, i_curr_c2, i_curr;
    logic signed [31:0] d_curr_c1, d_curr_c2, d_curr;
    logic signed [31:0] m_curr_c1, max_temp1, max_temp2, m_curr;
    
    always_comb begin
        m_up = (row == 1) ? 0 : M_prev[col];
        i_up = (row == 1) ? NEG_INF : I_prev[col];
        s = (q_arr[row] == r_arr[col]) ? MATCH : MISMATCH;

        i_curr_c1 = m_up + GAP_OPEN;
        i_curr_c2 = i_up + GAP_EXT;
        i_curr = (i_curr_c1 > i_curr_c2) ? i_curr_c1 : i_curr_c2;

        d_curr_c1 = m_left + GAP_OPEN;
        d_curr_c2 = d_left + GAP_EXT;
        d_curr = (d_curr_c1 > d_curr_c2) ? d_curr_c1 : d_curr_c2;

        m_curr_c1 = m_diag + s;
        max_temp1 = (m_curr_c1 > i_curr) ? m_curr_c1 : i_curr;
        max_temp2 = (d_curr > 0) ? d_curr : 0;
        m_curr    = (max_temp1 > max_temp2) ? max_temp1 : max_temp2;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            score <= '0;
            done <= 1'b0;
            row <= 1;
            col <= 1;
            best_score <= 0;
            m_left <= 0;
            d_left <= NEG_INF;
            m_diag <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (go) begin
                        state <= CALC;
                        row <= 1;
                        col <= 1;
                        best_score <= 0;
                        m_left <= 0;
                        d_left <= NEG_INF;
                        m_diag <= 0;
                    end
                end

                CALC: begin
                    M_prev[col] <= m_curr;
                    I_prev[col] <= i_curr;
                    
                    m_diag <= m_up; 
                    m_left <= m_curr;
                    d_left <= d_curr;
                    
                    if (m_curr > best_score) begin
                        best_score <= m_curr;
                    end

                    // Evaluate against the dynamic lengths instead of hardcoded 16
                    if (col == ref_len) begin
                        if (row == query_len) begin
                            state <= COMPLETE;
                        end else begin
                            col    <= 1;
                            row    <= row + 1;
                            m_left <= 0;
                            d_left <= NEG_INF;
                            m_diag <= 0;
                        end
                    end else begin
                        col <= col + 1;
                    end
                end

                COMPLETE: begin
                    score <= best_score;
                    done <= 1'b1;
                    if (!go) begin
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule