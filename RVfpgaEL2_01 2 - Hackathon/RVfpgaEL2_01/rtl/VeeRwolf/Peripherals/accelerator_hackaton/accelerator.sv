//Provided AS IS without any warranty of any kind nor EXPLICIT nor IMPLIED

module accelerator (
    input  logic         clk,
    input  logic         wb_rst_i,
    
    input  logic         go,
    input  logic [31:0]  reg_query,
    input  logic [31:0]  reg_ref [8],
    output logic [31:0]  reg_result [8],
    output logic         done
);

    logic rst_n;
    assign rst_n = ~wb_rst_i;

    logic [7:0] core_done;
    
    // The main done bit is high only when all 8 cores finish
    assign done = &core_done; 

    // Generate 8 concurrent Smith-Waterman engines
    genvar i;
    generate
        for (i = 0; i < 8; i++) begin : sw_cores
            smith_waterman_core core_inst (
                .clk        (clk),
                .rst_n      (rst_n),
                .go         (go),
                .query_seq  (reg_query),
                .ref_seq    (reg_ref[i]),
                .score      (reg_result[i]),
                .done       (core_done[i])
            );
        end
    endgenerate

endmodule
