module toplevel_tb();

reg				clk = 1'b0, rst, strt_btn, entr_new_pair_btn;
reg		[127:0]	plain_text, key;
wire			done;
wire	[127:0]	cipher_text;

toplevel DUT (clk, rst, strt_btn, entr_new_pair_btn, plain_text, key, cipher_text, done);

always
	#5 clk = ~clk;

initial begin
	$dumpfile("toplevel_tb.vcd");
	$dumpvars(0,toplevel_tb);

	//PHASE - 1
	rst <= 0;	strt_btn = 0;	entr_new_pair_btn = 0;			#18;
	rst <= 1;													#4;
	rst <= 0;													#6
	
	//PHASE - 2
	strt_btn	<= 1;

	plain_text	<= 128'h00000000000000000000000012233445;
	key			<= 128'h000000000000000000000000ABBCCDDE;		#4;

	strt_btn	<= 0;											#46

	// //PHASE - 3
	// entr_new_pair_btn = 1;

	// plain_text		  = 128'h00000000000000000000000067788991;
	// key				  = 128'h000000000000000000000000ABCDEFAB;	#4;

	// entr_new_pair_btn = 0;

	//						----------------					//
	
																#500;

	$finish;
end

endmodule