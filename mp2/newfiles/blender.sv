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
//#   blender.sv                                                     #
//#     Implements the blender module for the LC3B cache             #
//#     combinational logic unit for replacing one word or byte in   #
//#     a cache line with the data in mem_wdata                      #
//#     takes mem_byte_enable as an input to select which byte       #
//#     takes offset as input to select which word to modify         #
//#     takes cache line as input to modify the selected word        #
//#     takes mem_wdata as input as data to modify word with         #
//#                                                                  #
//#     outputs modified cache line                                  #
//####################################################################

import lc3b_types::*;

module blender
(
	input cache_line in_line,
	input cache_offset offset,
	input [1:0] mem_byte_enable,
	input lc3b_word data,
	output cache_line out_line
);

logic [7:0] high_byte, low_byte;	//logic separating the bytes of mem_wdata
cache_offset  wordselect_sel;
lc3b_word wordselect_out;
lc3b_word mixer_word[3:0];
lc3b_word mixer_out;
logic [1:0] mixer_sel;
logic [7:0] decoder_out;

assign mixer_sel = mem_byte_enable;
assign high_byte = data[15:8];
assign low_byte = data[7:0];
assign wordselect_sel = offset;
assign mixer_word[0] = wordselect_out;
assign mixer_word[1] = {wordselect_out[15:8],low_byte};
assign mixer_word[2] = {high_byte,wordselect_out[7:0]};
assign mixer_word[3] = {high_byte,low_byte};

//#############################################################################################################
//#############################################################################################################
//#############################################################################################################
//############################                                                 ################################
//############################                                                 ################################
//############################                     Blender                     ################################
//############################                (made from multiplexors)         ################################
//############################                                                 ################################
//############################                                                 ################################
//#############################################################################################################
//#############################################################################################################
//#############################################################################################################

//select the word to modify from data_out
mux8 wordselect
(
	.a(in_line[0]),
	.b(in_line[1]),
	.c(in_line[2]),
	.d(in_line[3]),
	.e(in_line[4]),
	.f(in_line[5]),
	.g(in_line[6]),
	.h(in_line[7]),
	.sel(wordselect_sel),
	.i(wordselect_out)
);

//select the mix of the word to use from 0 replacement, low_byte replacement,
//high_byte replacement, and total word replacement

mux4 mixer
(
	.a(mixer_word[0]),
	.b(mixer_word[1]),
	.c(mixer_word[2]),
	.d(mixer_word[3]),
	.f(mixer_out),
	.sel(mixer_sel)
);


//Decode the offset to actually mix the modified word back in
//takes 8 2 way mixers and 1 decoder for each associativity way.  
//Inputs for the mixers are the unmodified word and the modified word.  
//The decoder decodes the offset and selects the correct word to mix 
//back in.  All the other muxes default to the unmodified cacheline.  

decoder decoder
(
	.wordsel(offset),
	.control_byte(decoder_out)
);

mux2 rebuild0
(
	.a(in_line[0]),
	.b(mixer_out),
	.sel(decoder_out[0]),
	.f(out_line[0])
);

mux2 rebuild1
(
	.a(in_line[1]),
	.b(mixer_out),
	.sel(decoder_out[1]),
	.f(out_line[1])
);

mux2 rebuild2
(
	.a(in_line[2]),
	.b(mixer_out),
	.sel(decoder_out[2]),
	.f(out_line[2])
);

mux2 rebuild3
(
	.a(in_line[3]),
	.b(mixer_out),
	.sel(decoder_out[3]),
	.f(out_line[3])
);

mux2 rebuild4
(
	.a(in_line[4]),
	.b(mixer_out),
	.sel(decoder_out[4]),
	.f(out_line[4])
);

mux2 rebuild5
(
	.a(in_line[5]),
	.b(mixer_out),
	.sel(decoder_out[5]),
	.f(out_line[5])
);

mux2 rebuild6
(
	.a(in_line[6]),
	.b(mixer_out),
	.sel(decoder_out[6]),
	.f(out_line[6])
);

mux2 rebuild7
(
	.a(in_line[7]),
	.b(mixer_out),
	.sel(decoder_out[7]),
	.f(out_line[7])
);

endmodule : blender
