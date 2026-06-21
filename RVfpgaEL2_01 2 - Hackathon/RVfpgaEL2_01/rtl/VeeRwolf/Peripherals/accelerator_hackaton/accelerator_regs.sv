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
    // Arrive from accelerator_wb (wishbone bus)
    input  logic         clk,
    input  logic         wb_rst_i,
    input  logic [7:0]   wb_addr_i,
    input  logic [31:0]  wb_dat_i,
    output logic [31:0]  wb_dat_o,
    input  logic         wb_we_i,
    input  logic         wb_re_i,
    
    // Down to accelerator
    output logic         go,
    input  logic         done,
    output logic [31:0]  reg_query,
    output logic [31:0]  reg_ref,
    input  logic [31:0]  reg_result
);

    logic [31:0] reg_ctrl;
    assign go = reg_ctrl[0];

    // Read logic
    always_comb begin
        case (wb_addr_i)
            `ACCELERATOR_REG_CTRL:   wb_dat_o = {done, 30'b0, reg_ctrl[0]}; // Done is MSB
            `ACCELERATOR_REG_QUERY:  wb_dat_o = reg_query;
            `ACCELERATOR_REG_REF:    wb_dat_o = reg_ref;
            `ACCELERATOR_REG_RESULT: wb_dat_o = reg_result;
            default:                 wb_dat_o = 32'b0;
        endcase
    end

    // Write logic
    always_ff @(posedge clk or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            reg_ctrl  <= '0;
            reg_query <= '0;
            reg_ref   <= '0;
        end else if (wb_we_i) begin
            case (wb_addr_i)
                `ACCELERATOR_REG_CTRL:  reg_ctrl  <= wb_dat_i;
                `ACCELERATOR_REG_QUERY: reg_query <= wb_dat_i;
                `ACCELERATOR_REG_REF:   reg_ref   <= wb_dat_i;
            endcase
        end
     end

endmodule
