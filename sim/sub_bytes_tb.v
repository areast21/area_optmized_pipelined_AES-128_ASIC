module sub_bytes_tb();

reg		[127:0] state_in;
wire	[127:0] state_out;

sub_bytes DUT (state_in, state_out);

integer i;

reg 	[127:0] test_vector [4:0];

initial begin
	
	test_vector[0] = 128'h001F0E543C4E08596E221B0B4774311A;
	test_vector[1] = 128'h5847088B15B61CBA59D4E2E8CD39DFCE;
	test_vector[2] = 128'h43C6A9620E57C0C80908EBFE3DF87F37;
	test_vector[3] = 128'h7876305470767D23993C375B4B3934F1;
	test_vector[4] = 128'hB1CA51ED08FC54E104B1C9D3E7B26C20;

	for (i = 0; i < 5; i  = i + 1) begin
		state_in = test_vector[i]; #10;
		$display("%d. sub_bytes_in = %h; sub_bytes_out = %h", i, state_in, state_out);
	end

end

endmodule