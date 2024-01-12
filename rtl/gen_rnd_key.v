module gen_rnd_key(rnd, key_in, key_out);

input		[3:0]	rnd;
input		[127:0]	key_in;
output	reg	[127:0]	key_out;

reg 		[31:0]	rcon, g_func_out;

wire 		[31:0]	rot_word, sub_word;

always @ (*) begin
	case(rnd)
		4'd1:  		rcon = {8'h01, 24'd0};
		4'd2:  		rcon = {8'h02, 24'd0};
		4'd3:  		rcon = {8'h04, 24'd0};
		4'd4:  		rcon = {8'h08, 24'd0};
		4'd5:  		rcon = {8'h10, 24'd0};
		4'd6:  		rcon = {8'h20, 24'd0};
		4'd7:  		rcon = {8'h40, 24'd0};
		4'd8:  		rcon = {8'h80, 24'd0};
		4'd9:  		rcon = {8'h1B, 24'd0};
		4'd10: 		rcon = {8'h36, 24'd0};
		default: 	rcon = 32'd0;	
	endcase
	
	//All of this should be accomplished by just these two lines but using a case statement to elaborate
	//rcon = (rnd >= 0 && rnd <=7) ? {(const << rnd), 24'd0} : (rnd == 4'd8) ?
	//{8'h1B, 24'd0} : {8'h36, 24'b0};
	
	g_func_out		= rcon 			^ sub_word;
	key_out[31:0] 	= g_func_out	^ key_in[31:0];
	key_out[63:32] 	= key_out[31:0]	^ key_in[63:32];
	key_out[95:64] 	= key_out[63:32]^ key_in[95:64];
	key_out[127:96]	= key_out[95:64]^ key_in[127:96];
end

//Rotword() on upper 32-bit of prev round key
assign rot_word = key_in[127:96] << 24 | key_in[127:96] >> 8;

//Subword() on Rotword() output
sub_box
	s0(rot_word[7:0], 	sub_word[7:0]),
	s1(rot_word[15:8], 	sub_word[15:8]),
	s2(rot_word[23:16], sub_word[23:16]),
	s3(rot_word[31:24], sub_word[31:24]);

endmodule