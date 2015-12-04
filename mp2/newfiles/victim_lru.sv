//####################################################################
//####################################################################
//####################################################################
//################ Created by Nick Moore  ############################
//################  for MP3 in ECE 411 at ############################
//################ University of Illinois ############################
//################ Fall 2015              ############################
//####################################################################
//####################################################################
//####################################################################
//#                                                                  #
//#   LRU_unit.sv                                                    #
//#     Implements the LRU_unit module for the LC3B cache            #
//#     calculates and stores the least recently used way for a line #
//#                                                                  #
//####################################################################

import lc3b_types::*;
import cache_types::*;

module victim_lru (
				   input 				   mem_resp, //acts as write for the flip flop, since we update LRU when we actually use the data
				   input [3:0] 			   hit,
				   input 				      clk,
				   output logic [1:0] 	   out,
				   output logic [3:0][1:0] internals
);

   logic [2:0]			current;
   logic [2:0] 			last_place;
   logic [3:0] [1:0] 	data  /*synthesis ramstyle = "logic" */;
   logic [2:0] 			greatest_valid_place;
			
   
always_comb begin : current_assignment
   case(hit)
	 4'h1: current = 3'h0;
	 4'h2: current = 3'h1;
	 4'h4: current = 3'h2;
	 4'h8: current = 3'h3;
	 default: current = 3'h4;
   endcase // case (hit)
end : current_assignment

assign internals = data;
   
always_comb begin : last_place_assignment
   if(current[2]!=1'b1)begin
	  if (data[0][1:0] == current) last_place = 3'h0;
	  else if (data[1][1:0] == current[1:0]) last_place = 3'h1;
	  else if (data[2][1:0] == current[1:0]) last_place = 3'h2;
	  else last_place = 3'h3;
   end
   else last_place = 3'h4;
end : last_place_assignment


assign out = data[3][1:0];

/*
always_comb begin : greatest_valid_place_assignment
   if (data[3] != 3'bzzz)
	 greatest_valid_place = 3'h3;
   else if (data[2] != 3'bzzz)
	 greatest_valid_place = 3'h2;	 
   else if (data[1] != 3'bzzz)
	 greatest_valid_place = 3'h1;	 
   else if (data[0] != 3'bzzz)
	 greatest_valid_place = 3'h0;
   else
	 greatest_valid_place = 3'h4;
end : greatest_valid_place_assignment

always_comb begin : output_select
   if (greatest_valid_place[2] == 1'b1)
	 out = 2'bzz;
   else
	 out = data[greatest_valid_place[1:0]];
end : output_select
*/   

/* Initialize array */
initial begin
   for (int i = 0; i < 3; i++) begin
	  data[i] = 2'bzz;
   end
end


always_ff @(posedge clk) begin
    if (mem_resp == 1) begin
	   if (last_place == 3'h4) begin
		  data <= data;
	   end
	   else begin                          //last_place is valid,so we need to move it to the top and move the ones more recent down
		  for (int i = 3; i > 0; i--)begin
			 if (i > last_place) 
			   continue;
			 data[i] <= data[i-1];
		  end
		  data[0] <= current[1:0];
	   end
	end // if (mem_resp == 1)
   	   
	else begin
	   data <= data;
	end // else: !if(mem_resp == 1)
end // always_ff @
   


   
endmodule // LRU_unit
