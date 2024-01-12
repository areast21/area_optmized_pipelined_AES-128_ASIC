module toplevel (clk, rst, strt_btn, entr_new_pair_btn, plain_text, key, cipher_text, done);

input			clk, rst, strt_btn, entr_new_pair_btn;
input	[127:0]	plain_text, key;
output			done;
output	[127:0] cipher_text;

wire			ok2init, ok2load, ok2compute, ok2addtrack, ok2subtrack, ok2track, ok2cmplt;
wire			init, ctrl1, ctrl2, cmpltd;
wire	[3:0]	mc2ark3_val, ark2sb4_val, mc2ark4_val;

datapath 				DPTH	(
								.clk(clk),
								.compute(ok2compute),
								.do_load(ok2load),
								.init(ok2init),
								.add_track(ok2addtrack),
								.sub_track(ok2subtrack),
								.rnd(4'd1),
								.plain_text(plain_text),
								.key(key),
								.track_avlbl(ok2track),
								.cmplt_sts(ok2cmplt),
								.cur_mc2ark3_val(mc2ark3_val),
								.cur_ark2sb4_val(ark2sb4_val),
								.cur_mc2ark4_val(mc2ark4_val),
								.cipher_text(cipher_text)
								);

multi_run_controller 	CTRL	(
								.clk(clk),
								.cmplt_sts(ok2cmplt),
								.rst(rst),
								.enter_new_pair(entr_new_pair_btn),
								.start(strt_btn),
								.track_avlbl(ok2track),
								.cur_ark2sb4_val(ark2sb4_val),
								.cur_mc2ark3_val(mc2ark3_val),
								.cur_mc2ark4_val(mc2ark4_val),
								.init(ok2init), 
								.do_compute(ok2compute),
								.do_add_track(ok2addtrack),
								.do_load(ok2load),
								.do_sub_track(ok2subtrack),
								.done(done)
								);

endmodule