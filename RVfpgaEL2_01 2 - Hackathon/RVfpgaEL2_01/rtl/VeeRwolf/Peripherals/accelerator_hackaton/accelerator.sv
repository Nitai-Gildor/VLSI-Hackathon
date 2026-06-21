module accelerator (
    input  logic         clk,
    input  logic         wb_rst_i,
    
    input  logic         go,
    input  logic [31:0]  reg_query,
    input  logic [31:0]  reg_ref [8],
    output logic [31:0]  reg_result [8],
    
    // NEW: Ports for sequence lengths
    input  logic [4:0]   reg_query_len,
    input  logic [4:0]   reg_ref_len [8],
    
    output logic         done
);

    logic rst_n;
    assign rst_n = ~wb_rst_i;

    logic [7:0] core_done;
    assign done = &core_done;
    
    genvar i;
    generate
        for (i = 0; i < 8; i++) begin : sw_cores
            smith_waterman_core core_inst (
                .clk        (clk),
                .rst_n      (rst_n),
                .go         (go),
                .query_seq  (reg_query),
                .ref_seq    (reg_ref[i]),
                .query_len  (reg_query_len),
                .ref_len    (reg_ref_len[i]),
                .score      (reg_result[i]),
                .done       (core_done[i])
            );
        end
    endgenerate

endmodule