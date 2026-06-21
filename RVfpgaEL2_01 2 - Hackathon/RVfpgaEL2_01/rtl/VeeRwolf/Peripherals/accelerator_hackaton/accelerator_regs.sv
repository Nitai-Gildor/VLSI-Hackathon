// Alex Grinshpun Dec 2023
// Register addresses
// Provided AS IS without any warranty of any kind nor EXPLICIT nor IMPLIED

// Register addresses
// 2-Bit Packed Architecture
`define ACCELERATOR_REG_CTRL    8'h00   // [0] go, [31] done
`define ACCELERATOR_REG_QUERY   8'h04   // 16 chars packed into 32 bits (2 bits/char)
`define ACCELERATOR_REG_REF     8'h08   // 16 chars packed into 32 bits (2 bits/char)
`define ACCELERATOR_REG_RESULT  8'h0C   // Output Best Score

module accelerator_regs #(parameter SIM = 0) (
    input  logic         clk,
    input  logic         wb_rst_i,
    input  logic [7:0]   wb_addr_i,
    input  logic [31:0]  wb_dat_i,
    output logic [31:0]  wb_dat_o,
    input  logic         wb_we_i,
    input  logic         wb_re_i,
    
    output logic         go,
    input  logic         done,
    output logic [31:0]  reg_query,
    output logic [31:0]  reg_ref [8],
    input  logic [31:0]  reg_result [8]
);

    logic [31:0] reg_ctrl;
    assign go = reg_ctrl[0];

    // Explicit Read logic - Unrolled for Synthesis
    always_comb begin
        case (wb_addr_i)
            8'h00: wb_dat_o = {done, 30'b0, reg_ctrl[0]};
            8'h04: wb_dat_o = reg_query;
            
            // Reference Registers
            8'h08: wb_dat_o = reg_ref[0];
            8'h0C: wb_dat_o = reg_ref[1];
            8'h10: wb_dat_o = reg_ref[2];
            8'h14: wb_dat_o = reg_ref[3];
            8'h18: wb_dat_o = reg_ref[4];
            8'h1C: wb_dat_o = reg_ref[5];
            8'h20: wb_dat_o = reg_ref[6];
            8'h24: wb_dat_o = reg_ref[7];
            
            // Result Registers
            8'h28: wb_dat_o = reg_result[0];
            8'h2C: wb_dat_o = reg_result[1];
            8'h30: wb_dat_o = reg_result[2];
            8'h34: wb_dat_o = reg_result[3];
            8'h38: wb_dat_o = reg_result[4];
            8'h3C: wb_dat_o = reg_result[5];
            8'h40: wb_dat_o = reg_result[6];
            8'h44: wb_dat_o = reg_result[7];
            
            default: wb_dat_o = 32'b0;
        endcase
    end

    // Explicit Write logic - Unrolled for Synthesis
    always_ff @(posedge clk or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            reg_ctrl  <= '0;
            reg_query <= '0;
            for (int i = 0; i < 8; i++) begin
                reg_ref[i] <= '0;
            end
        end else if (wb_we_i) begin
            case (wb_addr_i)
                8'h00: reg_ctrl <= wb_dat_i;
                8'h04: reg_query <= wb_dat_i;
                
                8'h08: reg_ref[0] <= wb_dat_i;
                8'h0C: reg_ref[1] <= wb_dat_i;
                8'h10: reg_ref[2] <= wb_dat_i;
                8'h14: reg_ref[3] <= wb_dat_i;
                8'h18: reg_ref[4] <= wb_dat_i;
                8'h1C: reg_ref[5] <= wb_dat_i;
                8'h20: reg_ref[6] <= wb_dat_i;
                8'h24: reg_ref[7] <= wb_dat_i;
            endcase
        end
     end

endmodule
