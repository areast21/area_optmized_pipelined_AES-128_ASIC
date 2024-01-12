module multi_run_controller	(
							clk, cmplt_sts, rst, enter_new_pair, start, track_avlbl, cur_ark2sb4_val, cur_mc2ark3_val, cur_mc2ark4_val,
							init, do_add_track, do_load, do_compute, do_sub_track, done
							);

input 				clk, cmplt_sts, rst, enter_new_pair, start, track_avlbl;
input 		[3:0]	cur_ark2sb4_val, cur_mc2ark3_val, cur_mc2ark4_val;
output	reg			init, do_add_track, do_load, do_compute, do_sub_track, done;

reg 		[3:0]	state, next_state;

localparam	idle = 3'd0, initialize = 3'd1, check_capacity = 3'd2, allocate_tracker = 3'd3, load = 3'd4, compute = 3'd5, deallocate_tracker = 3'd6, check_exit = 3'd7;

//Current state update
always @ (negedge clk)
	state <= rst ? idle : next_state;

//Next state combinational logic
always @ (state, cmplt_sts, enter_new_pair, start, track_avlbl, cur_ark2sb4_val, cur_mc2ark3_val, cur_mc2ark4_val) begin
	case(state)
		idle:				next_state = start ? initialize : idle;
		initialize:			next_state = check_capacity;
		check_capacity:		begin
								if(track_avlbl && cur_ark2sb4_val == 15)
									next_state = allocate_tracker;
								else if(!track_avlbl | (cur_ark2sb4_val >= 1 && cur_ark2sb4_val <= 4))
									next_state = compute;
							end
		allocate_tracker:	next_state = load;
		load:				next_state = compute;	
		compute:			next_state = enter_new_pair ? check_capacity : (((cur_mc2ark3_val == 10) && cur_mc2ark4_val != 15) ? deallocate_tracker : compute);
		deallocate_tracker:	next_state = check_exit;
		check_exit:			next_state = (cmplt_sts) ? idle : compute;
		default:			next_state = idle;
	endcase
end

//output logic
always @ (state) begin
	case(state)
		idle, check_capacity, check_exit	:begin
												init		= 0;
												do_add_track= 0;
												do_load		= 0;
												do_compute	= 0;
												do_sub_track= 0;
												done		= 0;
											end
		initialize:							begin
												init		= 1;
												do_add_track= 0;
												do_load		= 0;
												do_compute	= 0;
												do_sub_track= 0;
												done		= 0;
											end
		allocate_tracker:					begin
												init		= 0;
												do_add_track= 1;
												do_load		= 0;
												do_compute	= 0;
												do_sub_track= 0;
												done		= 0;
											end
		load:								begin
												init		= 0;
												do_add_track= 0;
												do_load		= 1;
												do_compute	= 0;
												do_sub_track= 0;
												done		= 0;
											end
		compute:							begin
												init		= 0;
												do_add_track= 0;
												do_load		= 0;
												do_compute	= 1;
												do_sub_track= 0;
												done		= 0;
											end
		deallocate_tracker:					begin
												init		= 0;
												do_add_track= 0;
												do_load		= 0;
												do_compute	= 0;
												do_sub_track= 1;
												done		= 1;
											end
	endcase
end

endmodule