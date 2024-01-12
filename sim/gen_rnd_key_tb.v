module gen_rnd_key_tb();

reg		[127:0] key_in;
wire	[127:0] key_out;

gen_rnd_key DUT (4'd1, key_in, key_out);

integer i;

reg 	[127:0] test_vector [2:0];

initial begin
	
	test_vector[0] = 128'h000000000000000000000000A3928674;
	test_vector[1] = 128'h00000000122334450000000000000000;

	for (i = 0; i < 2; i  = i + 1) begin
		key_in = test_vector[i]; #10;
		$display("%d. key_in = %h; key_out = %h", i, key_in, key_out);
	end

end

endmodule