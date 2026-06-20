// Alex Grinshpun Dec 2023
//Provided AS IS without any warranty of any kind nor EXPLICIT nor IMPLIED

module accelerator
(
    // Control signals
	input	logic				clk,
	input	logic				wb_rst_i,


	input	logic	signed	[31:0]		reg_a,
	input	logic	signed	[31:0]		reg_b,
	output	logic						overflow,
	output	logic	signed	[31:0]		reg_result,
	output	logic			[31:0]		reg_status
);

//-------------------------------------------------------------------------------
// Local signal declaration
//-------------------------------------------------------------------------------

//-------------------------------------------------------------------------------
// Core interface
//-------------------------------------------------------------------------------
 

logic signed [63:0] result_64_bit;
assign rst_n = ~wb_rst_i;
 
//////////////CALCULATE RESULT////////////////////////////	 
	assign result_64_bit = reg_a + reg_b;
//////////////////////////////////////////
							 
	always_ff @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			reg_result	<=	32'h0;
			overflow	<=	1'b0;
		end
		else	begin
			reg_result <= result_64_bit[31:0];
			if (|result_64_bit[63:32])  
				overflow <=	1'b1;
			else
				overflow <=	1'b0;
		end
	end
		

endmodule
