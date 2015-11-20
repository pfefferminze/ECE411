module mp2_tb;

   timeunit 1ns;
   timeprecision 1ns;

   logic clk;
   logic pmem_resp;
   logic pmem_read;
   logic pmem_write;
   logic [15:0] pmem_address;
   logic [127:0] pmem_rdata;
   logic [127:0] pmem_wdata;
   logic [1:0] icache_wmask;
   logic [15:0] icache_address, icache_rdata;
   logic icache_read, icache_write,  icache_memresp;
   
   /* Clock generator */
   initial clk = 0;
   always #5 clk = ~clk;

   /* icache_address initialization*/
   initial icache_address = 16'h0;

   /*icache_address incrementation*/
   always_ff @ (posedge clk) begin
	  if(icache_memresp)
		icache_address= icache_address + 16'h2;
	  
   /*icache_memresp toggle*/
	  if (icache_memresp) icache_read = 1'b0;
	  else icache_read = 1'b1;
   end
   
   mp2 dut
	 (
      .clk,
      .pmem_resp,
      .pmem_rdata,
      .pmem_read,
      .pmem_write,
      .pmem_address,
      .pmem_wdata,
	  .*
	  );

   physical_memory memory
	 (
      .clk,
      .read(pmem_read),
      .write(pmem_write),
      .address(pmem_address),
      .wdata(pmem_wdata),
      .resp(pmem_resp),
      .rdata(pmem_rdata)
	  );

   initial begin : icache_stuff

   end : icache_stuff
   
endmodule : mp2_tb
