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
//#   victim_datapath.sv                                             #
//#     Implements the datapath module for the LC3B victim cache     #
//#     controlled by the control module for the LC3B victim         #
//#     instantiate both in victim_cache.sv and connect the          #
//#     inputs/outputs                                               #
//#   differences from L2_datapath.sv                                #
//#     fewer ways                                                   #
//#     line out is looped into line in for the ways so we don't     #
//#        have to worry about losing our data when we write back    #
//#        otherwise when we update the dirty bits we could lose     #
//#        data                                                      #
//####################################################################

import cache_types::*;
import lc3b_types::*;

module victim_datapath (
					   //signals between cache and cpu datapath
					   input 			  lc3b_word mem_address,
					   input 			  cache_line mem_wdata,
					   output 			  cache_line mem_rdata,
					   output 			  lc3b_word pmem_address,

					   //signals between cache and physical memory
					   input 			  cache_line pmem_rdata,  /*DEPRECATED for victim cache, as we loop lineout back around.  victim cache only*/
					   output 			  cache_line pmem_wdata,  /*gets new data from L2 cache.*/

					   //signals between cache datapath and cache controller
					   input 			  clk,
					   input 			  valid_data,
					   input 			  dirty_data,
					   input [7:0] 		  write,
					   input [2:0] 		  pmem_wdatamux_sel, //mux selects
					   input [2:0] 		  basemux_sel,
					   input 			  pmem_address_mux_sel,
					   input [7:0] 		  datainmux_sel,
					   input [2:0] 		  dataoutmux_sel, //select line from dataoutmux -- controlled by control unit
					   output logic [7:0] Valid,
					   output logic [7:0] Hit, //logic determining if there was a hit
					   output logic [7:0] Dirty
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

cache_offset offset;				//word select stripped off of mem_address
victim_tag tag;					//set tag stripped off of mem_address
cache_line dataoutmux_out;			//connects dataoutmux to wordselectmux
cache_line [3:0] line_out;
logic [3:0] isHit, isValid, isDirty;

logic [1:0] inter_hit;               //converts hit array to mux select signal
pmem_address_base [3:0] pmem_base;
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
assign offset = mem_address[3:1];
assign tag = mem_address[15:4];
assign Hit = isHit;
assign Valid = isValid;
assign Dirty = isDirty;

					   
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
victim_way way0    (
				   //signals between cache and cpu datapath
				   .mem_wdata(mem_wdata),
				  
				  //signals between cache and physical memory
				   .line_in(line_out[0]),
 				   .line_out(line_out[0]),
				   .pmem_base(pmem_base[0]),

				  //signals between cache datapath and cache controller
				   .clk(clk),
				   .valid_data(valid_data),
				   .dirty_data(dirty_data),
				   .write(write[0]),
				   .datainmux_sel(datainmux_sel[0]), //selection signal for the mux that feeds the cache line array
				   .isValid(isValid[0]),
				   .isHit(isHit[0]),
				   .isDirty(isDirty[0]),

				  //signals from the parent module
				   .offset(offset),
				   .tag(tag)
 				   );

victim_way way1    (
				   //signals between cache and cpu datapath
				   .mem_wdata(mem_wdata),
				  
				  //signals between cache and physical memory
				   .line_in(line_out[1]),
				   .line_out(line_out[1]),
				   .pmem_base(pmem_base[1]),

				  //signals between cache datapath and cache controller
				   .clk(clk),
				   .valid_data(valid_data),
				   .dirty_data(dirty_data),
				   .write(write[1]),
				   .datainmux_sel(datainmux_sel[1]), //selection signal for the mux that feeds the cache line array
				   .isValid(isValid[1]),
				   .isHit(isHit[1]),
				   .isDirty(isDirty[1]),

				  //signals from the parent module
				   .offset(offset),
				   .tag(tag)
				   );

victim_way way2    (
				   //signals between cache and cpu datapath
				   .mem_wdata(mem_wdata),
				  
				  //signals between cache and physical memory
				   .line_in(line_out[2]),
				   .line_out(line_out[2]),
				   .pmem_base(pmem_base[2]),

				  //signals between cache datapath and cache controller
				   .clk(clk),
				   .valid_data(valid_data),
				   .dirty_data(dirty_data),
				   .write(write[2]),
				   .datainmux_sel(datainmux_sel[2]), //selection signal for the mux that feeds the cache line array
				   .isValid(isValid[2]),
				   .isHit(isHit[2]),
				   .isDirty(isDirty[2]),

				  //signals from the parent module
				   .offset(offset),
				   .tag(tag)
				   );

victim_way way3    (
				   //signals between cache and cpu datapath
				   .mem_wdata(mem_wdata),
				  
				  //signals between cache and physical memory
				   .line_in(line_out[3]),
				   .line_out(line_out[3]),
				   .pmem_base(pmem_base[3]),

				  //signals between cache datapath and cache controller
				   .clk(clk),
				   .valid_data(valid_data),
				   .dirty_data(dirty_data),
				   .write(write[3]),
				   .datainmux_sel(datainmux_sel[3]), //selection signal for the mux that feeds the cache line array
				   .isValid(isValid[3]),
				   .isHit(isHit[3]),
				   .isDirty(isDirty[3]),

				  //signals from the parent module
				   .offset(offset),
				   .tag(tag)
				   );

mux2 #(.width(16)) pmem_address_mux
(
	.a(mem_address),
	.b(wb_address),
	.sel(pmem_address_mux_sel),
	.f(pmem_address)
);
   
mux4 #(.width(12)) basemux
(
	.a(pmem_base[0]),
	.b(pmem_base[1]),
    .c(pmem_base[2]),
    .d(pmem_base[3]),
	.sel(basemux_sel),
	.f(basemux_out)
);
   
mux8 #(.width(128)) dataoutmux
(
	.a(line_out[0]),
	.b(line_out[1]),
	.c(line_out[2]),
	.d(line_out[3]),
    .e(pmem_rdata),
    .f(),
    .g(),
    .h(),
	.sel(dataoutmux_sel),
	.i(mem_rdata)
);


mux4 #(.width(128)) pmem_wdatamux
(
	.a(line_out[0]),
	.b(line_out[1]),
	.c(line_out[2]),
	.d(line_out[3]),
	.sel(pmem_wdatamux_sel),
	.f(pmem_wdata)
);


endmodule // cache_datapath
