module datapath_tb();

//inputs
reg				clk = 0, init, ctrl1, ctrl2, ctrl3;
reg [3:0] 		rnd;
reg [127:0]		plain_text, key;


//outputs
wire			done;
wire [127:0]	cipher_text;

datapath DUT (clk, init, ctrl1, ctrl2, ctrl3, rnd, plain_text, key, done, cipher_text);

always
	#5 clk = ~clk;

initial begin
	$dumpfile("datapath_tb.vcd");
	$dumpvars(0,datapath_tb);

	init 		= 0;	ctrl1 = 0;	ctrl2 = 0;	ctrl3 = 0;		#20;
	init 		= 1;											#30;
	init 		= 0;	ctrl1 = 1;	ctrl2 = 1;	ctrl3 = 1;	
	plain_text 	= 128'h00000000000000000000000012233445;
	key			= 128'h000000000000000000000000A3928674;		
	rnd			= 4'd1;											#10;
	ctrl1 		= 0;	ctrl2 = 0;	ctrl3 = 0;					#500;

	$finish;
end

endmodule