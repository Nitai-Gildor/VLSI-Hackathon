/*
* Wishbone BFM testbench

*/

module wishbone_accelerator_tb;
`include "wishbone_accelerator_tb_include.svh"

    // Redefining the addresses here ensures the simulation compiles 
    // perfectly even if the include file hasn't been updated.
    `define ACCELERATOR_REG_CTRL   32'h00 
    `define ACCELERATOR_REG_A      32'h04 
    `define ACCELERATOR_REG_B      32'h08 
    `define ACCELERATOR_REG_C      32'h0c 
    `define ACCELERATOR_REG_D      32'h10 
    `define ACCELERATOR_REG_RESULT 32'h14

    always #5 wb_clk <= ~wb_clk;
    initial  #100 wb_rst <= 0;

    accelerator_top accelerator_top (
        .wb_clk_i   (wb_clk         ),
        .wb_rst_i   (wb_rst         ),
        .wb_adr_i   (wb_m2s_addr    ),
        .wb_dat_i   (wb_m2s_data    ),  
        .wb_dat_o   (wb_s2m_data    ),
        .wb_we_i    (wb_m2s_we      ),
        .wb_stb_i   (wb_m2s_stb     ),
        .wb_cyc_i   (wb_m2s_cyc     ),
        .wb_sel_i   (wb_m2s_sel     ),
        .wb_ack_o   (wb_s2m_ack     ),
        .int_o      (wb_s2m_inta    )
    );

    initial begin
        $display("Test start *******");
        
        // Wait for the initial reset pulse to finish before sending data
        #150;

        // LOAD DATA: 
        // We pack 4 bytes (8-bit numbers) into each 32-bit register.
        // Let's test: (1*1) + (2*1) + (3*1) + (4*1) + (5*1) + (6*1) + (7*1) + (8*1) = 36
        wb_write(`ACCELERATOR_REG_A, 32'h01_02_03_04); 
        wb_write(`ACCELERATOR_REG_B, 32'h01_01_01_01);
        wb_write(`ACCELERATOR_REG_C, 32'h05_06_07_08);
        wb_write(`ACCELERATOR_REG_D, 32'h01_01_01_01);

        // TRIGGER HARDWARE:
        // Set the GO bit (Bit 0) to 1 to start the state machine
        wb_write(`ACCELERATOR_REG_CTRL, 32'h00000001);

        // WAIT:
        // Give the hardware a few clock cycles to transition states and compute
        #50;

        // CLEAR TRIGGER:
        // Set the GO bit back to 0, just like the C code does
        wb_write(`ACCELERATOR_REG_CTRL, 32'h00000000);

        // READ RESULT:
        // We expect to see 36 (which is 0x24 in hexadecimal) in the waveform!
        wb_read(`ACCELERATOR_REG_RESULT);

        $display("Test complete ******");
    end
 
endmodule
