// Alex Grinshpun Dec 2023
// Register addresses
// Provided AS IS without any warranty of any kind nor EXPLICIT nor IMPLIED

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
    input  logic [31:0]  reg_result [8],
    
    // Length registers
    output logic [4:0]   reg_query_len,
    output logic [4:0]   reg_ref_len [8]
);
    logic [31:0] reg_ctrl;
    assign go = reg_ctrl[0];

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
            
            // PACKED Result Registers (6 bits per score)
            8'h28: wb_dat_o = {
                2'b00, 
                reg_result[4][5:0], 
                reg_result[3][5:0], 
                reg_result[2][5:0], 
                reg_result[1][5:0], 
                reg_result[0][5:0]
            };
            8'h2C: wb_dat_o = {
                14'b0, 
                reg_result[7][5:0], 
                reg_result[6][5:0], 
                reg_result[5][5:0]
            };
            
            default: wb_dat_o = 32'b0;
        endcase
    end

    always_ff @(posedge clk or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            reg_ctrl  <= '0;
            reg_query <= '0;
            reg_query_len <= '0;
            for (int i = 0; i < 8; i++) begin
                reg_ref[i] <= '0;
                reg_ref_len[i] <= '0;
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
                
                // Decode the packed lengths
                8'h48: begin
                    reg_query_len <= wb_dat_i[4:0];
                    reg_ref_len[0] <= wb_dat_i[9:5];
                    reg_ref_len[1] <= wb_dat_i[14:10];
                    reg_ref_len[2] <= wb_dat_i[19:15];
                    reg_ref_len[3] <= wb_dat_i[24:20];
                    reg_ref_len[4] <= wb_dat_i[29:25];
                end
                8'h4C: begin
                    reg_ref_len[5] <= wb_dat_i[4:0];
                    reg_ref_len[6] <= wb_dat_i[9:5];
                    reg_ref_len[7] <= wb_dat_i[14:10];
                end
            endcase
        end
     end
endmodule
