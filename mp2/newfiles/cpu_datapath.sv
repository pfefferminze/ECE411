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

module cpu_datapath
(
    input clk,
    /* control signals */
    input [1:0] pcmux_sel,
    input load_pc,
    	 input offset6mux_sel,
	 input storemux_sel,
	 input destmux_sel,
	 input load_ir,
	 input [1:0] marmux_sel,
	 input load_mar,
	 input [1:0] mdrmux_sel,
	 input load_mdr,
	 input load_regfile,
	 input [1:0] alumux_sel,
	 input lc3b_aluop alu_op,
	 input [1:0] regfilemux_sel,
	 input load_cc,
 	 output br_en, 
	 input br_addmux_sel,
	 input lc3b_reg destmuxalt,
    /* declare more ports here */
	 input lc3b_word mem_rdata,
	 output lc3b_word mem_address,
	 output lc3b_word mem_wdata,
	 output lc3b_opcode opcode,
	 output logic addand_immed,
	 output logic shfa,
	 output logic shfd,
	 output logic jsrr,
	 output logic ldbbit
);

/* declare internal signals */
lc3b_word pcmux_out;
lc3b_word mdr_out;
lc3b_word pc_out;
lc3b_word br_add_out;
lc3b_word pc_plus2_out;
lc3b_word adj9_out;
lc3b_word adj11_out;
lc3b_word adj6_out;
lc3b_word sr1_out, sr2_out;
lc3b_word regfilemux_out;
lc3b_word alu_out;
lc3b_word marmux_out;
lc3b_word mdrmux_out;
lc3b_word alumux_out;
lc3b_word br_addmux_out;
lc3b_word immed5_extension_out;
lc3b_word imm4_extension_out;
lc3b_offset11 offset11;
lc3b_word trapvect8_out;
lc3b_word extend6_out;
lc3b_word offset6mux_out;

lc3b_trapvect8 trapvect8;

lc3b_reg sr1, sr2, dest, storemux_out, cc_out,destmux_out;

lc3b_offset9 offset9;
lc3b_offset6 offset6;
lc3b_imm4 imm4;

lc3b_nzp gencc_out;
lc3b_immed5 immed5; 


/*
 * PC
 */
mux4 pcmux
(
	.sel(pcmux_sel),
	.a(pc_plus2_out),
	.b(br_add_out),
	.c(sr1_out),
	.d(mdr_out),
	.f(pcmux_out)
);

mux2 #(.width(3)) storemux
(
	.sel(storemux_sel),
	.a(sr1),
	.b(dest),
	.f(storemux_out)
);


mux2 #(.width(3))destmux 
(
	.sel(destmux_sel),
	.a(dest),
	.b(destmuxalt),
	.f(destmux_out)
);

register pc
(
    .clk(clk),
    .load(load_pc),
    .in(pcmux_out),
    .out(pc_out)
);


ir ir_unit
(
	.clk(clk),
	.load(load_ir),
	.in(mdr_out),
	.opcode(opcode),
	.dest(dest),
	.src1(sr1),
	.src2(sr2),
	.offset6(offset6),
	.offset9(offset9),
	.addand_immed(addand_immed),
	.immed5(immed5),  
	.shfa(shfa),
	.shfd(shfd),
	.imm4(imm4),
	.offset11(offset11),
	.jsrr(jsrr),
	.trapvect8(trapvect8)
);

zextsh #(.inwidth(8)) zexttrapvect8
(
	.in(trapvect8),
	.out(trapvect8_out)
);

zext #(.inwidth(4)) imm4_extension
(
	.in(imm4),
	.out(imm4_extension_out)
);

extend immed5_extension
(
	.in(immed5),
	.out(immed5_extension_out)
);

adj #(.width(9)) adj9
(
	.in(offset9),
	.out(adj9_out)
);

adj #(.width(11)) adj11
(
	.in(offset11),
	.out(adj11_out)
);

adder #(.width(16)) br_add
(	
	.a(br_addmux_out),
	.b(pc_out),
	.sum(br_add_out)
);

mux2 #(.width(16)) br_addmux
(
    .sel(br_addmux_sel),
    .a(adj9_out),
    .b(adj11_out),
    .f(br_addmux_out)
);

adj #(.width(6)) adj6
(
	.in(offset6),
	.out(adj6_out)
);

extend #(.inwidth(6)) extend6
(
	.in(offset6),
	.out(extend6_out)
);

mux2 #(.width(16)) offset6mux
(
	.sel(offset6mux_sel),
	.a(adj6_out),
	.b(extend6_out),
	.f(offset6mux_out)
);

regfile rfile
(
	.clk(clk),
	.load(load_regfile),
	.in(regfilemux_out),
	.src_a(storemux_out),
	.src_b(sr2),
	.dest(destmux_out),
	.reg_a(sr1_out),
	.reg_b(sr2_out)
);

mux4 regfilemux
(
	.sel(regfilemux_sel),
	.a(alu_out),
	.b(mdr_out),
	.c(br_add_out),
	.d(pc_out),
	.f(regfilemux_out)
);

mux4 mdrmux
(
    .sel(mdrmux_sel),
    .a(alu_out),
    .b(mem_rdata),
    .c({8'h0,mem_rdata[15:8]}),
    .d({8'h0,mem_rdata[7:0]}),
    .f(mdrmux_out)
);

mux4 marmux
(
    .sel(marmux_sel),
    .a(alu_out),
    .b(pc_out),
    .c(trapvect8_out),
    .d(mdr_out),
    .f(marmux_out)
);


register mar
(
    .clk(clk),
    .load(load_mar),
    .in(marmux_out),
    .out(mem_address)
);


register mdr
(
    .clk(clk),
    .load(load_mdr),
    .in(mdrmux_out),
    .out(mdr_out)
);
 
gencc gen_cc
(
	.in(regfilemux_out),
	.out(gencc_out)
);

register #(.width(3)) cc
(
    .clk(clk),
    .load(load_cc),
    .in(gencc_out),
    .out(cc_out)
);

nzp_comp cccomp
(
	.n(cc_out[2]), 
	.inst_n(dest[2]),
	.z(cc_out[1]),
	.inst_z(dest[1]),
	.p(cc_out[0]),
	.inst_p(dest[0]),
	.br_en(br_en)
);

plus2 plus_2
(
	.in(pc_out),
	.out(pc_plus2_out)
);

mux4 alumux
(
	.sel(alumux_sel),
	.a(sr2_out),
	.b(offset6mux_out),
	.c(immed5_extension_out),
	.d(imm4_extension_out),
	.f(alumux_out)
);

alu alu_unit
(
	.aluop(alu_op),
	.a(sr1_out),
	.b(alumux_out),
	.f(alu_out)
);

assign mem_wdata = mdr_out;
assign ldbbit = mem_address[0];


endmodule : cpu_datapath

