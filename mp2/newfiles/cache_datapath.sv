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
//#   L2cache_datapath.sv                                            #
//#     Implements the datapath module for the LC3B L2cache          #
//#     controlled by the control module for the LC3B L2cache        #
//#     instantiate both in L2cache.sv and connect the inputs/outputs#
//####################################################################

import cache_types::*;
import lc3b_types::*;

module L2cache_datapath (
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
					   input [7:0] 		  write,
					   input [2:0]		  pmem_wdatamux_sel, //mux selects
					   input [2:0]		  basemux_sel,
					   input 			  pmem_address_mux_sel,
					   input [7:0]		  datainmux_sel,
					   output logic [7:0] Valid,
					   output logic [7:0] Hit, //logic determining if there was a hit
					   output logic [7:0] Dirty
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
cache_line [7:0] line_out;
logic [7:0] isHit, isValid, isDirty;
logic [2:0] dataoutmux_sel;			//select line from dataoutmux -- controlled by combinational logic
logic [2:0] inter_hit;               //converts hit array to mux select signal
pmem_address_base [7:0] pmem_base;
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
assign offset = mem_address[3:1];
assign tag = mem_address[15:7];
assign Hit = isHit;
assign Valid = isValid;
assign Dirty = isDirty;
assign dataoutmux_sel = inter_hit;


always_comb begin : inter_hit_assignment
   case(Hit)
	 8'h1: inter_hit = 3'h0;
	 8'h2: inter_hit = 3'h1;
	 8'h4: inter_hit = 3'h2;
	 8'h8: inter_hit = 3'h3;
	 8'h10: inter_hit = 3'h4;
	 8'h20: inter_hit = 3'h5;
	 8'h40: inter_hit = 3'h6;
	 8'h80: inter_hit = 3'h7;
	 default: inter_hit = 3'h0;
   endcase // case (hit)
end : inter_hit_assignment
      
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
				   .datainmux_sel(datainmux_sel[0]), //selection signal for the mux that feeds the cache line array
				   .isValid(isValid[0]),
				   .isHit(isHit[0]),
				   .isDirty(isDirty[0]),

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
				   .datainmux_sel(datainmux_sel[1]), //selection signal for the mux that feeds the cache line array
				   .isValid(isValid[1]),
				   .isHit(isHit[1]),
				   .isDirty(isDirty[1]),

				  //signals from the parent module
				   .tag(tag),
				   .offset(offset),
				   .index(index)
				   );

   cache_way way2    (
				   //signals between cache and cpu datapath
				   .mem_wdata(mem_wdata),
				   .mem_byte_enable(mem_byte_enable),
				  
				  //signals between cache and physical memory
				   .line_in(pmem_rdata),
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
				   .tag(tag),
				   .offset(offset),
				   .index(index)
				   );

   cache_way way3    (
				   //signals between cache and cpu datapath
				   .mem_wdata(mem_wdata),
				   .mem_byte_enable(mem_byte_enable),
				  
				  //signals between cache and physical memory
				   .line_in(pmem_rdata),
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
				   .tag(tag),
				   .offset(offset),
				   .index(index)
				   );

   cache_way way4    (
				   //signals between cache and cpu datapath
				   .mem_wdata(mem_wdata),
				   .mem_byte_enable(mem_byte_enable),
				  
				  //signals between cache and physical memory
				   .line_in(pmem_rdata),
				   .line_out(line_out[4]),
				   .pmem_base(pmem_base[4]),

				  //signals between cache datapath and cache controller
				   .clk(clk),
				   .valid_data(valid_data),
				   .dirty_data(dirty_data),
				   .write(write[4]),
				   .datainmux_sel(datainmux_sel[4]), //selection signal for the mux that feeds the cache line array
				   .isValid(isValid[4]),
				   .isHit(isHit[4]),
				   .isDirty(isDirty[4]),

				  //signals from the parent module
				   .tag(tag),
				   .offset(offset),
				   .index(index)
				   );

   cache_way way5    (
				   //signals between cache and cpu datapath
				   .mem_wdata(mem_wdata),
				   .mem_byte_enable(mem_byte_enable),
				  
				  //signals between cache and physical memory
				   .line_in(pmem_rdata),
				   .line_out(line_out[5]),
				   .pmem_base(pmem_base[5]),

				  //signals between cache datapath and cache controller
				   .clk(clk),
				   .valid_data(valid_data),
				   .dirty_data(dirty_data),
				   .write(write[5]),
				   .datainmux_sel(datainmux_sel[5]), //selection signal for the mux that feeds the cache line array
				   .isValid(isValid[5]),
				   .isHit(isHit[5]),
				   .isDirty(isDirty[5]),

				  //signals from the parent module
				   .tag(tag),
				   .offset(offset),
				   .index(index)
				   );

   cache_way way6    (
				   //signals between cache and cpu datapath
				   .mem_wdata(mem_wdata),
				   .mem_byte_enable(mem_byte_enable),
				  
				  //signals between cache and physical memory
				   .line_in(pmem_rdata),
				   .line_out(line_out[6]),
				   .pmem_base(pmem_base[6]),

				  //signals between cache datapath and cache controller
				   .clk(clk),
				   .valid_data(valid_data),
				   .dirty_data(dirty_data),
				   .write(write[6]),
				   .datainmux_sel(datainmux_sel[6]), //selection signal for the mux that feeds the cache line array
				   .isValid(isValid[6]),
				   .isHit(isHit[6]),
				   .isDirty(isDirty[6]),

				  //signals from the parent module
				   .tag(tag),
				   .offset(offset),
				   .index(index)
				   );

   cache_way way7    (
				   //signals between cache and cpu datapath
				   .mem_wdata(mem_wdata),
				   .mem_byte_enable(mem_byte_enable),
				  
				  //signals between cache and physical memory
				   .line_in(pmem_rdata),
				   .line_out(line_out[7]),
				   .pmem_base(pmem_base[7]),

				  //signals between cache datapath and cache controller
				   .clk(clk),
				   .valid_data(valid_data),
				   .dirty_data(dirty_data),
				   .write(write[7]),
				   .datainmux_sel(datainmux_sel[7]), //selection signal for the mux that feeds the cache line array
				   .isValid(isValid[7]),
				   .isHit(isHit[7]),
				   .isDirty(isDirty[7]),

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
   
mux8 #(.width(12)) basemux
(
	.a(pmem_base[0]),
	.b(pmem_base[1]),
    .c(pmem_base[2]),
    .d(pmem_base[3]),
    .e(pmem_base[4]),
    .f(pmem_base[5]),
    .g(pmem_base[6]),
    .h(pmem_base[7]),
	.sel(basemux_sel),
	.i(basemux_out)
);

   
mux8 #(.width(128)) dataoutmux
(
	.a(line_out[0]),
	.b(line_out[1]),
	.c(line_out[2]),
	.d(line_out[3]),
	.e(line_out[4]),
	.f(line_out[5]),
	.g(line_out[6]),
	.h(line_out[7]),
	.sel(dataoutmux_sel),
	.i(dataoutmux_out)
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

mux8 #(.width(128)) pmem_wdatamux
(
	.a(line_out[0]),
	.b(line_out[1]),
	.c(line_out[2]),
	.d(line_out[3]),
	.e(line_out[4]),
	.f(line_out[5]),
	.g(line_out[6]),
	.h(line_out[7]),
	.sel(pmem_wdatamux_sel),
	.i(pmem_wdata)
);


endmodule // cache_datapath
