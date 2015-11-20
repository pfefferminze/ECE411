import cache_types::*;
import lc3b_types::*;

module L1_caches (
	// signals between datapath and caches
				  input logic  clk,
							   icache_read,
							   icache_write,
							   dcache_read,
							   dcache_write,
								
				  input 	   lc3b_mem_wmask icache_wmask,
							   dcache_wmask,
								
				  input 	   lc3b_word icache_addr,
							   dcache_addr,
	
				  input 	   lc3b_word dcache_wdata,
	
				  output 	   lc3b_word icache_rdata,
							   dcache_rdata,
									
				  output logic icache_mresp,
							   dcache_mresp,
	
	// signals between arbitor and L2 (pmem or L2 cache
				  input 	   cache_line L2_rdata,
				  output logic L2_read,
							   L2_write,
				  input 	   L2_resp,
						
				  output 	   lc3b_word L2_addr,
				  output 	   cache_line L2_wdata
	
);

   logic   d_resp;
   logic 		i_resp;
   logic 		i_mem_read;
   logic 			d_mem_read;
   logic 			i_mem_write;
   logic 			d_mem_write;
   logic [127:0] 	i_wdata;
   logic [127:0] 	d_wdata;
   logic [127:0] 	i_rdata;
   logic [127:0] 	d_rdata;
   logic [15:0] 	i_raddr;
   logic [15:0] 	d_raddr;

//   assign i_wdata = 128'h0;
   
   cache icache(
				.clk,
				.mem_read(icache_read),
				.mem_write(icache_write),
				.mem_address(icache_addr),
				.mem_wdata(),
				.mem_byte_enable(icache_wmask),
				.mem_rdata(icache_rdata),
				.mem_resp(icache_mresp),
			 
				.pmem_rdata(i_rdata),//input
				.pmem_resp(i_resp),
 				.pmem_wdata(i_wdata),//output
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
	
				 .pmem_rdata(d_rdata),		//input
				 .pmem_resp(d_resp),
				 .pmem_wdata(d_wdata),		//output
				 .pmem_address(d_raddr),
				 .pmem_read(d_mem_read),
				 .pmem_write(d_mem_write)
				 );

/*module arbitor(
	input logic				clk,i_mem_write,d_mem_write,i_mem_read,	d_mem_read,	L2_resp,
	input logic [127:0]	L2_rdata,i_rdata,d_rdata,
	input logic [15:0]	i_raddr,d_raddr,
	output logic			L2_read,L2_write,i_resp,d_resp,
	output logic [127:0]	L2_wdata,i_wdata,d_wdata,
	output logic [15:0] 	L2_addr
);
*/
   arbitor arbitor_unit(
				   .clk,
				   .i_mem_write,
				   .d_mem_write,
				   .i_mem_read,
				   .d_mem_read,
				   .L2_resp,
				   .L2_rdata,
				   .i_rdata,
				   .d_rdata,
				   .i_raddr,
				   .d_raddr,
				   .L2_read,
				   .L2_write,
				   .i_resp,
				   .d_resp,
				   .L2_wdata,
				   .d_wdata,
				   .L2_addr,
                                   .i_wdata
				   );

 
endmodule
