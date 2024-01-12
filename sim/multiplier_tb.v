module multiplier_tb();

reg		[7:0] dataa;
wire	[7:0] datar2;
wire	[7:0] datar3;

multiplier DUT (dataa, datar2, datar3);

integer 		i;

reg 	[8:0] test_vector [5:0];

initial begin
	
	test_vector[0] = 8'd0;
	test_vector[1] = 8'h95;
	test_vector[2] = 8'hC3;
	test_vector[3] = 8'hEC;
	test_vector[4] = 8'h97;

	for (i = 0; i < 5; i  = i + 1) begin
		dataa = test_vector[i]; #30;
		$display("%d. multiplier_in = %h; multiplier*2 result = %h; multiplier*3 result = %h", i, dataa, datar2, datar3);
	end

end

endmodule