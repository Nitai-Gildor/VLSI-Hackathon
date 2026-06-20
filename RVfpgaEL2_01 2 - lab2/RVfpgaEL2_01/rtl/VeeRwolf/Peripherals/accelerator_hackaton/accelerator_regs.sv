// Alex Grinshpun Dec 2023
// Register addresses
// Provided AS IS without any warranty of any kind nor EXPLICIT nor IMPLIED

`define ACCELERATOR_REG_CTRL		8'h0	// 
`define ACCELERATOR_REG_A			8'h4	// 
`define ACCELERATOR_REG_B			8'h8	//
`define ACCELERATOR_REG_C			8'hC	//
`define ACCELERATOR_REG_D			8'h10	//
`define ACCELERATOR_REG_RESULT		8'h14	// 


module accelerator_regs
#(parameter SIM = 0)
 (
    //Arrive from accelerator_wb (wishbone bus)
	input	logic					clk,
	input	logic					wb_rst_i,
	input	logic	[7:0]			wb_addr_i,
	input	logic	[31:0]			wb_dat_i,
	output	logic	[31:0]			wb_dat_o,
	input	logic					wb_we_i,
	input	logic					wb_re_i,
	
	//Down to accelerator
	output   logic                   go,
	input   logic                   done,
	output	logic	[31:0]			reg_a,
	output	logic	[31:0]			reg_b,
	output	logic	[31:0]			reg_c,
	output	logic	[31:0]			reg_d,
	input	logic	[31:0]			reg_result
);

    logic [31:0] reg_ctrl;
    assign go = reg_ctrl[0];

// Read logic
    always_comb begin
        case (wb_addr_i)
            `ACCELERATOR_REG_CTRL:   wb_dat_o = {done, 30'b0, reg_ctrl[0]}; // Done is the MSB
            `ACCELERATOR_REG_A:      wb_dat_o = reg_a;
            `ACCELERATOR_REG_B:      wb_dat_o = reg_b;
            `ACCELERATOR_REG_C:      wb_dat_o = reg_c;
            `ACCELERATOR_REG_D:      wb_dat_o = reg_d;
            `ACCELERATOR_REG_RESULT: wb_dat_o = reg_result;
            default:                 wb_dat_o = 32'b0;
        endcase
    end

// Write logic
    always_ff @(posedge clk or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            reg_ctrl <= '0;
            reg_a    <= '0;
            reg_b    <= '0;
            reg_c    <= '0;
            reg_d    <= '0;
        end else if (wb_we_i) begin
            case (wb_addr_i)
                `ACCELERATOR_REG_CTRL: reg_ctrl <= wb_dat_i; 
                `ACCELERATOR_REG_A:    reg_a    <= wb_dat_i;
                `ACCELERATOR_REG_B:    reg_b    <= wb_dat_i;
                `ACCELERATOR_REG_C:    reg_c    <= wb_dat_i;
                `ACCELERATOR_REG_D:    reg_d    <= wb_dat_i;
            endcase
        end
     end

endmodule
