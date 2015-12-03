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
//#   victim_control.sv                                              #
//#     Implements the control module for the LC3B victim_cache      #
//#     controls the datapath module for the LC3B L2cache            #
//#     instantiate both in L2cache.sv and connect the inputs/outputs#
//#                                                                  #
//####################################################################

import cache_types::*;
import lc3b_types::*;

module victim_control
(
	//signals between cache and cpu datapath
	input 			   mem_read,
	input 			   mem_write,
	output logic 	   mem_resp,

	//signals between cache and physical memory
	output logic 	   pmem_read,
	output logic 	   pmem_write,
	input 			   pmem_resp,

	//signals between cache datapath and cache controller
	input 			   clk,
	output logic 	   valid_data,
	output logic 	   dirty_data,
	output logic [7:0] write,
	output logic [2:0] pmem_wdatamux_sel, //mux selects
	output logic [7:0] datainmux_sel, //mux selects
    output logic 	   pmem_address_mux_sel,
    output logic [2:0] basemux_sel,
	output logic [2:0] dataoutmux_sel, //select line from dataoutmux -- controlled by control unit
//	input cache_tag tag,
	input [7:0] 	   Valid,
	input [7:0] 	   Hit, //logic determining if there was a hit
	input [7:0] 	   Dirty
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

   enum 			   {READY, WRITE_BACK, WRITE_BACK_2, FINISH_WRITE_BACK,GET_MEM,GET_MEM_2} state, next_state;
   logic [1:0] 		   lru_out;
   logic [3:0] 		   valid_and_dirty;
   logic [1:0] 		   inter_hit;     //used for converting the Hit array to an index in assigning write[]
   logic [1:0] 		   recipient;	//the associativity way to write to in the event of a cache miss 
   logic [3:0] [1:0]   internals;  //all of the internal values in the LRU unit, so we can check priorities of write-back
   logic 			   lru_is_populated;
   logic [1:0] 		   next_to_write;
   logic 			   isDirty;
   logic 			   write_back_to_read_flag;
   logic               write_back_state_flag;        /*when HIGH tells control that it came from WRITE_BACK, LOW means WRITE_BACK_2*/
                                                     /*for use with flip flop so control can flip it on and off*/
 			   
   
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

assign valid_and_dirty = Valid & Dirty;         /*signals which ways are both valid and waiting to write back*/
assign isDirty = (lru_is_populated)? (|valid_and_dirty):1'b0;              /*signals if there is a way yet to be written back that needs it*/

    
/*signal to tell control which index to clear the dirty bit for*/
   /*this might be better to put as much as possible in the state machine.  I'm not sure*/
always_ff @ (posedge clk) begin : assign_write_back_state_flag
   if (state == WRITE_BACK)
	 write_back_state_flag = 1'b1;
   else if (state == FINISH_WRITE_BACK)
	 write_back_state_flag = 1'b0;
   else
	 write_back_state_flag = 1'b0;	 
end : assign_write_back_state_flag

   
/*signal to ensure we don't write anything back when a read request is imminent*/
always_ff @(posedge clk)begin : assign_write_back_to_read_flag 

   if (mem_write == 1'b1) /*L2_cache is evicting data so we can expect a read request, therefore we should not go to WRITE_BACK_2*/
	 write_back_to_read_flag <= 1'b1;
   else if (mem_read  && (|Hit)) /*we have a mem_read hit and we can reset write_back_to_read_flag */
	 write_back_to_read_flag <= 1'b0;
   else if (state == GET_MEM) /*we have successfully changed to the correct state so we can reset write_back_to_read_flag*/
	 write_back_to_read_flag <= 1'b0;
   else 
	 write_back_to_read_flag <= write_back_to_read_flag;

end : assign_write_back_to_read_flag

/*assigning the next to write back based on LRU priority, recorded in internals*/
always_ff@(posedge clk) begin : assigning_next_to_write
   if(lru_is_populated && next_state == WRITE_BACK_2 && state != next_state)begin /*going to WRITE_BACK_2 when lru is full*/
	  if(valid_and_dirty[internals[3]]==1'b1)begin
		 next_to_write <= 2'b11;
	  end
	  else if(valid_and_dirty[internals[2]]==1'b1)begin
		 next_to_write <= 2'b10;
	  end
	  if(valid_and_dirty[internals[1]]==1'b1)begin
		 next_to_write <= 2'b01;
	  end
	  else/* if(valid_and_dirty[internals[0]]==1'b1)*/begin
		 next_to_write <= 2'b00;
	  end
   end // if (lru_is_populated)
   else if(next_state == WRITE_BACK_2 && next_state != state)begin /*going to WRITE_BACK_2 when lru is not full*/
	  case(recipient)
		2'b00: next_to_write <=2'b00;
		2'b01: next_to_write <=2'b00;
		2'b10: next_to_write <=2'b01;
		2'b11: next_to_write <=2'b10;
		default: next_to_write <=2'b00;
	  endcase // case (recipient)
   end
   else begin                                                     /*not going to WRITE_BACK_2 or already in WRITE_BACK_2*/
	  next_to_write <= next_to_write;
   end
end : assigning_next_to_write

/*converting hit array to unsigned int format for use as array index or mux select signal*/   
always_comb begin : inter_hit_assignment
   case(Hit)
	 4'h1: inter_hit = 3'h0;
	 4'h2: inter_hit = 3'h1;
	 4'h4: inter_hit = 3'h2;
	 4'h8: inter_hit = 3'h3;
	 default: inter_hit = 3'h0;
   endcase // case (hit)
end : inter_hit_assignment
      

/*determine the recipient of a write request from the L2_cache based on validity first, and LRU once all ways are populated*/
always_comb begin : recipient_determination
   if (Valid[0] == 1'b0)begin
	  recipient = 2'h0;
	  lru_is_populated = 1'b0;
   end
   else if (Valid[1] == 1'b0)begin
	  recipient = 2'h1;
	  lru_is_populated = 1'b0;
   end
   else if (Valid[2] == 1'b0)begin
	  recipient = 2'h2;
	  lru_is_populated = 1'b0;
   end
   else if (Valid[3] == 1'b0)begin
	  recipient = 2'h3;
	  lru_is_populated = 1'b0;	  
   end
   else begin
	  recipient = lru_out;
	  lru_is_populated = 1'b1;
   end
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

victim_lru lru
(
    .clk(clk),
    .hit(Hit),
    .mem_resp(mem_resp),
    .out(lru_out),
    .internals(internals)
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

/* 
******* CHANGES NEEDING TO BE MADE*******
- reading needs to be read-through policy
- writing back needs to be on a round-robin-ish policy beginning from least recently used and going towards most recently used, which is not immediate
-      writes happen when reading does not happen,
-      writes only write back valid data
-      dirty does not happen because any time we read from the victim cache we just send it back to L2 cache
-          so we use the dirty array in the ways to keep track of if it's been written back
-           we mark dirty when we send it to the victim cache, and clear it when it's been written back, so if we need to evict we write back if dirty is 
           marked.

-  if we need to read from a way in the victim cache, we can take it out of the write-back loop, because it is being used again.  This means just clear the dirty bit.
 states for state machine
 READY -> all ways to be written have been written, have no reads or writes to perform, or reads and writes are hits to the ways
 GET_MEM ->  read through from pmem to L2 cache
 GET_MEM_2 -> finish the read process.  probably not needed, but not necessary to change.  The extra cycle might be useful in the future, maybe.  IDK
 WRITE_BACK -> writing back specifically the least recently used way because we are evicting it for new data.
 WRITE_BACK_2 -> writing back one of the dirty ways because we think we have free time to do it.  
 FINISH_WRITE_BACK -> clearing dirty bits from writing back gets its own state at the end so we don't corrupt our data during write backs
 
 
- We can expect that every time we get a write request in the victim cache, we will always follow it with a read request, otherwise there wouldn't be a reason for the L2 to write anything back.  We want to avoid going to the WRITE_BACK_2 state before we get that read request when that occurs.  
 
   */

always_comb begin : next_state_logic
   case (state)
	 READY: begin
		if ( mem_read  && !(|Hit) ) begin       /* theres a read request and the data is not in any of the ways*/
		   next_state = GET_MEM;
		end
		else if (write_back_to_read_flag)begin /*we've finished a write back and are waiting for the imminent read request*/
		   next_state = READY;
		end
		else if(mem_write && Dirty[recipient] == 1) begin  /*there's a write request and the least recently used way hasn't been written back yet*/
		   next_state = WRITE_BACK;
		end
		else if (isDirty) begin                  /* there is no read/write request but we have dirty data in the victim cache that needs written*/
		   next_state = WRITE_BACK_2;
		end
		else begin                               /*there is no read write request and there is no dirty data in any of the ways that needs written*/
		   next_state = READY;
		end
	 end // case: READY
	 WRITE_BACK: begin                           /*there is a write request and we have to make space*/
		if (pmem_resp == 1)begin
		  next_state = FINISH_WRITE_BACK;
		end
		else
		  next_state = WRITE_BACK;
	 end
	 WRITE_BACK_2:begin                         /*there is no read or write request, but we can make more space so we are doing so*/
		if (pmem_resp == 1)begin                /*in this case we should be able to handle read requests where we have the data in the ways already*/
		  next_state = FINISH_WRITE_BACK;
		end
		else
		  next_state = WRITE_BACK_2;
	 end
	 FINISH_WRITE_BACK:begin                    /*state for writing a zero bit into the dirty array for the way just written, so we know we can use it*/
		next_state = READY;		                /*we use this state to make sure that we don't accidentally write to the way while writing it back*/
	 end
	 GET_MEM:begin                              /*we are requesting data from the physical memory to forward it on to the L2 cache*/
		if (pmem_resp == 1)
		  next_state = GET_MEM_2;
		else
		  next_state = GET_MEM;
	 end	
	 GET_MEM_2: begin                          /*legacy from development of other caches, not sure we need it but better safe than sorry*/
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
	write = 4'h00;
	pmem_wdatamux_sel = 3'h0;
	datainmux_sel = 4'h0; //a high value means when we write to a specified way, we are not changing the data, just the valid, dirty, etc
    dataoutmux_sel = {1'b0,inter_hit}; //select line from dataoutmux -- controlled by control unit
    basemux_sel = recipient;
    pmem_address_mux_sel = 1'b0;
   	case (state) 
	  READY:	begin
		 //if there's a hit and mem_write is high, write to
		 //the correct way and respond
		 //if there is a hit and mem_write is not high, respond
		 if ((|Hit) && mem_read == 1'b1) begin                               /*if we have a read request and a hit*/
			//clear the dirty bit, since we won't need to write back something that's being used by L2_cache
			write[inter_hit] = 1'b1; //dirty_data is 0 by default
			datainmux_sel[inter_hit] = 1'b1; //we're not writing from mem_rdata
			valid_data = 1'b1;
			
			//respond to cpu and set the LRU, as read logic is automatic
			mem_resp = 1'b1;
		 end
		 if (mem_write == 1'b1 && Dirty[recipient] == 1'b0) begin   /* or if we have a write request and there's room*/
			//write the data
			dirty_data = 1'b1;
			write[recipient] = 1'b1;
			valid_data = 1'b1;

			//respond to cpu and set LRU
			mem_resp = 1'b1;
		 end
	  end	
	  
	  WRITE_BACK: begin
		 pmem_wdatamux_sel = recipient;
		 pmem_write = 1'b1;
		 pmem_address_mux_sel = 1'b1;
	  end

	  WRITE_BACK_2: begin                   /*write back based on 'next_to_write' instead of recipient*/
		 pmem_wdatamux_sel = next_to_write;
		 pmem_write = 1'b1;
		 pmem_address_mux_sel = 1'b1;
		 /*handle read requests in the case where the requested data is already in the victim cache*/
		 if ((|Hit) && mem_read == 1'b1) begin
			//respond to L2_cache and set the LRU, as read logic is automatic
			mem_resp = 1'b1;
		 end
		 /*handle write requests in the case where there is space in the victim cache to write to*/
		 if (mem_write == 1'b1 && Dirty[recipient] == 1'b0) begin  /* write the data if we have room to write the data, or go to WRITE_BACK*/
			//write the data
			dirty_data = 1'b1;
			write[recipient] = 1'b1;
			valid_data = 1'b1;
			
			//respond to cpu and set LRU
			mem_resp = 1'b1;
		 end
	  end
	  FINISH_WRITE_BACK:begin                    /*state for writing a zero bit into the dirty array for the way just written, so we know we can use it*/
		                 		                /*we use this state to make sure that we don't accidentally write to the way while writing it back*/
		 if(write_back_state_flag)begin//came from WRITE_BACK, so use recipient
			write[recipient] = 1'b1;
			dirty_data = 1'b0;
			valid_data = 1'b1;
			datainmux_sel[recipient] = 1'b1; //we're not writing from mem_rdata
		 end
		 else begin //came from WRITE_BACK_2, so use next_to_write
			write[next_to_write] = 1'b1;
			dirty_data = 1'b0;
			valid_data = 1'b1;
			datainmux_sel[next_to_write] = 1'b1; //we're not writing from mem_rdata
		 end
	  end

	  GET_MEM: begin
		 pmem_read = 1'b1;
		 mem_resp = pmem_resp;
		 dataoutmux_sel = 3'b100;
	  end

	  GET_MEM_2:	begin
		 mem_resp = pmem_resp;
		 dataoutmux_sel = 3'b100;		   /*select the dataoutmux line corresponding to bypassing the ways and pushing pmem_rdata through to L2 cache*/
	  end	

	  default:	;

	endcase

end : state_control_signals

endmodule : victim_control
