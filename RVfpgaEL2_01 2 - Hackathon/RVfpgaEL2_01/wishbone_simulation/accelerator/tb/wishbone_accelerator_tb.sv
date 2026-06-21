/*
* Wishbone BFM testbench

*/

module wishbone_accelerator_tb;
`include "wishbone_accelerator_tb_include.svh"


   always #5 wb_clk <= ~wb_clk;
   initial  #100 wb_rst <= 0;


accelerator_top accelerator_top	(

		.wb_clk_i	(wb_clk			),

		.wb_rst_i	(wb_rst			),
		.wb_adr_i	(wb_m2s_addr	),
		.wb_dat_i	(wb_m2s_data	), 	
		.wb_dat_o	(wb_s2m_data	),
		.wb_we_i	(wb_m2s_we		),
		.wb_stb_i	(wb_m2s_stb		),
		.wb_cyc_i	(wb_m2s_cyc		),
		.wb_sel_i	(wb_m2s_sel		),
		.wb_ack_o	(wb_s2m_ack		),
		.int_o		(wb_s2m_inta	)

	);
 int A;
 int B; 
    initial begin
        $display("Test start *****************");
        A=1;
        B=2;
        for (int i=0;i < 10;i++) begin
          wb_write(`ACCELERATOR_REG_A , A);
          wb_write(`ACCELERATOR_REG_B,B); 
          wb_read(`ACCELERATOR_REG_RESULT);
          wb_read(`ACCELERATOR_REG_STATUS);
          wb_read(  32'h8);

		  A= A+2;
		  B= B+3;
		end 
		

        $display("Test complete **************");
    end
 
endmodule
