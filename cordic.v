//CORDIC alogrithm 
//author:yanshanyan@csdn

module cordic(
        clk_in,
        reset_n,
        ena,
        phase_in,
        clk_out,
        phase_out,
        cos_o,
        sin_o
        );
  parameter dat_width = 16, pha_width =16, pipeline = 10;


  input clk_in, reset_n, ena;
  input [pha_width-1 : 0] phase_in;

  output clk_out;
  output [pha_width-1 : 0] phase_out;
  output [dat_width-1 : 0] cos_o, sin_o;

//reg [1:0] quad;
//reg [pha_width-3 : 0] phase;

  reg [dat_width-1 : 0] x[pipeline :0];
  reg [dat_width-1 : 0] y[pipeline :0];
  reg [pha_width-1 : 0] z[pipeline :0];
  
  reg [pha_width-1 : 0] phase_tmp[pipeline :0];


  wire [dat_width-1:0] amp;
  wire [pha_width-1:0] atan [32:0];

  
  assign amp = 32'd1304065887 >>(32-dat_width);      //K=0.607253 * 2^(datwidth-1), 1bit sign bit  
  assign atan[0] = 32'd536870912 >>(32-pha_width);   //atan(1) * 2^(pha_width) /360    = 45? * 2^(pha_width) /360
	assign atan[1] = 32'd316933407 >>(32-pha_width);   //atan(1/2) * 2^(pha_width) /360  = 26.5651 ? * 2^(pha_width) /360
	assign atan[2]	= 32'd167458907 >>(32-pha_width);   //atan(1/4)  = 26.5651
	assign atan[3]= 32'd85004756 >>(32-pha_width);     //atan(1/8)  = 14.0362
	assign atan[4]= 32'd42667331 >>(32-pha_width);     //atan(1/16)  = 7.1250
	assign atan[5]= 32'd21354465 >>(32-pha_width);     //atan(1/32)  = 3.5763
	assign atan[6]= 32'd10679838 >>(32-pha_width);     //atan(1/64)  = 1.7899
	assign atan[7]= 32'd5340245 >>(32-pha_width);      //atan(1/128)  = 0.8952
	assign atan[8]= 32'd2670163 >>(32-pha_width);      //atan(1/256)  = 0.4476
	assign atan[9]= 32'd1335087 >>(32-pha_width);      //atan(1/512)  =  0.2238
	assign atan[10]= 32'd667544 >>(32-pha_width);      //atan(1/1024)  = 0.1119
	assign atan[11]= 32'd333772 >>(32-pha_width);      //atan(1/2048)  = 0.0560
	assign atan[12]= 32'd166886 >>(32-pha_width);      //atan(1/4096)  = 0.0280
	assign atan[13]= 32'd83443 >>(32-pha_width);      //atan(1/8192)  = 0.0140
	assign atan[14]= 32'd41722 >>(32-pha_width);      // 0.0070
	assign atan[15]= 32'd20861 >>(32-pha_width);      // 0.0035
	assign atan[16]= 32'd10430 >>(32-pha_width);      // 0.0017
	assign atan[17]= 32'd5215 >>(32-pha_width);      // 0.0009 
	assign atan[18]= 32'd2608 >>(32-pha_width);      // 0.0004
	assign atan[19]= 32'd1304 >>(32-pha_width);      // 0.0002 
	assign atan[20]= 32'd652 >>(32-pha_width);      //  0.0001 
	assign atan[21]= 32'd326 >>(32-pha_width);      // 
	assign atan[22]= 32'd163 >>(32-pha_width);
	assign atan[23]= 32'd81 >>(32-pha_width);
	assign atan[24]= 32'd41 >>(32-pha_width);
	assign atan[25]= 32'd20 >>(32-pha_width);
	assign atan[26]= 32'd10 >>(32-pha_width);
	assign atan[27]= 32'd5 >>(32-pha_width);
	assign atan[28]= 32'd3 >>(32-pha_width);
	assign atan[29]= 32'd1 >>(32-pha_width);
	assign atan[30]= 32'd1 >>(32-pha_width);
	assign atan[31]= 32'd0 >>(32-pha_width);
	assign atan[32]= 32'd0 >>(32-pha_width);


