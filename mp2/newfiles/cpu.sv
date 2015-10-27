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

module cpu
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
logic [1:0] marmux_sel;
logic load_mar;
logic [1:0] mdrmux_sel;
logic load_mdr;
logic load_regfile;
logic [1:0] alumux_sel;
logic [1:0] regfilemux_sel;
logic load_cc;
logic br_en;
logic addand_immed;
logic shfa;
logic shfd;
logic br_addmux_sel;
logic jsrr;
logic destmux_sel; 
logic offset6mux_sel;
logic ldbbit; 

lc3b_aluop alu_op;
lc3b_opcode opcode;
lc3b_reg destmuxalt;

/* Instantiate MP 0 top level blocks here */
cpu_datapath data_path(
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
	.addand_immed(addand_immed),
	.shfa(shfa),
	.shfd(shfd),
	.br_addmux_sel(br_addmux_sel),
	.destmux_sel(destmux_sel),
	.destmuxalt(destmuxalt),
	.jsrr(jsrr),
	.offset6mux_sel(offset6mux_sel),
	.ldbbit(ldbbit)
);
cpu_control control_unit(
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
	.addand_immed(addand_immed),
	.shfa(shfa),
	.shfd(shfd),
	.br_addmux_sel(br_addmux_sel),
	.destmux_sel(destmux_sel),
	.destmuxalt(destmuxalt),
	.jsrr(jsrr),
	.offset6mux_sel(offset6mux_sel),
	.ldbbit(ldbbit)
);
endmodule : cpu

