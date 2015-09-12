import lc3b_types::*;

module datapath
(
    input clk,
    /* control signals */
    input [1:0] pcmux_sel,
    input load_pc,
	 input storemux_sel,
	 input load_ir,
	 input marmux_sel,
	 input load_mar,
	 input mdrmux_sel,
	 input load_mdr,
	 input load_regfile,
	 input [1:0] alumux_sel,
	 input lc3b_aluop alu_op,
	 input [1:0] regfilemux_sel,
	 input load_cc,
 	 output br_en, 
    /* declare more ports here */
	 input lc3b_word mem_rdata,
	 output lc3b_word mem_address,
	 output lc3b_word mem_wdata,
	 output lc3b_opcode opcode,
	 output logic addand_immed
);

/* declare internal signals */
lc3b_word pcmux_out;
lc3b_word mdr_out;
lc3b_word pc_out;
lc3b_word br_add_out;
lc3b_word pc_plus2_out;
lc3b_word adj9_out;
lc3b_word adj6_out;
lc3b_word sr1_out, sr2_out;
lc3b_word regfilemux_out;
lc3b_word alu_out;
lc3b_word marmux_out;
lc3b_word mdrmux_out;
lc3b_word alumux_out;
lc3b_word immed5_extension_out;

lc3b_reg sr1, sr2, dest, storemux_out, cc_out;

lc3b_offset9 offset9;
lc3b_offset6 offset6;

lc3b_nzp gencc_out;
lc3b_immed5 immed5; 


/*
 * PC
 */
mux3 pcmux
(
	.sel(pcmux_sel),
	.a(pc_plus2_out),
	.b(br_add_out),
	.c(sr1_out),
	.f(pcmux_out)
);

mux2 #(.width(3)) storemux
(
	.sel(storemux_sel),
	.a(sr1),
	.b(dest),
	.f(storemux_out)
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
	.immed5(immed5)  
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

adder #(.width(16)) br_add
(	
	.a(adj9_out),
	.b(pc_out),
	.sum(br_add_out)
);


adj #(.width(6)) adj6
(
	.in(offset6),
	.out(adj6_out)
);

regfile rfile
(
	.clk(clk),
	.load(load_regfile),
	.in(regfilemux_out),
	.src_a(storemux_out),
	.src_b(sr2),
	.dest(dest),
	.reg_a(sr1_out),
	.reg_b(sr2_out)
);

mux3 regfilemux
(
	.sel(regfilemux_sel),
	.a(alu_out),
	.b(mdr_out),
	.c(br_add_out),
	.f(regfilemux_out)
);

mux2 mdrmux
(
    .sel(mdrmux_sel),
    .a(alu_out),
    .b(mem_rdata),
    .f(mdrmux_out)
);

mux2 marmux
(
    .sel(marmux_sel),
    .a(alu_out),
    .b(pc_out),
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

mux3 alumux
(
	.sel(alumux_sel),
	.a(sr2_out),
	.b(adj6_out),
	.c(immed5_extension_out),
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

endmodule : datapath
