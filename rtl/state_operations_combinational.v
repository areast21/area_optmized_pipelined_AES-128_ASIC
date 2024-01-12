module sub_bytes (state_in, state_out);
	input	wire	[127:0]	state_in;
	output	wire	[127:0]	state_out;
	sub_box
		sb0		(state_in[7:0],		state_out[7:0]		),
		sb1		(state_in[15:8],	state_out[15:8]		),
		sb2		(state_in[23:16],	state_out[23:16]	),
		sb3		(state_in[31:24],	state_out[31:24]	),
		sb4		(state_in[39:32],	state_out[39:32]	),
		sb5		(state_in[47:40],	state_out[47:40]	),
		sb6		(state_in[55:48],	state_out[55:48]	),
		sb7		(state_in[63:56],	state_out[63:56]	),
		sb8		(state_in[71:64],	state_out[71:64]	),
		sb9		(state_in[79:72],	state_out[79:72]	),
		sb10	(state_in[87:80],	state_out[87:80]	),
		sb11	(state_in[95:88],	state_out[95:88]	),
		sb12	(state_in[103:96],	state_out[103:96]	),
		sb13	(state_in[111:104],	state_out[111:104]	),
		sb14	(state_in[119:112],	state_out[119:112]	),
		sb15	(state_in[127:120],	state_out[127:120]	);
endmodule

module shift_rows(state_in, state_out);
	input	wire	[127:0]	state_in;
	output	wire	[127:0]	state_out;
	reg				[127:0] temp_res;
	always @ (state_in) begin
		//No shifting done on 1st row
		temp_res [7:0]		<= state_in[7:0];
		temp_res [39:32]	<= state_in[39:32];
		temp_res [71:64]	<= state_in[71:64];
		temp_res [103:96]	<= state_in[103:96];
		//LCS 2nd row by 1 byte
		temp_res [15:8]		<= state_in[47:40];
		temp_res [47:40]	<= state_in[79:72];
		temp_res [79:72]	<= state_in[111:104];
		temp_res [111:104]	<= state_in[15:8];
		//LCS 3rd row by 2 byte
		temp_res [23:16]	<= state_in[87:80];
		temp_res [55:48]	<= state_in[119:112];
		temp_res [87:80]	<= state_in[23:16];
		temp_res [119:112]	<= state_in[55:48];
		//LCS 4th row by 3 byte
		temp_res [31:24]	<= state_in[127:120];
		temp_res [63:56]	<= state_in[31:24];
		temp_res [95:88]	<= state_in[63:56];
		temp_res [127:120]	<= state_in[95:88];
	end
	assign state_out = temp_res;
endmodule

