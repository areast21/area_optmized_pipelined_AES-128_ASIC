module mix_columns_tb();

reg		[127:0] state_in;
wire	[127:0] state_out;

mix_columns DUT (state_in, state_out);

integer 		i;

reg 	[127:0] test_vector [3:0];

initial begin
	
	$dumpfile("mix_columns_tb.vcd");
	$dumpvars(0,mix_columns_tb);

	test_vector[0] = 128'd0;
	test_vector[1] = 128'h876E46A6F24CE78C4D904AD897ECC395;
	test_vector[2] = 128'h632FAFA2EB93C7209F92ABCBA0C0302B;

	for (i = 0; i < 3; i  = i + 1) begin
		state_in = test_vector[i]; #10;
		$display("%d. mix_columns_in = %h; mix_columns_out = %h", i, state_in, state_out);
	end

end

endmodule