//####################################################################
//####################################################################
//####################################################################
//################ Created by Nick Moore  ############################
//################  for MP2 in ECE 411 at ############################
//################ University of Illinois ############################
//################ Fall 2015              ############################
//####################################################################
//####################################################################
//####################################################################
//#                                                                  #
//#   L2cache_control.sv                                             #
//#     Implements the control module for the LC3B L2cache           #
//#     controls the datapath module for the LC3B L2cache            #
//#     instantiate both in L2cache.sv and connect the inputs/outputs#
//#                                                                  #
//####################################################################

import cache_types::*;
import lc3b_types::*;

module L2cache_control
(
	//signals between cache and cpu datapath
	input mem_read,
	input mem_write,
	output logic mem_resp,

	//signals between cache and physical memory
	output logic pmem_read,
	output logic pmem_write,
	input pmem_resp,

	//signals between cache datapath and cache controller
	input clk,
	output logic valid_data,
	output logic dirty_data,
	output logic [7:0] write,
	output logic [2:0] pmem_wdatamux_sel,		//mux selects
	output logic [7:0] datainmux_sel,	//mux selects
    output logic  pmem_address_mux_sel,
    output logic [2:0] basemux_sel,
//	input cache_tag tag,
	input cache_index index,
	input [7:0] Valid,
	input [7:0] Hit,		//logic determining if there was a hit
	input [7:0] Dirty
);

//#############################################################################################################
//#############################################################################################################
//#############################################################################################################
//############################                                                 ################################
//############################                                                 ################################
//############################              variable declarations              ################################
//############################                                                 ################################
//############################                                                 ################################
//############################                                                 ################################
//#############################################################################################################
//#############################################################################################################
//#############################################################################################################

   enum 		{READY, WRITE_BACK, GET_MEM,GET_MEM_2} state, next_state;
   logic [2:0] lru_out;
   logic [2:0] inter_hit;     //used for converting the Hit aray to an index in assigning write[]
   logic [2:0] recipient;	//the associativity way to write to in the event of a cache miss 

//#############################################################################################################
//#############################################################################################################
//#############################################################################################################
//############################                                                 ################################
//############################                                                 ################################
//############################              variable definitions               ################################
//############################                                                 ################################
//############################                                                 ################################
//############################                                                 ################################
//#############################################################################################################
//#############################################################################################################
//#############################################################################################################

always_comb begin : inter_hit_assignment
   case(Hit)
	 8'h1: inter_hit = 3'h0;
	 8'h2: inter_hit = 3'h1;
	 8'h4: inter_hit = 3'h2;
	 8'h8: inter_hit = 3'h3;
	 8'h10: inter_hit = 3'h4;
	 8'h20: inter_hit = 3'h5;
	 8'h40: inter_hit = 3'h6;
	 8'h80: inter_hit = 3'h7;
	 default: inter_hit = 3'h0;
   endcase // case (hit)
end : inter_hit_assignment
   
always_comb begin : recipient_determination
	if (Valid[0] == 1'b0)
		recipient = 3'h0;
	else if (Valid[1] == 1'b0)
		recipient = 3'h1;
	else if (Valid[2] == 1'b0)
		recipient = 3'h2;
	else if (Valid[3] == 1'b0)
		recipient = 3'h3;
	else if (Valid[4] == 1'b0)
		recipient = 3'h4;
	else if (Valid[5] == 1'b0)
		recipient = 3'h5;
	else if (Valid[6] == 1'b0)
		recipient = 3'h6;
	else if (Valid[7] == 1'b0)
		recipient = 3'h7;
	else recipient = lru_out;

end : recipient_determination

//#############################################################################################################
//#############################################################################################################
//#############################################################################################################
//############################                                                 ################################
//############################                                                 ################################
//############################               least recently used               ################################
//############################                     array                       ################################
//############################                                                 ################################
//############################                                                 ################################
//#############################################################################################################
//#############################################################################################################
//#############################################################################################################

LRU_unit lru
(
    .clk(clk),
    .hit(Hit),
    .mem_resp(mem_resp),
    .index(index),
    .out(lru_out)
);

//#############################################################################################################
//#############################################################################################################
//#############################################################################################################
//############################                                                 ################################
//############################                                                 ################################
//############################                 Next State Logic                ################################
//############################                                                 ################################
//############################                                                 ################################
//############################                                                 ################################
//#############################################################################################################
//#############################################################################################################
//#############################################################################################################
always_ff @ (posedge clk) state <= next_state;


always_comb begin : next_state_logic
	case (state)
		READY: begin
			if ( (mem_read ^ mem_write ) && !(|Hit) ) begin
				if (Dirty[recipient] == 1) begin
					next_state = WRITE_BACK;
				end
				else begin
					next_state = GET_MEM;
				end
			end
			else begin
				next_state = READY;
			end
		end
		
		WRITE_BACK:begin
			if (pmem_resp == 1)
				next_state = GET_MEM;
			else
				next_state = WRITE_BACK;
		end
		GET_MEM:begin
			if (pmem_resp == 1)
				next_state = GET_MEM_2;
			else
				next_state = GET_MEM;

		end	
		GET_MEM_2: begin
			next_state = READY;
		end	
	endcase

end : next_state_logic

//#############################################################################################################
//#############################################################################################################
//#############################################################################################################
//############################                                                 ################################
//############################                                                 ################################
//############################               State Control Signals             ################################
//############################                                                 ################################
//############################                                                 ################################
//############################                                                 ################################
//#############################################################################################################
//#############################################################################################################
//#############################################################################################################

always_comb begin : state_control_signals
	mem_resp = 1'b0;
	pmem_read = 1'b0;
	pmem_write = 1'b0;
	valid_data = 1'b0;
	dirty_data = 1'b0;
	write = 8'h00;
	pmem_wdatamux_sel = 3'h0;
	datainmux_sel = 8'h00;
    basemux_sel = recipient;
    pmem_address_mux_sel = 1'b0;
   	case (state) 
		READY:	begin
			//if there's a hit and mem_write is high, write to
			//the correct way and respond
			//if there is a hit and mem_write is not high, respond
			if (|Hit) begin
				if (mem_write == 1'b1) begin
					//write the data
					dirty_data = 1'b1;
					write[inter_hit] = 1'b1;
					valid_data = 1'b1;

					//respond to cpu and set LRU
					mem_resp = 1'b1;
				end
				if (mem_read == 1'b1) begin
					//respond to cpu and set the LRU, as read logic is automatic
					mem_resp = 1'b1;
				end
			end
		end	

		WRITE_BACK: begin
				pmem_wdatamux_sel = recipient;
				pmem_write = 1'b1;
		        pmem_address_mux_sel = 1'b1;
		end

		GET_MEM: begin
			pmem_read = 1'b1;
		end

		GET_MEM_2:	begin
			datainmux_sel[recipient] = 1'b1;
			write[recipient] = 1'b1;
			valid_data = 1'b1;
		end	

		default:	;

	endcase

end : state_control_signals

endmodule : L2cache_control
