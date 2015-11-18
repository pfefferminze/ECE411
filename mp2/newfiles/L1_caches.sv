import lc3b_types::*;

module L1_caches (
	// signals between datapath and caches
	input logic 				clk,
									icache_read,
									icache_write,
									dcache_read,
									dcache_write,
									pmem_resp,
								
	input lc3b_mem_wmask 	icache_wmask,
									dcache_wmask,
								
	input lc3b_word			icache_addr,
									dcache_addr,
	
	input lc3b_pmem			dcache_wdata,
	
	output lc3b_pmem			icache_rdata,
									dcache_rdata,
									
	output logic 				icache_mresp,
									dcache_mresp,
	
	// signals between arbitor and L2 (pmem or L2 cache
	input lc3b_pmem	L2_rdata,
	output logic		L2_read,
							L2_write,
							L2_resp,
						
	output lc3b_word	L2_addr,
	output lc3b_pmem	L2_wdata
	
);

logic 			d_resp;
logic 			i_resp;
logic				i_mem_read;
logic				d_mem_read;
logic				i_mem_write;
logic				d_mem_write;
logic [127:0] 	i_wdata;
logic [127:0] 	d_wdata;
logic [127:0] 	i_rdata;
logic [127:0]	d_rdata;
logic [16:0]	i_raddr;
logic [16:0]	d_raddr;

cache icache(
	.clk,
	.mem_read(icache_read),
	.mem_write(icache_write),
	.mem_address(icache_addr),
	.mem_wdata(),
	.mem_byte_enable(icache_wmask),
	.mem_rdata(icache_rdata),
	.mem_resp(icache_mresp),
	
	.pmem_rdata(i_wdata),
	.pmem_resp(i_resp),
	.pmem_wdata(i_rdata),
	.pmem_address(i_raddr),
	.pmem_read(i_mem_read),
	.pmem_write(i_mem_write)
);

cache dcache (
	.clk,
	.mem_read(dcache_read),
	.mem_write(dcache_write),
	.mem_address(dcache_addr),
	.mem_wdata(dcache_wdata),
	.mem_byte_enable(dcache_wmask),
	.mem_rdata(dcache_rdata),
	.mem_resp(dcache_mresp),
	
	.pmem_rdata(d_wdata),
	.pmem_resp(d_resp),
	.pmem_wdata(d_rdata),
	.pmem_address(d_raddr),
	.pmem_read(d_mem_read),
	.pmem_write(d_mem_write)
);

arbitor arbitor(
	.*
);

 
endmodule
