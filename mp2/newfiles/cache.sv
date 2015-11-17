//####################################################################
//#                                                                  #
//#                L2cache.sv                                        #
//#                                                                  #
//#               Created by Nick Moore                              #
//#                for group Random2to use                           #
//#                in MP3 in ECE 411 at                              #
//#                University of Illinois                            #
//#                Fall 2015                                         #
//#                                                                  #
//####################################################################

import lc3b_types::*;
import cache_types::*;

module cache 
(
	input clk,

	//signals between the datapath and the cache
	input lc3b_word mem_address,
	input lc3b_word mem_wdata,
	input mem_read,
	input mem_write,
	input [1:0] mem_byte_enable,
	output lc3b_word mem_rdata,
	output logic mem_resp,

	//signals between the cache and the main memory
	input cache_line pmem_rdata,
	input pmem_resp,
	output cache_line pmem_wdata,
	output lc3b_word pmem_address,
	output logic pmem_read,
	output logic pmem_write
);


logic valid_data,dirty_data;
logic [2:0] pmem_wdatamux_sel;
logic [7:0] write, valid, dirty, hit,datainmux_sel;
logic [2:0]	basemux_sel;
logic pmem_address_mux_sel;
   
   
cache_index index;

assign index = mem_address[6:4];
   
   L2cache_datapath cdatapath(
					   //signals between cache and cpu datapath
//					   input lc3b_word
					   .mem_address(mem_address),
//					   input 			  lc3b_word
                  .mem_wdata(mem_wdata),
					   //input [1:0] 		  
					   .mem_byte_enable(mem_byte_enable),
//					   output 			  lc3b_word
					   .mem_rdata(mem_rdata),
//					   output 			  lc3b_word
					   .pmem_address(pmem_address),

					   //signals between cache and physical memory
					   //input 			  cache_line
					   .pmem_rdata(pmem_rdata),
					   //output 			  cache_line
					   .pmem_wdata(pmem_wdata),

					   //signals between cache datapath and cache controller
					   //input 			  
					   .clk(clk),
					   //input 			  
					   .valid_data(valid_data),
					   //input 			  
					   .dirty_data(dirty_data),
//					   input [7:0] 		  
					   .write(write),
//					   input [2:0]			  
					   .pmem_wdatamux_sel(pmem_wdatamux_sel), //mux selects
//					   input 			  
					   .basemux_sel(basemux_sel),
//					   input 			  
					   .pmem_address_mux_sel(pmem_address_mux_sel),
//					   output logic [7:0] 
					   .Valid(valid),
//					   output logic [7:0] 
					   .Hit(hit), //logic determining if there was a hit
//					   output logic [7:0] 
					   .Dirty(dirty),
					   .datainmux_sel(datainmux_sel)
					   );
						
   L2cache_control ccontrol(
	//signals between cache and cpu datapath
//	input 
						   .mem_read(mem_read),
//	input 
						   .mem_write(mem_write),
//	output logic 
						   .mem_resp(mem_resp),

	//signals between cache and physical memory
//	output logic 
						   .pmem_read(pmem_read),
//	output logic 
						   .pmem_write(pmem_write),
//	input 
						   .pmem_resp(pmem_resp),

	//signals between cache datapath and cache controller
//	input 
						   .clk(clk),
//	output logic 
						   .valid_data(valid_data),
//	output logic 
						   .dirty_data(dirty_data),
//	output logic [7:0] 
						   .write(write),
//	output logic [2:0]
						   .pmem_wdatamux_sel(pmem_wdatamux_sel),		//mux selects
//	output logic [7:0] 
						   .datainmux_sel(datainmux_sel),	//mux selects
//    output logic  
						   .pmem_address_mux_sel(pmem_address_mux_sel),
//    output logic [2:0] 
						   .basemux_sel(basemux_sel),
//	input cache_index 
						   .index(index),
//	input [7:0] 
						   .Valid(valid),
//	input [7:0] 
						   .Hit(hit),		//logic determining if there was a hit
//	input [7:0] 
						   .Dirty(dirty)
);

   
endmodule // L2cache
