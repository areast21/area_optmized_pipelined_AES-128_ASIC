module shift_rows_tb();

reg		[127:0] state_in;
wire	[127:0] state_out;

shift_rows DUT (state_in, state_out);

reg 	[127:0] test_vector [4:0];

reg		[7:0] 	selected_byte;

integer 		i;

initial begin
	
	test_vector[0] = 128'h63C0AB20EB2F30CB9F93AF2BA092C7A2;
	test_vector[1] = 128'h6AA0303D594E9CF4CB48989BBD129E8B;
	test_vector[2] = 128'h1AB4D3AAAB5BBAE80130E9BB2741D29A;
	test_vector[3] = 128'hBC3804205138FF26EEEB9A39B31218A1;
	test_vector[4] = 128'hC874D15530B020F8F2C8DD66943750B7;

	for (i = 0; i < 5; i  = i + 1) begin
		state_in = test_vector[i]; #10;
		$display("%d. shift_rows_in = %h; shift_rows_out = %h", i, state_in, state_out);
	end

end

endmodule