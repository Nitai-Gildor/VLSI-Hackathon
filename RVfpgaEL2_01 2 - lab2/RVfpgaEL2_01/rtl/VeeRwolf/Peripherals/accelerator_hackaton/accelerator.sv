//Provided AS IS without any warranty of any kind nor EXPLICIT nor IMPLIED

module accelerator
(
    // Control signals
	input	logic				        clk,
	input	logic				        wb_rst_i,
	
	input   logic               go,
	input	logic	signed	[31:0]		reg_a,
	input	logic	signed	[31:0]		reg_b,
	input	logic	signed	[31:0]		reg_c,
	input	logic	signed	[31:0]		reg_d,
	output	logic	signed	[31:0]		reg_result,
	output  logic                       done
);


    logic signed [63:0] result_64_bit;
    assign rst_n = ~wb_rst_i;
     
    typedef enum logic [1:0] {IDLE, CALC, COMPLETE} state_t;
    state_t state, next_state;

    logic signed [31:0] next_result;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            reg_result <= '0;
            done <= 1'b0;
        end else begin
            state <= next_state;
            if (state == CALC) begin
                reg_result <= next_result;
                done <= 1'b1;
            end else if (state == IDLE) begin
                done <= 1'b0;
            end
        end
    end

    always_comb begin
        next_state = state;
        next_result = '0;

        case (state)
            IDLE: begin
                if (go) next_state = CALC;
            end
            CALC: begin
                // Extract 8-bit chunks, cast to signed, multiply, and accumulate
                next_result = 
                    $signed(reg_a[31:24]) * $signed(reg_b[31:24]) +
                    $signed(reg_a[23:16]) * $signed(reg_b[23:16]) +
                    $signed(reg_a[15:8])  * $signed(reg_b[15:8])  +
                    $signed(reg_a[7:0])   * $signed(reg_b[7:0])   +
                    $signed(reg_c[31:24]) * $signed(reg_d[31:24]) +
                    $signed(reg_c[23:16]) * $signed(reg_d[23:16]) +
                    $signed(reg_c[15:8])  * $signed(reg_d[15:8])  +
                    $signed(reg_c[7:0])   * $signed(reg_d[7:0]);
                next_state = COMPLETE;
            end
            COMPLETE: begin
                if (!go) next_state = IDLE; // Wait for software to clear the Go bit
            end
            default: next_state = IDLE;
        endcase
    end
endmodule
