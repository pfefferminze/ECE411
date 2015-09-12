import lc3b_types::*;

module mp1
(
    input clk,

    /* Memory signals */
    input mem_resp,
    input lc3b_word mem_rdata,
    output mem_read,
    output mem_write,
    output lc3b_mem_wmask mem_byte_enable,
    output lc3b_word mem_address,
    output lc3b_word mem_wdata
);

logic [1:0] pcmux_sel;
logic load_pc;
logic storemux_sel;
logic load_ir;
logic marmux_sel;
logic load_mar;
logic mdrmux_sel;
logic load_mdr;
logic load_regfile;
logic [1:0] alumux_sel;
logic [1:0] regfilemux_sel;
logic load_cc;
logic br_en;
logic addand_immed;

lc3b_aluop alu_op;
lc3b_opcode opcode;
/* Instantiate MP 0 top level blocks here */
datapath data_path(
	.clk(clk),
	.pcmux_sel(pcmux_sel),
	.load_pc(load_pc),
	.storemux_sel(storemux_sel),
	.load_ir(load_ir),
	.marmux_sel(marmux_sel),
	.load_mar(load_mar),
	.mdrmux_sel(mdrmux_sel),
	.load_mdr(load_mdr),
	.load_regfile(load_regfile),
	.alumux_sel(alumux_sel),
	.alu_op(alu_op),
	.regfilemux_sel(regfilemux_sel),
	.load_cc(load_cc),
	.br_en(br_en),
	.mem_rdata(mem_rdata),
	.mem_address(mem_address),
	.mem_wdata(mem_wdata),
	.opcode(opcode),
	.addand_immed(addand_immed)
);
control control_unit(
	.clk(clk),
	.pcmux_sel(pcmux_sel),
	.load_pc(load_pc),
	.storemux_sel(storemux_sel),
	.load_ir(load_ir),
	.marmux_sel(marmux_sel),
	.load_mar(load_mar),
	.mdrmux_sel(mdrmux_sel),
	.load_mdr(load_mdr),
	.load_regfile(load_regfile),
	.alumux_sel(alumux_sel),
	.alu_op(alu_op),
	.regfilemux_sel(regfilemux_sel),
	.load_cc(load_cc),
	.opcode(opcode),
	.br_en(br_en),
	.mem_resp(mem_resp),
	.mem_read(mem_read),
	.mem_write(mem_write),
	.mem_byte_enable(mem_byte_enable),
	.addand_immed(addand_immed)
);
endmodule : mp1
