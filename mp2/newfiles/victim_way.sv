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
//#   victim_way.sv                                                  #
//#     Implements a single way for a fully associative victim cache #
//#     Using 4 ways for the victim cache                            #
//#     instantiates all data arrays, and modules needed for a       #
//#     complete way.  Control the way with a separate control mod   #
//#                                                                  #
//#     victim_way has a new mux not present in regular way          #
//#     as line_in has been rerouted in datapath to keep the         #
//#     data in a way unchanged when we write a way with datainmux   #
//#     select line being HIGH, taginmux uses the same select signal #
//#     to ensure we do not change the tag in the array when we do   #
//#     this.  The reason we would want to keep data unchanged for a #
//#     write is to be able to clear the dirty bits. This makes      #
//#     that easy.                                                   #
//####################################################################

import cache_types::*;
import lc3b_types::*;

module victim_way (
				  //signals between cache and cpu datapath
				  input 	   cache_line mem_wdata,
				  
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
				  input cache_offset offset,				//word select stripped off of mem_address
				  input victim_tag tag					//set tag stripped off of mem_address
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

   victim_tag tag_out;
   victim_tag taginmux_out;
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

   assign pmem_base = tag_out;
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


victim_array way_unit
(
    .clk(clk),
    .write(write),
    .datain(datainmux_out),
    .dataout(way_out)
);


victim_array #(.width(12)) tag_unit
(
    .clk(clk),
    .write(write),
    .datain(taginmux_out),
    .dataout(tag_out)
);


victim_compare compare_unit
(
	.tag_a(tag_out),
	.tag_b(tag),
	.isEqual(tagcompare_out)
);

   
victim_array #(.width(1)) valid_unit
(
    .clk(clk),
    .write(write),
    .datain(valid_data),
    .dataout(valid)
);

victim_array #(.width(1)) dirty_unit
(
    .clk(clk),
    .write(write),
    .datain(dirty_data),
    .dataout(isDirty)
);
  
mux2 #(.width(128)) datainmux
(
	.a(mem_wdata),
	.b(line_in),
	.sel(datainmux_sel),
	.f(datainmux_out)
);

mux2 #(.width(12)) taginmux
(
	.a(tag),
	.b(tag_out),
	.sel(datainmux_sel),
	.f(taginmux_out)
);

endmodule // cache_way

