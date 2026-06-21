//Provided AS IS without any warranty of any kind nor EXPLICIT nor IMPLIED

module accelerator (
    // Control signals
    input  logic         clk,
    input  logic         wb_rst_i,
    
    input  logic         go,
    input  logic [31:0]  reg_query,
    input  logic [31:0]  reg_ref,
    output logic [31:0]  reg_result,
    output logic         done
);

    logic rst_n;
    assign rst_n = ~wb_rst_i;

    // Instantiate a single Smith-Waterman core
    smith_waterman_core core_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        .go         (go),
        .query_seq  (reg_query),
        .ref_seq    (reg_ref),
        .score      (reg_result),
        .done       (done)
    );

endmodule
