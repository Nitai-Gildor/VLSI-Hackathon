////  accelerator_top.sv                                          ////
////  based on uart_top.v                                         ////
////  Alex Grinshpun 2023                                         ////
////  Provided AS IS without any warranty of any kind nor EXPLICIT nor IMPLIED                                                          ////

module accelerator_top	(

	input					wb_clk_i,
	
	// WISHBONE interface
	input	logic			wb_rst_i,

	input	logic			wb_stb_i,
	input	logic	[2:0]	wb_cti_i,
    input	logic	[1:0]	wb_bte_i,
	input	logic			wb_cyc_i,
	input	logic	[3:0]	wb_sel_i,
	input	logic			wb_we_i,
	input	logic	[7:0]	wb_adr_i,
	input	logic	[31:0]	wb_dat_i,
	output	logic	[31:0]	wb_dat_o,


	output	logic			wb_ack_o,
	output	logic			wb_err_o,
	output	logic			wb_rty_o,
	output	logic			int_o

	);
parameter SIM = 0;
parameter debug = 0;

logic	[31:0]			wb_data_reg_out; // 8-bit internal data input
logic	[31:0]			wb_dat8_o; // 8-bit internal data output
logic	[31:0]			wb_data_reg_in; // debug interface 32-bit output
logic	[7:0]			wb_adr_int;
logic 					we_o;	// Write enable for registers
logic					re_o;	// Read enable for registers


logic	[31:0]			reg_a;
logic	[31:0]			reg_b;
logic	[31:0]			reg_c;
logic	[31:0]			reg_d;
logic                   go;
logic                   done;
logic	[31:0]			reg_result;

`ifndef XSIM

ila_accelerator ila_accelerator (
	.clk(wb_clk_i), 
    .probe0(go),         
    .probe1(done),       
    .probe2(reg_a),      
    .probe3(reg_b),      
    .probe4(reg_c),      
    .probe5(reg_d),      
    .probe6(reg_result)
);

`endif
//
// MODULE INSTANCES
//
	
////  WISHBONE interface module
accelerator_wb	wb_interface
	(
		.clk			(wb_clk_i		),
		.wb_rst_i		(wb_rst_i		),
			
		.wb_we_i		(wb_we_i		),
		.wb_stb_i		(wb_stb_i		),
		.wb_cti_i		(wb_cti_i		),
		.wb_bte_i		(wb_bte_i		),
		.wb_cyc_i		(wb_cyc_i		),
		.wb_ack_o		(wb_ack_o		),
		.wb_sel_i		(4'b0			),
		.wb_adr_i		(wb_adr_i),	
		.wb_dat_i		(wb_dat_i		),		
		.wb_dat_o		(wb_dat_o		),
		.wb_err_o		(wb_err_o		),
		.wb_rty_o		(wb_rty_o		),

		.wb_adr_reg		(wb_adr_int		),	
		.wb_data_reg_in	(wb_data_reg_in	),
		.wb_data_reg_out(wb_data_reg_out),
		.we_o			(we_o			),
		.re_o			(re_o			)
	);

// Registers
accelerator_regs regs
	(
		.clk		(wb_clk_i			),
		.wb_rst_i	(wb_rst_i			),
		
		.wb_addr_i	(wb_adr_int			),
		.wb_dat_i	(wb_data_reg_out	),
		.wb_dat_o	(wb_data_reg_in		),
		.wb_we_i	(we_o				),
		.wb_re_i	(re_o				),
		
		.go	        (go			        ),
		.done	    (done			    ),
		.reg_a		(reg_a				),
		.reg_b		(reg_b				),
		.reg_c		(reg_c				),
		.reg_d		(reg_d				),
		.reg_result	(reg_result			)
		
		);

// Accelerator
accelerator  accelerator
	(
		.clk			(wb_clk_i	), 
		.wb_rst_i		(wb_rst_i	), 

		.go	        (go			        ),
		.done	    (done			    ),
		.reg_a		(reg_a				),
		.reg_b		(reg_b				),
		.reg_c		(reg_c				),
		.reg_d		(reg_d				),
		.reg_result	(reg_result			)
		);


endmodule


