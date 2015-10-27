import lc3b_types::*;

module mp2
(
    input clk,
    input pmem_resp,
    input [127:0] pmem_rdata,
    output logic pmem_read,
    output logic pmem_write,
    output logic [15:0] pmem_address,
    output logic [127:0] pmem_wdata
);

lc3b_mem_wmask mem_byte_enable;
lc3b_word mem_address;
lc3b_word mem_wdata;
lc3b_word mem_rdata;
logic mem_read;
logic mem_write;
logic mem_resp;

cpu core(
    .clk(clk),
    .mem_resp(mem_resp),
    .mem_rdata(mem_rdata),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_byte_enable(mem_byte_enable),
    .mem_address(mem_address),
    .mem_wdata(mem_wdata)
);


cache memory(
	.clk(clk),
	.mem_resp(mem_resp),
	.mem_rdata(mem_rdata),
	.mem_read(mem_read),
	.mem_write(mem_write),
	.mem_byte_enable(mem_byte_enable),
	.mem_address(mem_address),
	.mem_wdata(mem_wdata),
	.pmem_resp(pmem_resp),
	.pmem_rdata(pmem_rdata),
	.pmem_read(pmem_read),
	.pmem_write(pmem_write),
	.pmem_address(pmem_address),
	.pmem_wdata(pmem_wdata)
);

//assign pmem_address = mem_address;
endmodule : mp2
