module datapath(clk, compute, do_load, init, add_track, sub_track, rnd, plain_text, key, track_avlbl, cmplt_sts, cur_mc2ark3_val, cur_ark2sb4_val, cur_mc2ark4_val, cipher_text);
input 			clk, compute, do_load, init, add_track, sub_track;
input	[3:0]	rnd;
input 	[127:0]	plain_text;
input 	[127:0]	key;
output			track_avlbl, cmplt_sts;
output	[3:0]	cur_ark2sb4_val, cur_mc2ark3_val, cur_mc2ark4_val;
output 	[127:0] cipher_text;

//Vector used to track vacancies in the pipeline
wire			track_avlbl, cmplt_sts;
reg		[3:0]	track, new_pair_id;

//User - Input Stage
wire	[3:0] 	mux3, mux4;
wire	[127:0] mux1, mux2;

//Feedback stage muxs
wire	[3:0]	fb_ark2sb3, fb_ark2sb4;
wire	[127:0]	fb_ark2sb1, fb_ark2sb2;

//New module ins and outs
wire	[3:0]	grk_rnd, mc_rnd;
wire	[127:0] sb_in, sb_out, sr_in, sr_out, mc_in, mc_out, ark_in, ark_out, grk_in, grk_out;

//Pipeline Registers
reg		[3:0]	ark2sb3, ark2sb4, sb2sr3, sb2sr4, sr2mc3, sr2mc4, mc2ark3, mc2ark4;
reg		[127:0] ark2sb1, ark2sb2, sb2sr1, sb2sr2, sr2mc1, sr2mc2, mc2ark1, mc2ark2;

//Combinational blocks
sub_bytes	sb	(sb_in,		sb_out				);
shift_rows	sr	(sr_in,		sr_out				);
mix_columns	mc	(mc_rnd,	mc_in,		mc_out	);
gen_rnd_key	grk	(grk_rnd, 	grk_in,		grk_out	);
add_rnd_key ark (grk_out,	ark_in,		ark_out	);

//Connecting module inputs with pipeline register outputs
assign sb_in	= ark2sb1;
assign sr_in	= sb2sr1;
assign mc_in	= sr2mc1;
assign mc_rnd	= sr2mc3;
assign ark_in	= mc2ark1;
assign grk_in 	= mc2ark2;
assign grk_rnd	= mc2ark3;

//Making a decision to either accept user input or previous round feedback
assign mux1 = do_load ? plain_text	: fb_ark2sb1;
assign mux2 = do_load ? key			: fb_ark2sb2;
assign mux3 = do_load ? rnd			: fb_ark2sb3;
assign mux4 = do_load ? new_pair_id	: fb_ark2sb4;

//** Stage - 1 **//
always @ (posedge clk) begin
	if(compute || do_load || init) begin
		ark2sb1 <= init ? 128'd0	: mux1;
		ark2sb2 <= init ? 128'd0	: mux2;
		ark2sb3 <= init ? 4'd0		: mux3;
		ark2sb4	<= init ? 4'hF		: mux4;
	end
end

//** Stage - 2 **//
always @ (posedge clk) begin
	if(compute || init) begin
		sb2sr1 <= init ? 128'd0 : sb_out;
		sb2sr2 <= init ? 128'd0 : ark2sb2;
		sb2sr3 <= init ? 4'd0	: ark2sb3;
		sb2sr4 <= init ? 4'hF	: ark2sb4;
	end
end

//** Stage - 3 **//
always @ (posedge clk) begin
	if(compute || init) begin
		sr2mc1 <= init ? 128'd0	: sr_out;
		sr2mc2 <= init ? 128'd0	: sb2sr2;
		sr2mc3 <= init ? 4'd0	: sb2sr3;
		sr2mc4 <= init ? 4'hF	: sb2sr4;
	end
end

//** Stage - 4 **//
always @ (posedge clk) begin
	if(compute || init) begin
		mc2ark1 <= init ? 128'd0	: mc_out;
		mc2ark2 <= init ? 128'd0	: sr2mc2;
		mc2ark3 <= init ? 4'd0		: sr2mc3;
		mc2ark4 <= init ? 4'hF		: sr2mc4;
	end
end

//Alllocting a pair no. for the newly entering key - plain text pair
always @ (posedge clk) begin
	if(init) begin
		track		<= 4'hf;
		new_pair_id	<= 4'd0;
	end
	else if(add_track) begin
		if(track[3]) begin
			new_pair_id <= 4'd1;
			track		<= 4'd7;
		end
		else if(track[2]) begin
			new_pair_id <= 4'd2;
			track		<= 4'd3;
		end
		else if(track[1]) begin
			new_pair_id <= 4'd3;
			track		<= 4'd1;
		end
		else if(track[0]) begin
			new_pair_id <= 4'd4;
			track		<= 4'd0;
		end
	end
end

//Deallocating pair no. during offload state
always @ (posedge clk) begin
	if(sub_track) begin
		if(mc2ark4 == 4'd1)
			track[3] <= 1'b1;
		else if(mc2ark4 == 4'd2)
			track[2] <= 1'b1;
		else if(mc2ark4 == 4'd3)
			track[1] <= 1'b1;
		else if(mc2ark4 == 4'd4)
			track[0] <= 1'b1;
	end
end

assign cipher_text = sub_track ? ark_out : 128'd0;

//Pipeline Feedback Stage
assign fb_ark2sb1 = sub_track ? 128'd0	: ark_out;
assign fb_ark2sb2 = sub_track ? 128'd0	: grk_out;
assign fb_ark2sb3 = sub_track ? 4'd0	: (mc2ark3 + 1);
assign fb_ark2sb4 = sub_track ? 4'hF	: mc2ark4;

//Feedback to controller
assign track_avlbl		= |track;
assign cmplt_sts		= &track;
assign cur_mc2ark3_val	= mc2ark3;
assign cur_mc2ark4_val	= mc2ark4;
assign cur_ark2sb4_val	= ark2sb4;
endmodule