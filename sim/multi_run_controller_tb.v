module multi_run_controller_tb();

reg				clk = 1'b0, cmplt_sts, rst, start, enter_new_pair, track_available;
reg		[3:0]	ark2sb4, mc2ark3, mc2ark4;
wire			ok2load, ok2compute, init, perform_offload, done;

multi_run_controller DUT 	(
							clk, cmplt_sts, rst, enter_new_pair, start, track_available, ark2sb4, mc2ark3, mc2ark4,
							init, ok2compute, perform_offload, ok2load, done
							);

always
	#5 clk = ~clk;

initial begin
	$dumpfile("multi_run_controller_tb.vcd");
	$dumpvars(0,multi_run_controller_tb);

	rst 	= 0;		start = 0;				enter_new_pair = 0;												#27;
	rst 	= 1;																								#4;
	rst 	= 0;																								#6;
	start	= 1;		track_available = 1;	cmplt_sts = 1;		ark2sb4 = 4'hF;			mc2ark3 = 4'd0;		#4;
	start	= 0;																								#46;
	enter_new_pair = 1;																							#4;
	enter_new_pair = 0;																							#50;
	$finish;
end

endmodule