//####################################################################
//####################################################################
//####################################################################
//################ Created by Nick Moore     #########################
//################  for group Random2's mp3  #########################
//################  in ECE 411 at            #########################
//################ University of Illinois    #########################
//################ Fall 2015                 #########################
//####################################################################
//####################################################################
//####################################################################
//#                                                                  #
//#   cache_way.sv                                                   #
//#     Implements a single way for a set associative cache          #
//#     multiple ways can be set up for a larger associativity       #
//#     instantiates all data arrays, and modules needed for a       #
//#     complete way.  Control the way with a separate control mod   #
//#                                                                  #
//####################################################################

import cache_types::*;
import lc3b_types::*;

module cache_way (
				  //signals between cache and cpu datapath
				  input 	   lc3b_word mem_wdata,
				  input [1:0]  mem_byte_enable,
				  
				  //signals between cache and physical memory
				  input 	   cache_line line_in,
				  output 	   cache_line line_out,
				  output 	   pmem_address_base pmem_base,

				  //signals between cache datapath and cache controller
				  input 	   clk,
				  input 	   valid_data,
				  input 	   dirty_data,
				  input 	   write,
				  input 	   datainmux_sel, //selection signal for the mux that feeds the cache line array
				  output logic isValid,
				  output logic isHit,
				  output logic isDirty,

				  //signals from the parent module
				  input cache_index index,				//set select stripped off of mem_address
				  input cache_offset offset,				//word select stripped off of mem_address
				  input cache_tag tag					//set tag stripped off of mem_address
				  );

//#############################################################################################################
//#############################################################################################################
//#############################################################################################################
//############################                                                 ################################
//############################                                                 ################################
//############################                 Variable Declarations           ################################
//############################                                                 ################################
//############################                                                 ################################
//############################                                                 ################################
//#############################################################################################################
//#############################################################################################################
//#############################################################################################################

   cache_tag tag_out;
   cache_line blender_out;		//outputs from the blenders to the datainmuxes				  
   cache_line datainmux_out;
   cache_line way_out;
   logic tagcompare_out;
   logic hit,valid;
//#############################################################################################################
//#############################################################################################################
//#############################################################################################################
//############################                                                 ################################
//############################                                                 ################################
//############################               Variable Definitions              ################################
//############################                                                 ################################
//############################                                                 ################################
//############################                                                 ################################
//#############################################################################################################
//#############################################################################################################
//#############################################################################################################

   assign pmem_base = {tag_out,index};
	assign isValid = valid;
   assign isHit = valid & tagcompare_out;
   assign line_out = way_out;
   
//#############################################################################################################
//#############################################################################################################
//#############################################################################################################
//############################                                                 ################################
//############################                                                 ################################
//############################              Module Instantiations              ################################
//############################                                                 ################################
//############################                                                 ################################
//############################                                                 ################################
//#############################################################################################################
//#############################################################################################################
//#############################################################################################################


array way_unit
(
    .clk(clk),
    .write(write),
    .index(index),
    .datain(datainmux_out),
    .dataout(way_out)
);


array #(.width(9)) tag_unit
(
    .clk(clk),
    .write(write),
    .index(index),
    .datain(tag),
    .dataout(tag_out)
);


compare compare_unit
(
	.tag_a(tag_out),
	.tag_b(tag),
	.isEqual(tagcompare_out)
);

   
array #(.width(1)) valid_unit
(
    .clk(clk),
    .write(write),
    .index(index),
    .datain(valid_data),
    .dataout(valid)
);



array #(.width(1)) dirty_unit
(
    .clk(clk),
    .write(write),
    .index(index),
    .datain(dirty_data),
    .dataout(isDirty)
);
  

blender blender_unit
(
	.in_line(way_out),
	.offset(offset),
	.mem_byte_enable(mem_byte_enable),
	.data(mem_wdata),
	.out_line(blender_out)
);

mux2 #(.width(128)) datainmux
(
	.a(blender_out),
	.b(line_in),
	.sel(datainmux_sel),
	.f(datainmux_out)
);

endmodule // cache_way

