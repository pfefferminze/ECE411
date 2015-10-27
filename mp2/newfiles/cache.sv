//####################################################################
//#                                                                  #
//#                                                                  #
//#               Created by Nick Moore                              #
//#                                                                  #
//#                for MP2 in ECE 411 at                             #
//#                University of Illinois                            #
//#                Fall 2015                                         #
//#                                                                  #
//####################################################################
import lc3b_types::*;

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
	output logic [15:0] pmem_address,
	output logic pmem_read,
	output logic pmem_write
);

logic valid_data,dirty_data;
logic pmem_wdatamux_sel,datainmux1_sel, datainmux0_sel;
logic [1:0] write, valid, dirty, hit;
cache_tag tag;
cache_tag [1:0] tags;
cache_index index;
lc3b_word rdata;
cache_offset offset;



assign mem_rdata = rdata;

cache_control control(
	.clk(clk),

	//signals between cache and cpu datapath
	.mem_read(mem_read),
	.mem_write(mem_write),
	.mem_resp(mem_resp),
	.mem_address(mem_address),

	//signals between cache and physical memory
	.pmem_read(pmem_read),
	.pmem_write(pmem_write),
	.pmem_resp(pmem_resp),
	.pmem_address(pmem_address),

	//signals between cache datapath and cache controller
	.valid_data(valid_data),
	.dirty_data(dirty_data),
	.write1(write[1]), 
	.write0(write[0]),
	.pmem_wdatamux_sel(pmem_wdatamux_sel),		//mux selects
	.datainmux1_sel(datainmux1_sel), 
	.datainmux0_sel(datainmux0_sel),	//mux selects
	.tag(tag),
	.tags(tags),
	.index(index),
	.isValid1(valid[1]), 
	.isValid0(valid[0]),
	.isHit1(hit[1]), 
	.isHit0(hit[0]),		//logic determining if there was a hit
	.isDirty1(dirty[1]),
	.isDirty0(dirty[0]),
	.offset(offset)


);

cache_datapath datapath(
	//signals between cache and cpu datapath
	.mem_address(mem_address),
	.mem_rdata(rdata),
	.mem_wdata(mem_wdata),
	.mem_byte_enable(mem_byte_enable),

	//signals between cache and physical memory
	.pmem_rdata(pmem_rdata),
	.pmem_wdata(pmem_wdata),

	//signals between cache datapath and cache controller
	.clk(clk),
	.valid_data(valid_data),
	.dirty_data(dirty_data),
	.write1(write[1]), 
	.write0(write[0]),
	.pmem_wdatamux_sel(pmem_wdatamux_sel),		//mux selects
	.datainmux1_sel(datainmux1_sel), 
	.datainmux0_sel(datainmux0_sel),	//mux selects
	.isValid1(valid[1]), 
	.isValid0(valid[0]),
	.isHit1(hit[1]), 
	.isHit0(hit[0]),		//logic determining if there was a hit
	.isDirty1(dirty[1]), 
	.isDirty0(dirty[0]),
	.index_out(index),
	.tag_out(tag),
	.tags(tags),
	.offset_out(offset)
);

//assign pmem_address = mem_address;
endmodule : cache
