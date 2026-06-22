////  accelerator_top.sv                                          ////
////  based on uart_top.v                                         ////
////  Alex Grinshpun 2023                                         ////
////  Provided AS IS without any warranty of any kind nor EXPLICIT nor IMPLIED                                                          ////

module accelerator_top (
    input               wb_clk_i,
    
    input  logic        wb_rst_i,
    input  logic        wb_stb_i,
    input  logic [2:0]  wb_cti_i,
    input  logic [1:0]  wb_bte_i,
    input  logic        wb_cyc_i,
    input  logic [3:0]  wb_sel_i,
    input  logic        wb_we_i,
    input  logic [7:0]  wb_adr_i,
    input  logic [31:0] wb_dat_i,
    output logic [31:0] wb_dat_o,
    output logic        wb_ack_o,
    output logic        wb_err_o,
    output logic        wb_rty_o,
    output logic        int_o
);
    parameter SIM = 0;
    parameter debug = 0;

    logic [31:0] wb_data_reg_out; 
    logic [31:0] wb_data_reg_in;  
    logic [7:0]  wb_adr_int;
    logic        we_o;            
    logic        re_o;
    
    logic [31:0] reg_query;
    logic [31:0] reg_ref [8];        
    logic [31:0] reg_result [8];
    logic        go;
    logic        done;
    
    // Wires for passing lengths
    logic [4:0]  reg_query_len;
    logic [4:0]  reg_ref_len [8];

    accelerator_wb wb_interface (
        .clk             (wb_clk_i),
        .wb_rst_i        (wb_rst_i),
        .wb_we_i         (wb_we_i),
        .wb_stb_i        (wb_stb_i),
        .wb_cti_i        (wb_cti_i),
        .wb_bte_i        (wb_bte_i),
        .wb_cyc_i        (wb_cyc_i),
        .wb_ack_o        (wb_ack_o),
        .wb_sel_i        (4'b0),
        .wb_adr_i        (wb_adr_i),    
        .wb_dat_i        (wb_dat_i),   
        .wb_dat_o        (wb_dat_o),
        .wb_err_o        (wb_err_o),
        .wb_rty_o        (wb_rty_o),
        .wb_adr_reg      (wb_adr_int),    
        .wb_data_reg_in  (wb_data_reg_in),
        .wb_data_reg_out (wb_data_reg_out),
        .we_o            (we_o),
        .re_o            (re_o)
    );
    
    accelerator_regs regs (
        .clk           (wb_clk_i),
        .wb_rst_i      (wb_rst_i),
        .wb_addr_i     (wb_adr_int),
        .wb_dat_i      (wb_data_reg_out),
        .wb_dat_o      (wb_data_reg_in),
        .wb_we_i       (we_o),
        .wb_re_i       (re_o),
        .go            (go),
        .done          (done),
        .reg_query     (reg_query),
        .reg_ref       (reg_ref),
        .reg_result    (reg_result),
        .reg_query_len (reg_query_len),
        .reg_ref_len   (reg_ref_len)
    );
    
    accelerator accelerator (
        .clk           (wb_clk_i), 
        .wb_rst_i      (wb_rst_i), 
        .go            (go),
        .done          (done),
        .reg_query     (reg_query),
        .reg_ref       (reg_ref),
        .reg_result    (reg_result),
        .reg_query_len (reg_query_len),
        .reg_ref_len   (reg_ref_len)
    );
endmodule


