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
//#   tag_array.sv                                                   #
//#     Implements a tag array for checking tags of cache lines      #
//#                                                                  #
//#                                                                  #
//#     takes write as a 1 bit input to set the tag for index        #
//#     takes index as input to select which tag to set              #
//#     takes tag as input to be stored                              #
//#                                                                  #
//#     outputs tag selected by index                                #
//####################################################################
//input:	typedef logic  [9:0] cache_tag;

import lc3b_types::*;

module tag_array
(
	input cache_tag tag_in,
	output cache_tag tag_out,
	input cache_index line_sel,
	input clk,
	input write
);

cache_tag data [7:0];

initial begin
	for (i = 0; i < 8; i++)
		data[i] = 10'h0;
end

always_ff @(posedge clk) begin
	if (write == 1)	data[line_sel] <= tag_in;
end

assign tag_out = data[line_sel];

endmodule : tag_array