//input latch; get quadrant, adjust pahse to quardant 1
//initial x0 and y0 and z0
always @(posedge clk_in )
begin
  if( !reset_n )  //reset syn
  begin
     x[0] <= 0;
      y[0] <= 0;
      z[0] <= 0;
      phase_tmp[0] <=  0;
  end
  else
  begin
      x[0] <= amp;
      y[0] <= 0;
      z[0] <= { 2'b0, phase_in[pha_width-3 : 0]};
      phase_tmp[0] <=  phase_in;                  
  end    
end

// cordic  calclulate
genvar i;
  wire [dat_width-1 : 0] x_tmp[pipeline-1 :0];
  wire [dat_width-1 : 0] y_tmp[pipeline-1 :0];
  wire [pha_width-1 : 0] z_tmp[pipeline-1 :0];

generate for(i=1;i<=pipeline;i=i+1) begin:cordic_core  
  cordic_step #(dat_width,pha_width,i) cordic_step_inst(x[i-1],y[i-1],z[i-1],atan[i-1],x_tmp[i-1],y_tmp[i-1],z_tmp[i-1]);
  always @(posedge clk_in)
  begin
   if(!reset_n)
   begin
      x[i] <= 0;
      y[i] <= 0;
      z[i] <= 0;
      phase_tmp[i]<=0;
   end
   else 
   begin             
      x[i] <= x_tmp[i-1];     
      y[i] <= y_tmp[i-1];     
      z[i] <= z_tmp[i-1]; 
      phase_tmp[i] <= phase_tmp[i-1];      
   end        
  end
end
endgenerate

//adjust sign according to quadrant\
reg [dat_width-1 : 0] cos_o, sin_o;
reg [pha_width-1 : 0] phase_out;
wire [pha_width-1:0] quad_tmp;
wire [1:0] quad;
assign quad_tmp = phase_tmp[pipeline];
assign quad = quad_tmp[pha_width-1: pha_width-2];
wire [dat_width-1 : 0] x_o_wire, y_o_wire;
wire [dat_width-1 : 0] x_o_wire_tmp, y_o_wire_tmp;

assign x_o_wire_tmp = x[pipeline];
assign y_o_wire_tmp = y[pipeline];

//clear negative value in quadrant 1 when near to 0;
assign x_o_wire = x_o_wire_tmp[dat_width-1] ? {(dat_width){1'b0}} : x[pipeline];
assign y_o_wire = y_o_wire_tmp[dat_width-1] ? {(dat_width){1'b0}} : y[pipeline];

// adjust value to orignal quadrant  
always @(posedge clk_in)
begin
  if( !reset_n)
  begin
    cos_o <= 0;
    sin_o <= 0;
    phase_out <= 0;    
  end
  else    
  begin
    case( quad[1:0] )
      2'b00:begin
            cos_o <= x_o_wire;// x[pipeline];
            sin_o <= y_o_wire;//y[pipeline];
            end
      2'b01:begin
            cos_o <= ~y_o_wire + 1'b1;
            sin_o <= x_o_wire;
            end
      2'b10:begin
            cos_o <= ~x_o_wire + 1'b1;
            sin_o <= ~y_o_wire + 1'b1;
            end
      2'b11:begin
            cos_o <= y_o_wire;
            sin_o <= ~x_o_wire + 1'b1;
            end
      default:begin
            cos_o <= x_o_wire;
            sin_o <= y_o_wire;
            end
    endcase
    
    phase_out <= phase_tmp[pipeline];
  end
end


      
endmodule
/////////////////////////////
//module cordic_step

module cordic_step(
  dat_a,
  dat_b,
  dat_c,
  dat_pha,
  out_a,
  out_b,
  out_c
  );
  parameter dat_width = 16, pha_width = 16, pipe_index = 3;

  input [dat_width-1:0] dat_a, dat_b;
  input [pha_width-1:0] dat_c;
  input [pha_width-1:0] dat_pha;
  output[dat_width-1:0] out_a, out_b;
  output [pha_width-1:0] out_c;

  wire [dat_width:0] out_a_tmp1, out_a_tmp2, out_a_tmp3, out_b_tmp1, out_b_tmp2, out_b_tmp3;
  wire [pha_width-1:0] out_c_tmp1,out_c_tmp2 ;
  wire [1:0] ov_a,ov_b;
  
  //calculate
generate
  if(pipe_index == 6'b1 )
  begin
    //
    assign out_a_tmp1 = { dat_a[dat_width-1], dat_a} + { dat_b[dat_width-1], dat_b};
    assign out_b_tmp1 = { dat_b[dat_width-1], dat_b} - { dat_a[dat_width-1], dat_a};
    assign out_c_tmp1 = dat_c + dat_pha;
    //
    assign out_a_tmp2 = { dat_a[dat_width-1], dat_a} - { dat_b[dat_width-1], dat_b};
    assign out_b_tmp2 = { dat_b[dat_width-1], dat_b} + { dat_a[dat_width-1], dat_a};
    assign out_c_tmp2 = dat_c - dat_pha;
  end
  else
  begin
     //
     assign out_a_tmp1 = { dat_a[dat_width-1], dat_a} + { { (pipe_index){dat_b[dat_width-1]} }, dat_b[dat_width-1: (pipe_index-1)] } ;
     assign out_b_tmp1 = { dat_b[dat_width-1], dat_b} - { { (pipe_index){dat_a[dat_width-1]} }, dat_a[dat_width-1: (pipe_index-1)] } ;
     assign out_c_tmp1 = dat_c + dat_pha;
    //
     assign out_a_tmp2 = { dat_a[dat_width-1], dat_a} - { { (pipe_index){dat_b[dat_width-1]} }, dat_b[dat_width-1: (pipe_index-1)] } ;
     assign out_b_tmp2 = { dat_b[dat_width-1], dat_b} + { { (pipe_index){dat_a[dat_width-1]} }, dat_a[dat_width-1: (pipe_index-1)] } ;
     assign out_c_tmp2 = dat_c - dat_pha;
  end
  
  assign out_a_tmp3 = dat_c[pha_width-1] ? out_a_tmp1 :out_a_tmp2;
  assign out_b_tmp3 = dat_c[pha_width-1] ? out_b_tmp1 :out_b_tmp2;
  
endgenerate

  assign ov_a = out_a_tmp3[dat_width:dat_width-1];
  assign ov_b = out_b_tmp3[dat_width:dat_width-1];
  //anti overflow
  assign out_a = ~^ ov_a ? (out_a_tmp3[dat_width-1:0]):(ov_a[1] ? {1'b1, {(dat_width-1){1'b0}} } : {1'b0, {(dat_width-1){1'b1}} } );
  assign out_b = ~^ ov_b ? (out_b_tmp3[dat_width-1:0]):(ov_b[1] ? {1'b1, {(dat_width-1){1'b0}} } : {1'b0, {(dat_width-1){1'b1}} } );
  
  assign out_c = dat_c[pha_width-1] ? out_c_tmp1 :out_c_tmp2;
  
endmodule
