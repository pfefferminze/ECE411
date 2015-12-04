import lc3b_types::*;
import cache_types::*;

module cache_global(
	input clk,

	//signals between the datapath and the cache
	input lc3b_word [1:0] mem_address,
	input lc3b_word mem_wdata,
	input [1:0] mem_read,
	input [1:0] mem_write,
	input [1:0][1:0] mem_byte_enable,
	output lc3b_word [1:0] mem_rdata,
	output logic [1:0] mem_resp,

	//signals between the cache and the main memory
	input cache_line pmem_rdata,
	input pmem_resp,
	output cache_line pmem_wdata,
	output lc3b_word pmem_address,
	output logic pmem_read,
	output logic pmem_write
);

   logic 		 bigcache_write;
   logic 		 bigcache_read;
   lc3b_word bigcache_address;
   cache_line bigcache_wdata;
   logic 		 bigcache_resp;
   cache_line bigcache_rdata;

   cache_line L2_pmem_rdata;
   cache_line L2_pmem_wdata;
   logic 		 L2_pmem_resp;
   logic 		 L2_pmem_read;
   logic 		 L2_pmem_write;
   lc3b_word L2_pmem_address;
   

 		 
L1_caches level_one(
					
// signals between datapath and caches
					//	input logic 
					.clk(clk),
					.icache_read(mem_read[0]),
					.icache_write(mem_write[0]),
					.dcache_read(mem_read[1]),
					.dcache_write(mem_write[1]),
								
					//	input lc3b_mem_wmask 	
					.icache_wmask(mem_byte_enable[0]),
					.dcache_wmask(mem_byte_enable[1]),
								
					//	input lc3b_word			
					.icache_addr(mem_address[0]),
					.dcache_addr(mem_address[1]),
	
					//	input lc3b_pmem			
					.dcache_wdata(mem_wdata),
	
					//	output lc3b_pmem			
					.icache_rdata(mem_rdata[0]),
					.dcache_rdata(mem_rdata[1]),
									
					//	output logic 				
					.icache_mresp(mem_resp[0]),
					.dcache_mresp(mem_resp[1]),
	
// signals between arbitor and L2 (pmem or L2 cache
					//	input cache_line	
					.L2_rdata(bigcache_rdata),
					//	output logic		
					.L2_read(bigcache_read),
					.L2_write(bigcache_write),
					.L2_resp(bigcache_resp),
					
					//	output lc3b_word	
					.L2_addr(bigcache_address),
					//	output cache_line	
					.L2_wdata(bigcache_wdata)
); 

victim_cache Vicky
(
                 //input              
                   .clk(clk),

                    //signals between the victim cache and the bigcache
                    // input lc3b_word 
                   .mem_address(L2_pmem_address),
                    // input cache_line  
                   .mem_wdata(L2_pmem_wdata),
                    // input 
                   .mem_read(L2_pmem_read),
                   // input 
                   .mem_write(L2_pmem_write),
                   // output cache_line  
                   .mem_rdata(L2_pmem_rdata),
                   // output logic  
                   .mem_resp(L2_pmem_resp),

	               //signals between the cache and the main memory
                   // input cache_line  
                   .pmem_rdata(pmem_rdata),
                   // input  
                   .pmem_resp(pmem_resp),
                   // output cache_line  
                   .pmem_wdata(pmem_wdata),
                   // output lc3b_word  
                   .pmem_address(pmem_address),
                    // output logic  
                   .pmem_read(pmem_read),
                    // output logic  
                   .pmem_write(pmem_write)
);
 

bigcache level_two(
				   //	input clk,
				   .clk(clk),
//signals between the datapath and the cache
				   //	input lc3b_word 
				   .mem_address(bigcache_address),
				   //	input 		 cache_line 
				   .mem_wdata(bigcache_wdata),
				   //	input 		 
				   .mem_read(bigcache_read),
				   //	input 		 
				   .mem_write(bigcache_write),
				   //	output 		 cache_line 
				   .mem_rdata(bigcache_rdata),
				   //	output logic 
				   .mem_resp(bigcache_resp),

//signals between the cache and the main memory
				   //	input 		 cache_line 
				   .pmem_rdata(L2_pmem_rdata),
				   //	input 		 
				   .pmem_resp(L2_pmem_resp),
				   //	output 		 cache_line 
				   .pmem_wdata(L2_pmem_wdata),
				   //	output 		 lc3b_word 
				   .pmem_address(L2_pmem_address),
				   //	output logic 
				   .pmem_read(L2_pmem_read),
				   //	output logic 
				   .pmem_write(L2_pmem_write)
);
   

  
endmodule // cache_global
