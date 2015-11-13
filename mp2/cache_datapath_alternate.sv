//####################################################################
//####################################################################
//####################################################################
//################ Created by Nick Moore  ############################
//################  for group Random2 for ############################
//################  MP3 in ECE 411 at     ############################
//################ University of Illinois ############################
//################ Fall 2015              ############################
//####################################################################
//####################################################################
//####################################################################
//#                                                                  #
//#   cache_datapath_alternate.sv                                    #
//#     Implements the datapath module for the LC3B cache            #
//#     controlled by the control module for the LC3B cache          #
//#     instantiate both in cache.sv and connect the inputs/outputs  #
//#   alternate version is developed to clean up the cache code      #
//#     and make it easier to build larger caches in other projects  #
//####################################################################

import cache_types::*;


module cache_datapath (
					   //signals between cache and cpu datapath
					   input 			  lc3b_word mem_address,
					   input 			  lc3b_word mem_wdata,
					   input [1:0] 		  mem_byte_enable,
					   output 			  lc3b_word mem_rdata,
					   output 			  lc3b_word pmem_address,

					   //signals between cache and physical memory
					   input 			  cache_line pmem_rdata,
					   output 			  cache_line pmem_wdata,

					   //signals between cache datapath and cache controller
					   input 			  clk,
					   input 			  valid_data,
					   input 			  dirty_data,
					   input [1:0] 		  write,
					   input 			  pmem_wdatamux_sel, //mux selects
					   input 			  basemux_sel,
					   input 			  pmem_address_mux_sel,
					   output logic [1:0] Valid,
					   output logic [1:0] Hit, //logic determining if there was a hit
					   output logic [1:0] Dirty,
//					   output 			  cache_index index_out,
//					   output 			  cache_tag tag_out,
//					   output 			  cache_tag [1:0] tags,
//					   output 			  cache_offset offset_out
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

cache_index index;				//set select stripped off of mem_address
cache_offset offset;				//word select stripped off of mem_address
cache_tag tag;					//set tag stripped off of mem_address
cache_line dataoutmux_out;			//connects dataoutmux to wordselectmux
cache_line [1:0] line_out;
logic [1:0] isHit, isValid, isDirty;
logic dataoutmux_sel;			//select line from dataoutmux -- controlled by combinational logic
pmem_address_base [1:0] pmem_base;
pmem_address_base basemux_out;     //msb array to assign pmem_address in the case of a writeback
lc3b_word wb_address;
   
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

assign wb_address = {basemux_out, 4'h0};
assign index = mem_address[6:4];
assign index_out = index;
assign offset = mem_address[3:1];
assign tag = mem_address[15:7];
assign Hit = isHit;
assign Valid = isValid;
assign Dirty = isDirty;
assign dataoutmux_sel = isHit[1];
      
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

/*ways
*/ 
cache_way way0    (
				   //signals between cache and cpu datapath
				   .mem_wdata(mem_wdata),
				   .mem_byte_enable(mem_byte_enable),
				  
				  //signals between cache and physical memory
				   .line_in(pmem_rdata),
 				   .line_out(line_out[0]),
				   .pmem_base(pmem_base[0]),

				  //signals between cache datapath and cache controller
				   .clk(clk),
				   .valid_data(valid_data),
				   .dirty_data(dirty_data),
				   .write(write[0]),
				   .datainmuxsel(datainmux_sel), //selection signal for the mux that feeds the cache line array
				   .isValid(isValid[0]),
				   .isHit(isHit[0]),
				   .isDirty(isDirty[0])

				  //signals from the parent module
				   .tag(tag),
				   .offset(offset),
				   .index(index)
 				   );

cache_way way1    (
				   //signals between cache and cpu datapath
				   .mem_wdata(mem_wdata),
				   .mem_byte_enable(mem_byte_enable),
				  
				  //signals between cache and physical memory
				   .line_in(pmem_rdata),
				   .line_out(line_out[1]),
				   .pmem_base(pmem_base[1]),

				  //signals between cache datapath and cache controller
				   .clk(clk),
				   .valid_data(valid_data),
				   .dirty_data(dirty_data),
				   .write(write[1]),
				   .datainmuxsel(datainmux_sel), //selection signal for the mux that feeds the cache line array
				   .isValid(isValid[1]),
				   .isHit(isHit[1]),
				   .isDirty(isDirty[1])

				  //signals from the parent module
				   .tag(tag),
				   .offset(offset),
				   .index(index)
				   );


mux2 #(.width(16)) pmem_address_mux
(
	.a(mem_address),
	.b(wb_address),
	.sel(pmem_address_mux_sel),
	.f(pmem_address)
);
   
mux2 #(.width(12)) basemux
(
	.a(pmem_base[0]),
	.b(pmem_base[1]),
	.sel(basemux_sel),
	.f(basemux_out)
);

   
mux2 #(.width(128)) dataoutmux
(
	.a(line_out[0]),
	.b(line_out[1]),
	.sel(dataoutmux_sel),
	.f(dataoutmux_out)
);

mux8  wordselectmux
(
	.a(dataoutmux_out[0]),
	.b(dataoutmux_out[1]),
	.c(dataoutmux_out[2]),
	.d(dataoutmux_out[3]),
	.e(dataoutmux_out[4]),
	.f(dataoutmux_out[5]),
	.g(dataoutmux_out[6]),
	.h(dataoutmux_out[7]),
	.sel(offset),
	.i(mem_rdata)
);

mux2 #(.width(128)) pmem_wdatamux
(
	.a(line_out[0]),
	.b(line_out[1]),
	.sel(pmem_wdatamux_sel),
	.f(pmem_wdata)
);


endmodule // cache_datapath
