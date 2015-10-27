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
//#   assoc_set.sv                                                   #
//#     Implements a full associativity block set for the LC3B cache #
//#     very similar to a register file, but for the cache lines     #
//#     a cache line with the data in mem_wdata                      #
//#     takes mem_byte_enable as an input to select which byte       #
//#     takes offset as input to select which word to modify         #
//#     takes cache line as input to modify the selected word        #
//#     takes mem_wdata as input as data to modify word with         #
//#                                                                  #
//#     outputs modified cache line                                  #
//####################################################################
//The data arrays can only interface with other components using the following signals: an index (address) bus, two data buses (datain and dataout), clk, and write signals


import lc3b_types::*;

module array #(parameter width = 128)
(
    input clk,
    input write,
    input cache_index index,
    input [width-1:0] datain,
    output logic [width-1:0] dataout
);

logic [width-1:0] data [7:0] /*synthesis ramstyle = "logic" */;
/* Initialize array */
initial
begin
	for (int i = 0; i < $size(data); i++) begin
	        data[i] = 1'b0;
        end
end

always_ff @(posedge clk) begin
    if (write == 1) begin
	data[index] = datain;
    end
end

assign dataout = data[index];
											    
endmodule : array
