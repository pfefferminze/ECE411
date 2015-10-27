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
//#     takes cache line as input                                    #
//#                                                                  #
//#     outputs cache line                                           #
//####################################################################
//The data arrays can only interface with other components using the following signals: an index (address) bus, two data buses (datain and dataout), clk, and write signals





rt lc3b_types::*;

module array #(parameter width = 128)
(
    input clk,
    input write,
    input cache_index index,
    input [width-1:0] datain,
    output logic [width-1:0] dataout
);

logic [width-1:0] data [7:0];
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