module mix_columns (rnd, state_in, state_out);
	input	wire	[3:0]		rnd;
	input	wire	[127:0]		state_in;
	output	wire	[127:0]		state_out;
	reg				[127:0]		temp_res;
	wire			[15:0] 		rslt [15:0];
	genvar 						i;

	for(i = 0; i < 16; i = i + 1) begin
		multiplier mul_circuit (state_in[7+(8*i):8*i], rslt[i][7:0], rslt[i][15:8]);
	end

	always @ (*) begin
		if(rnd >= 1 && rnd <= 9) begin
			//GF(2^8) transformation for 1st column
			temp_res [7:0]		<= rslt[0][7:0]		^	rslt[1][15:8]		^	state_in[23:16]		^	state_in[31:24];
			temp_res [15:8]		<= state_in[7:0]	^	rslt[1][7:0]		^	rslt[2][15:8]		^	state_in[31:24];
			temp_res [23:16]	<= state_in[7:0]	^	state_in[15:8] 		^	rslt[2][7:0]		^	rslt[3][15:8];
			temp_res [31:24]	<= rslt[0][15:8]	^	state_in[15:8]		^	state_in[23:16]		^	rslt[3][7:0];
			//GF(2^8) transformation for 2nd column
			temp_res [39:32]	<= rslt[4][7:0]		^	rslt[5][15:8]		^	state_in[55:48]		^	state_in[63:56];
			temp_res [47:40]	<= state_in[39:32]	^	rslt[5][7:0]		^	rslt[6][15:8]		^	state_in[63:56];
			temp_res [55:48]	<= state_in[39:32]	^	state_in[47:40]		^	rslt[6][7:0]		^	rslt[7][15:8];
			temp_res [63:56]	<= rslt[4][15:8]	^	state_in[47:40]		^	state_in[55:48] 	^	rslt[7][7:0];
			//GF(2^8) transformation for 3rd column
			temp_res [71:64]	<= rslt[8][7:0]		^	rslt[9][15:8]		^	state_in[87:80]		^	state_in[95:88];
			temp_res [79:72]	<= state_in[71:64]	^	rslt[9][7:0]		^	rslt[10][15:8]		^	state_in[95:88];
			temp_res [87:80]	<= state_in[71:64]	^	state_in[79:72] 	^	rslt[10][7:0]		^	rslt[11][15:8];
			temp_res [95:88]	<= rslt[8][15:8]	^	state_in[79:72]		^	state_in[87:80] 	^	rslt[11][7:0];
			//GF(2^8) transformation for 4th column
			temp_res [103:96]	<= rslt[12][7:0]	^	rslt[13][15:8]		^	state_in[119:112]	^	state_in[127:120];
			temp_res [111:104]	<= state_in[103:96]	^	rslt[13][7:0]		^	rslt[14][15:8]		^	state_in[127:120];
			temp_res [119:112]	<= state_in[103:96] ^	state_in[111:104]	^	rslt[14][7:0]		^	rslt[15][15:8];
			temp_res [127:120]	<= rslt[12][15:8]	^	state_in[111:104]	^	state_in[119:112]	^	rslt[15][7:0];	
		end
		else
			temp_res = state_in;
	end
	assign state_out = temp_res;
endmodule

module add_rnd_key(rnd_key, state_in, state_out);
	input	wire	[127:0]		rnd_key;
	input	wire	[127:0]		state_in;
	output	wire	[127:0]		state_out;

	assign state_out = state_in ^ rnd_key;
endmodule

module multiplier (input [7:0] byte_in, output [7:0] out_mul2, out_mul3);
	assign out_mul2 = byte_in[7] ? (byte_in << 1) ^ 8'h1B : (byte_in << 1);
	assign out_mul3 = byte_in[7] ? (byte_in << 1) ^ 8'h1B ^ byte_in : (byte_in << 1) ^ byte_in;
endmodule

