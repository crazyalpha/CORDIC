`timescale  1ns/1ns
module cordic_testbench;
parameter dat_width = 16, pha_width =16, pipeline = 10;  
  reg clk, rst_n;
   
  reg [pha_width-1 : 0] phase;  
  wire [pha_width-1 : 0] phase_o;
  wire [dat_width-1 : 0] cos, sin;
  
 	initial
	fork	
	rst_n=1'b0;
	clk=1'b0;	
	#100 rst_n=1'b1;	
	forever #10 clk=~clk;
	
	join
	
	always @(posedge clk)
	begin
	 if(!rst_n)
	    phase <= 0;
	 else
	    phase <= phase +1 ;	    
	end
	
	cordic cordic_inst(
        .clk_in(clk),
        .reset_n(rst_n),
        .ena(1'b1),
        .phase_in(phase),
        .clk_out(),
        .phase_out(phase_o),
        .cos_o(cos),
        .sin_o(sin)
        );
endmodule
	  