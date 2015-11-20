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

module LRU_unit 
(
     input 				mem_resp,             //acts as write for the flip flop, since we update LRU when we actually use the data
     input [7:0]        hit,
     input 				cache_index index,
	 input 				clk,
	 output logic [2:0] out
);

   logic [3:0]			current;
   logic [3:0] 			last_place;
   logic [7:0] [2:0] 	data [7:0] /*synthesis ramstyle = "logic" */;

always_comb begin : current_assignment
   case(hit)
	 8'h01: current = 4'h0;
	 8'h02: current = 4'h1;
	 8'h04: current = 4'h2;
	 8'h08: current = 4'h3;
	 8'h10: current = 4'h4;
	 8'h20: current = 4'h5;
	 8'h40: current = 4'h6;
	 8'h80: current = 4'h7;
	 default: current = 4'h8;
   endcase // case (hit)
end : current_assignment

always_comb begin : last_place_assignment
   if(current[3]!=1'b1)begin
	  if (data[index][0] == current) last_place = 4'h0;
	  else if (data[index][1] == current[2:0]) last_place = 4'h1;
	  else if (data[index][2] == current[2:0]) last_place = 4'h2;
	  else if (data[index][3] == current[2:0]) last_place = 4'h3;
	  else if (data[index][4] == current[2:0]) last_place = 4'h4;
	  else if (data[index][5] == current[2:0]) last_place = 4'h5;
	  else if (data[index][6] == current[2:0]) last_place = 4'h6;
	  else last_place = 4'h7;
   end
   else last_place = 4'h8;
	  
end : last_place_assignment
   
   

/* Initialize array */
initial
begin
	for (int i = 0; i < 7; i++) begin
	   for(int j = 0; j < 7;j++)begin
	        data[i][j] = 3'bxxx;
	   end
    end
end

always_ff @(posedge clk) begin
    if (mem_resp == 1) begin
//	   if (last_place == 4'h8 && data[index][7] == 3'bxxx ) begin  //current is not actually in the history => LRU_unit is not full for this index, so move everything down
//		  for (int i = 7; i > 0; i--)begin
//			 data[index][i] <= data[index][i-1];
//		  end
//		  data[index][0] <= current[2:0];
//	   end
/*	   else*/ if (last_place == 4'h8) begin
		  data = data;
	   end
	   else begin                          //last_place is valid,so we need to move it to the top and move the ones more recent down
		  for (int i = 7; i > 0; i--)begin
			 if (i > last_place) 
			   continue;
			 data[index][i] <= data[index][i-1];
		  end
		  data[index][0] = current[2:0];
	   end
	end // if (mem_resp == 1)
   	   
	else begin
	   data = data;
	end // else: !if(mem_resp == 1)
end // always_ff @
   

assign out = data[index][7][2:0];
   
endmodule // LRU_unit
