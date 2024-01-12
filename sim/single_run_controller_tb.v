module single_run_controller_tb();

reg		clk = 1'b0, rst_, start, done;
wire	ctrl1, ctrl2, init;

single_run_controller DUT (clk, rst_, start, done, ctrl1, ctrl2, init);

always
	#5 clk = ~clk;

initial begin
	$dumpfile("single_run_controller_tb.vcd");
	$dumpvars(0,single_run_controller_tb);

	rst_ 	= 1;	start = 0; 	done = 0;	#13;
	rst_ 	= 0; 							#4;
	rst_ 	= 1; 							#11;
	start	= 1;							#14;
	start	= 0;							#40;

	$finish;
end

endmodule