module sub_box(input [7:0] byte_in, output [7:0] byte_out);
	reg [7:0] temp_res;
	always @ (byte_in) begin
		case(byte_in)
	      //Row 1
		  8'h00:  temp_res = 8'h63;
		  8'h01:  temp_res = 8'h7c;
		  8'h02:  temp_res = 8'h77;
		  8'h03:  temp_res = 8'h7b;
		  8'h04:  temp_res = 8'hf2;
		  8'h05:  temp_res = 8'h6b;
		  8'h06:  temp_res = 8'h6f;
		  8'h07:  temp_res = 8'hc5;
		  8'h08:  temp_res = 8'h30;
		  8'h09:  temp_res = 8'h01;
		  8'h0a:  temp_res = 8'h67;
		  8'h0b:  temp_res = 8'h2b;
		  8'h0c:  temp_res = 8'hfe;
		  8'h0d:  temp_res = 8'hd7;
		  8'h0e:  temp_res = 8'hab;
		  8'h0f:  temp_res = 8'h76;
		  
		  //Row 2
		  8'h10:  temp_res = 8'hca;
		  8'h11:  temp_res = 8'h82;
		  8'h12:  temp_res = 8'hc9;
		  8'h13:  temp_res = 8'h7d;
		  8'h14:  temp_res = 8'hfa;
		  8'h15:  temp_res = 8'h59;
		  8'h16:  temp_res = 8'h47;
		  8'h17:  temp_res = 8'hf0;
		  8'h18:  temp_res = 8'had;
		  8'h19:  temp_res = 8'hd4;
		  8'h1a:  temp_res = 8'ha2;
		  8'h1b:  temp_res = 8'haf;
		  8'h1c:  temp_res = 8'h9c;
		  8'h1d:  temp_res = 8'ha4;
		  8'h1e:  temp_res = 8'h72;
		  8'h1f:  temp_res = 8'hc0;
		  
		  //Row 3
		  8'h20:  temp_res = 8'hb7;
		  8'h21:  temp_res = 8'hfd;
		  8'h22:  temp_res = 8'h93;
		  8'h23:  temp_res = 8'h26;
		  8'h24:  temp_res = 8'h36;
		  8'h25:  temp_res = 8'h3f;
		  8'h26:  temp_res = 8'hf7;
		  8'h27:  temp_res = 8'hcc;
		  8'h28:  temp_res = 8'h34;
		  8'h29:  temp_res = 8'ha5;
		  8'h2a:  temp_res = 8'he5;
		  8'h2b:  temp_res = 8'hf1;
		  8'h2c:  temp_res = 8'h71;
		  8'h2d:  temp_res = 8'hd8;
		  8'h2e:  temp_res = 8'h31;
		  8'h2f:  temp_res = 8'h15;
		  
		  //Row 4
		  8'h30:  temp_res = 8'h04;
		  8'h31:  temp_res = 8'hc7;
		  8'h32:  temp_res = 8'h23;
		  8'h33:  temp_res = 8'hc3;
		  8'h34:  temp_res = 8'h18;
		  8'h35:  temp_res = 8'h96;
		  8'h36:  temp_res = 8'h05;
		  8'h37:  temp_res = 8'h9a;
		  8'h38:  temp_res = 8'h07;
		  8'h39:  temp_res = 8'h12;
		  8'h3a:  temp_res = 8'h80;
		  8'h3b:  temp_res = 8'he2;
		  8'h3c:  temp_res = 8'heb;
		  8'h3d:  temp_res = 8'h27;
		  8'h3e:  temp_res = 8'hb2;
		  8'h3f:  temp_res = 8'h75;
		  
		  //Row 5
		  8'h40:  temp_res = 8'h09;
		  8'h41:  temp_res = 8'h83;
		  8'h42:  temp_res = 8'h2c;
		  8'h43:  temp_res = 8'h1a;
		  8'h44:  temp_res = 8'h1b;
		  8'h45:  temp_res = 8'h6e;
		  8'h46:  temp_res = 8'h5a;
		  8'h47:  temp_res = 8'ha0;
		  8'h48:  temp_res = 8'h52;
		  8'h49:  temp_res = 8'h3b;
		  8'h4a:  temp_res = 8'hd6;
		  8'h4b:  temp_res = 8'hb3;
		  8'h4c:  temp_res = 8'h29;
		  8'h4d:  temp_res = 8'he3;
		  8'h4e:  temp_res = 8'h2f;
		  8'h4f:  temp_res = 8'h84;
		  
		  //Row 6
		  8'h50:  temp_res = 8'h53;
		  8'h51:  temp_res = 8'hd1;
		  8'h52:  temp_res = 8'h00;
		  8'h53:  temp_res = 8'hed;
		  8'h54:  temp_res = 8'h20;
		  8'h55:  temp_res = 8'hfc;
		  8'h56:  temp_res = 8'hb1;
		  8'h57:  temp_res = 8'h5b;
		  8'h58:  temp_res = 8'h6a;
		  8'h59:  temp_res = 8'hcb;
		  8'h5a:  temp_res = 8'hbe;
		  8'h5b:  temp_res = 8'h39;
		  8'h5c:  temp_res = 8'h4a;
		  8'h5d:  temp_res = 8'h4c;
		  8'h5e:  temp_res = 8'h58;
		  8'h5f:  temp_res = 8'hcf;
		  
		  //Row 7
		  8'h60:  temp_res = 8'hd0;
		  8'h61:  temp_res = 8'hef;
		  8'h62:  temp_res = 8'haa;
		  8'h63:  temp_res = 8'hfb;
		  8'h64:  temp_res = 8'h43;
		  8'h65:  temp_res = 8'h4d;
		  8'h66:  temp_res = 8'h33;
		  8'h67:  temp_res = 8'h85;
		  8'h68:  temp_res = 8'h45;
		  8'h69:  temp_res = 8'hf9;
		  8'h6a:  temp_res = 8'h02;
		  8'h6b:  temp_res = 8'h7f;
		  8'h6c:  temp_res = 8'h50;
		  8'h6d:  temp_res = 8'h3c;
		  8'h6e:  temp_res = 8'h9f;
		  8'h6f:  temp_res = 8'ha8;
		  
		  //Row 8
		  8'h70:  temp_res = 8'h51;
		  8'h71:  temp_res = 8'ha3;
		  8'h72:  temp_res = 8'h40;
		  8'h73:  temp_res = 8'h8f;
		  8'h74:  temp_res = 8'h92;
		  8'h75:  temp_res = 8'h9d;
		  8'h76:  temp_res = 8'h38;
		  8'h77:  temp_res = 8'hf5;
		  8'h78:  temp_res = 8'hbc;
		  8'h79:  temp_res = 8'hb6;
		  8'h7a:  temp_res = 8'hda;
		  8'h7b:  temp_res = 8'h21;
		  8'h7c:  temp_res = 8'h10;
		  8'h7d:  temp_res = 8'hff;
		  8'h7e:  temp_res = 8'hf3;
		  8'h7f:  temp_res = 8'hd2;
		  
		  //Row 9
		  8'h80:  temp_res = 8'hcd;
		  8'h81:  temp_res = 8'h0c;
		  8'h82:  temp_res = 8'h13;
		  8'h83:  temp_res = 8'hec;
		  8'h84:  temp_res = 8'h5f;
		  8'h85:  temp_res = 8'h97;
		  8'h86:  temp_res = 8'h44;
		  8'h87:  temp_res = 8'h17;
		  8'h88:  temp_res = 8'hc4;
		  8'h89:  temp_res = 8'ha7;
		  8'h8a:  temp_res = 8'h7e;
		  8'h8b:  temp_res = 8'h3d;
		  8'h8c:  temp_res = 8'h64;
		  8'h8d:  temp_res = 8'h5d;
		  8'h8e:  temp_res = 8'h19;
		  8'h8f:  temp_res = 8'h73;
		  
		  //Row 10
		  8'h90:  temp_res = 8'h60;
		  8'h91:  temp_res = 8'h81;
		  8'h92:  temp_res = 8'h4f;
		  8'h93:  temp_res = 8'hdc;
		  8'h94:  temp_res = 8'h22;
		  8'h95:  temp_res = 8'h2a;
		  8'h96:  temp_res = 8'h90;
		  8'h97:  temp_res = 8'h88;
		  8'h98:  temp_res = 8'h46;
		  8'h99:  temp_res = 8'hee;
		  8'h9a:  temp_res = 8'hb8;
		  8'h9b:  temp_res = 8'h14;
		  8'h9c:  temp_res = 8'hde;
		  8'h9d:  temp_res = 8'h5e;
		  8'h9e:  temp_res = 8'h0b;
		  8'h9f:  temp_res = 8'hdb;
		  
		  //Row 11
		  8'ha0:  temp_res = 8'he0;
		  8'ha1:  temp_res = 8'h32;
		  8'ha2:  temp_res = 8'h3a;
		  8'ha3:  temp_res = 8'h0a;
		  8'ha4:  temp_res = 8'h49;
		  8'ha5:  temp_res = 8'h06;
		  8'ha6:  temp_res = 8'h24;
		  8'ha7:  temp_res = 8'h5c;
		  8'ha8:  temp_res = 8'hc2;
		  8'ha9:  temp_res = 8'hd3;
		  8'haa:  temp_res = 8'hac;
		  8'hab:  temp_res = 8'h6c;
		  8'hac:  temp_res = 8'h91;
		  8'had:  temp_res = 8'h95;
		  8'hae:  temp_res = 8'he4;
		  8'haf:  temp_res = 8'h79;
		  
		  //Row 12
		  8'hb0:  temp_res = 8'he7;
		  8'hb1:  temp_res = 8'hc8;
		  8'hb2:  temp_res = 8'h37;
		  8'hb3:  temp_res = 8'h6d;
		  8'hb4:  temp_res = 8'h8d;
		  8'hb5:  temp_res = 8'hd5;
		  8'hb6:  temp_res = 8'h4e;
		  8'hb7:  temp_res = 8'ha9;
		  8'hb8:  temp_res = 8'h6c;
		  8'hb9:  temp_res = 8'h56;
		  8'hba:  temp_res = 8'hf4;
		  8'hbb:  temp_res = 8'hea;
		  8'hbc:  temp_res = 8'h65;
		  8'hbd:  temp_res = 8'h7a;
		  8'hbe:  temp_res = 8'hae;
		  8'hbf:  temp_res = 8'h08;
		  
		  //Row 13
		  8'hc0:  temp_res = 8'hba;
		  8'hc1:  temp_res = 8'h78;
		  8'hc2:  temp_res = 8'h25;
		  8'hc3:  temp_res = 8'h2e;
		  8'hc4:  temp_res = 8'h1c;
		  8'hc5:  temp_res = 8'ha6;
		  8'hc6:  temp_res = 8'hb4;
		  8'hc7:  temp_res = 8'hc6;
		  8'hc8:  temp_res = 8'he8;
		  8'hc9:  temp_res = 8'hdd;
		  8'hca:  temp_res = 8'h74;
		  8'hcb:  temp_res = 8'h1f;
		  8'hcc:  temp_res = 8'h4b;
		  8'hcd:  temp_res = 8'hbd;
		  8'hce:  temp_res = 8'h8b;
		  8'hcf:  temp_res = 8'h8a;
		  
		  //Row 14
		  8'hd0:  temp_res = 8'h70;
		  8'hd1:  temp_res = 8'h3e;
		  8'hd2:  temp_res = 8'hb5;
		  8'hd3:  temp_res = 8'h66;
		  8'hd4:  temp_res = 8'h48;
		  8'hd5:  temp_res = 8'h03;
		  8'hd6:  temp_res = 8'hf6;
		  8'hd7:  temp_res = 8'h0e;
		  8'hd8:  temp_res = 8'h61;
		  8'hd9:  temp_res = 8'h35;
		  8'hda:  temp_res = 8'h57;
		  8'hdb:  temp_res = 8'hb9;
		  8'hdc:  temp_res = 8'h86;
		  8'hdd:  temp_res = 8'hc1;
		  8'hde:  temp_res = 8'h1d;
		  8'hdf:  temp_res = 8'h9e;
		  
		  //Row 15
		  8'he0:  temp_res = 8'he1;
		  8'he1:  temp_res = 8'hf8;
		  8'he2:  temp_res = 8'h98;
		  8'he3:  temp_res = 8'h11;
		  8'he4:  temp_res = 8'h69;
		  8'he5:  temp_res = 8'hd9;
		  8'he6:  temp_res = 8'h8e;
		  8'he7:  temp_res = 8'h94;
		  8'he8:  temp_res = 8'h9b;
		  8'he9:  temp_res = 8'h1e;
		  8'hea:  temp_res = 8'h87;
		  8'heb:  temp_res = 8'he9;
		  8'hec:  temp_res = 8'hce;
		  8'hed:  temp_res = 8'h55;
		  8'hee:  temp_res = 8'h28;
		  8'hef:  temp_res = 8'hdf;
		  
		  //Row 16
		  8'hf0:  temp_res = 8'h8c;
		  8'hf1:  temp_res = 8'ha1;
		  8'hf2:  temp_res = 8'h89;
		  8'hf3:  temp_res = 8'h0d;
		  8'hf4:  temp_res = 8'hbf;
		  8'hf5:  temp_res = 8'he6;
		  8'hf6:  temp_res = 8'h42;
		  8'hf7:  temp_res = 8'h68;
		  8'hf8:  temp_res = 8'h41;
		  8'hf9:  temp_res = 8'h99;
		  8'hfa:  temp_res = 8'h2d;
		  8'hfb:  temp_res = 8'h0f;
		  8'hfc:  temp_res = 8'hb0;
		  8'hfd:  temp_res = 8'h54;
		  8'hfe:  temp_res = 8'hbb;
		  8'hff:  temp_res = 8'h16;
	    endcase
	end
	assign byte_out = temp_res;
endmodule