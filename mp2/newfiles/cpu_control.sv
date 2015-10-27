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

module cpu_control
(
    /* Input and output port declarations */
	  input clk,
    
	 /*datapath control signals */
    output logic [1:0] pcmux_sel,
    output logic load_pc,
    output logic offset6mux_sel,
	 output logic storemux_sel,
	 output logic load_ir,
	 output logic [1:0] marmux_sel,
	 output logic load_mar,
	 output logic [1:0] mdrmux_sel,
	 output logic load_mdr,
	 output logic load_regfile,
	 output logic [1:0] alumux_sel,
	 output lc3b_aluop alu_op,
	 output logic [1:0] regfilemux_sel,
	 output logic load_cc,
	 output logic destmux_sel,
	 output lc3b_reg destmuxalt,
	 output logic br_addmux_sel, 
	 input lc3b_opcode opcode,
	 input br_en,
	 input addand_immed,
	 input shfa,
	 input shfd,
	 input jsrr,

	 /* memory signals */
	 input mem_resp,
	 output logic mem_read,
	 output logic mem_write,
	 output lc3b_mem_wmask mem_byte_enable,
	 input ldbbit
);

enum int unsigned {
    /* List of states */
	fetch1,
	fetch2,
	fetch3,
	decode,
	s_add,
	s_and,
	s_not,
	br,
	br_taken,
	calc_addr,
	ldr1,
	ldr2,
	str1,
	str2,
	s_lea,
	s_jmp,
	s_shf,
	s_jsr1,
	s_jsr2,
	s_trap1,
	s_trap2,
	s_trap3,
	s_sti1,
	s_sti2,
	s_sti3,
	s_sti4,
	s_ldi1,
	s_ldi2,
	s_ldi3,
	s_ldi4,
	s_ldi5,
	s_ldb1,		//compute address and laod mar
	s_ldb2,		//mdr <= mem[mar]
	s_ldb3,		//DR <= MDR
	s_stb1,
	s_stb2,
	s_stb3
} state, next_state;

always_comb
begin : state_actions
    /* Default output assignments */
     	 br_addmux_sel = 1'b0; 
	 offset6mux_sel = 1'b0;
	 load_pc = 1'b0;
	 load_ir = 1'b0;
	 load_regfile = 1'b0;
	 load_mar = 1'b0;
	 load_mdr = 1'b0;
	 load_cc = 1'b0;
	 pcmux_sel = 2'b00;
	 storemux_sel = 1'b0;
	 alumux_sel = 2'b00;
	 regfilemux_sel = 2'b00;
	 marmux_sel = 2'b00;
	 mdrmux_sel = 2'b00;
	 alu_op = alu_add;
	 mem_read = 1'b0;
	 mem_write = 1'b0;
	 mem_byte_enable = 2'b00;
	 br_addmux_sel = 1'b0;
	 destmux_sel = 1'b0;
	 destmuxalt = 3'b000;
	 
	 /* Actions for each state */
	 case(state)
		fetch1: begin
			//MAR <= PC
			marmux_sel = 2'b01;
			load_mar = 1;
			
			//PC<=PC+2
			pcmux_sel = 0;
			load_pc = 1;
		end
		
		fetch2: begin 
			//Read Memory
	 		mem_byte_enable = 2'b11;
			mem_read = 1;
			mdrmux_sel = 2'b01;
			load_mdr = 1;
		end
		
		fetch3: begin
			//Load IR
			load_ir = 1;
		end
		
		decode: ;//do nothing
		
		s_add: begin
			//DR <= SRA + SRB
			alu_op = alu_add;
			load_regfile = 1;
			load_cc = 1;
			if (addand_immed == 1'b1) alumux_sel = 2'b10;
		end
		
		s_not: begin
			//DR <= NOT(SRA)
			alu_op = alu_not;
			load_regfile = 1;
			load_cc = 1;
		end
		
		s_and: begin
			//DR <= SRA & SRB
			alu_op = alu_and;
			load_regfile = 1;
			load_cc = 1;
			if (addand_immed == 1'b1) alumux_sel = 2'b10;
		end
		
		br: begin
			//NONE
			//do nothing
		end
		
		br_taken: begin
			//PC<= PC + SEXT(IR[8:0] << 1)
			pcmux_sel = 2'b01;
			load_pc = 1;
		end
		
		calc_addr: begin
			//MAR <= SRA + SEXT(IR[5:0] << 1)
			alumux_sel = 2'b01;
			alu_op = alu_add;
			load_mar = 1;
		end
		
		ldr1: begin
			//MDR<=M[MAR]
	 		mem_byte_enable = 2'b11;
			mdrmux_sel = 2'b01;
			load_mdr = 1;
			mem_read = 1;
		end
		
		ldr2: begin
			//DR <= MDR
			regfilemux_sel = 2'b01;
			load_regfile = 1;
			load_cc = 1;
		end
		
		str1: begin
			//MDR<=SR
			storemux_sel = 1;
			alu_op = alu_pass;
			load_mdr = 1;
		end
		
		str2: begin
			//M[MAR] <= MDR
	 		mem_byte_enable = 2'b11;
			mem_write = 1;
		end
		
		s_lea: begin
			//DR <= PC + (SEXT(PCoffset9)<<1)
			regfilemux_sel = 2'b10;
			load_regfile = 1;
			load_cc = 1;
		end

		s_jmp:	begin
			//PC <= BaseR (sr2_out)
			pcmux_sel = 2'b10;
			load_pc = 1;
		end

		s_shf:	begin
			//DR <= SR shifted imm4
			alumux_sel = 2'b11;
			if (shfd == 1'b0)
			       alu_op = alu_sll;
			else 
			       alu_op = (shfa == 1'b0)? alu_srl:alu_sra;
			load_regfile = 1;
			load_cc = 1;
		end

		s_jsr1: begin
			//R7 <= PC
			destmux_sel = 1'b1;
			destmuxalt = 3'b111;
			regfilemux_sel = 2'b11;
			load_regfile = 1;
		end

		s_jsr2: begin
			//PC <= (!IR[11])? BaseR : PC + (SEXT(Off11)<<1)
			br_addmux_sel = 1'b1;
			pcmux_sel = (jsrr == 0)? 2'b10 : 2'b01;
			load_pc = 1;
		end

		s_trap1: begin
			 //R7 <= PC
			 regfilemux_sel = 2'b11;
			 load_regfile = 1;

			 //MAR <= trapvect8
			 marmux_sel = 2'b10;
			 load_mar = 1;
		end

		s_trap2: begin
			//MDR <= mem[MAR]
	 		mem_byte_enable = 2'b11;
			mdrmux_sel = 2'b01;
			load_mdr = 1;
			mem_read = 1;
		end

		s_trap3: begin
			//PC <= MDR
			pcmux_sel = 2'b11;
			load_pc = 1;
		end

		s_sti1: begin
			//MAR <= base + (offset6<<1)
			alumux_sel = 2'b01;
			alu_op = alu_add;
			load_mar = 1;
		end

		s_sti2: begin
			//MDR <= mem[MAR]
	 		mem_byte_enable = 2'b11;
	 		mem_read = 1'b1;
			mdrmux_sel = 2'b01;
			load_mdr = 1;
		end

		s_sti3: begin
			//MAR <= MDR
			marmux_sel = 2'b11;
			load_mar = 1;

			//MDR <= SR
			alu_op = alu_pass;
			storemux_sel = 1'b1;
			load_mdr = 1;
		end

		s_sti4: begin
			//mem[MAR] <= MDR
	 		mem_byte_enable = 2'b11;
	 		mem_write = 1'b1;
		end

		s_ldi1: begin
			//MAR <= base + (offset6<<1)
			alumux_sel = 2'b01;
			alu_op = alu_add;
			load_mar = 1;
		end

		s_ldi2: begin
			//MDR <= mem[MAR]
	 		mem_byte_enable = 2'b11;
	 		mem_read = 1'b1;
			mdrmux_sel = 2'b01;
			load_mdr = 1;
		end

		s_ldi3: begin
			//MAR <= MDR
			marmux_sel = 2'b11;
			load_mar = 1;
		end

		s_ldi4: begin
			//MDR <= mem[MAR]
	 		mem_byte_enable = 2'b11;
	 		mem_read = 1'b1;
			load_mdr = 1;
			mdrmux_sel = 2'b01;
		end

		s_ldi5: begin
			//DR <= MDR
			regfilemux_sel = 2'b01;
			load_regfile = 1;
			load_cc = 1;
		end
		
		s_ldb1:	begin
			//MAR <= BaseR + SEXT(offset6)
			alu_op = alu_add;
			offset6mux_sel = 1'b1;
			alumux_sel = 2'b01;
			load_mar = 1;
		end

		s_ldb2:	begin
			//MDR <= mem[MAR]
			mem_byte_enable = 2'b11;
			mdrmux_sel = (ldbbit == 1'b1)? 2'b10 : 2'b11;
			load_mdr = 1'b1;
			mem_read = 1;
		end

		s_ldb3:	begin
			//DR <= MDR setcc()
			regfilemux_sel = 2'b01;
			load_regfile = 1;
			load_cc = 1;

		end

		s_stb1: begin
			//MAR <= BaseR + SEXT(offset6)
			alu_op = alu_add;
			offset6mux_sel = 1'b1;
			alumux_sel = 2'b01;
			load_mar = 1;
		end

		s_stb2: begin
			//MDR <= SR 
			storemux_sel = 1'b1;
			alu_op = alu_stb;
			load_mdr = 1;
		end

		s_stb3: begin
			//mem[MAR] <= MDR
			mem_byte_enable = (ldbbit == 1'b1)? 2'b10 : 2'b01;
			mem_write = 1;
		end

		default: ;//do nothing]
	endcase
end : state_actions

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
	  next_state = state;
	  
	case(state)
//FETCH
		fetch1: next_state = fetch2;
		fetch2: next_state = (mem_resp == 1)? fetch3 : fetch2;
		fetch3: next_state = decode;
//DECODE
		decode: begin
			case(opcode)
				op_add: next_state = s_add;
				op_and: next_state = s_and;
				op_br:  next_state = br;
				op_not: next_state = s_not;
				op_ldr: next_state = calc_addr;
				op_str: next_state = calc_addr;
				op_lea:	next_state = s_lea; 
				op_jmp: next_state = s_jmp;
				op_shf:	next_state = s_shf;  
				op_jsr: next_state = s_jsr1;  
				op_trap: next_state = s_trap1; 
				op_sti:	next_state = s_sti1;
				op_ldi: next_state = s_ldi1;  
				op_ldb: next_state = s_ldb1;
				op_stb: next_state = s_stb1;
				default: ; //nothing
			endcase	
		end
//ADD		
		s_add: 	next_state = fetch1;
//AND
		s_and:	next_state = fetch1;
//NOT
		s_not: 	next_state = fetch1;
//CALC_ADDR
		calc_addr: next_state = (opcode == op_ldr)? ldr1 : str1;
//LDR
		ldr1:   next_state = (mem_resp == 1)? ldr2 : ldr1;
		ldr2:	next_state = fetch1;
//STR
		str1: 	next_state = str2;
		str2:	next_state = (mem_resp == 1)? fetch1 : str2;
//BR
		br: 	next_state = (br_en == 1)? br_taken : fetch1;
//BR_TAKEN
		br_taken: next_state = fetch1;
//LEA
		s_lea:	next_state = fetch1;
//JMP		
		s_jmp:	next_state = fetch1;
//SHF
		s_shf:	next_state = fetch1;
//JSR
		s_jsr1:	next_state = s_jsr2;
		s_jsr2:	next_state = fetch1;
//TRAP
		s_trap1: next_state = s_trap2;
		s_trap2: next_state = (mem_resp == 1)? s_trap3 : s_trap2;
		s_trap3: next_state = fetch1;
//STI
		s_sti1:  next_state = s_sti2;
		s_sti2:  next_state = (mem_resp == 1)? s_sti3 : s_sti2;
		s_sti3:  next_state = s_sti4;
		s_sti4:  next_state = (mem_resp == 1)? fetch1 : s_sti4;
//LDI
		s_ldi1:	 next_state = s_ldi2;
		s_ldi2:	 next_state = (mem_resp == 1)? s_ldi3 : s_ldi2;
		s_ldi3:	 next_state = s_ldi4;
		s_ldi4:	 next_state = (mem_resp == 1)? s_ldi5 : s_ldi4;
		s_ldi5:	 next_state = fetch1;
//LDB
		s_ldb1:	 next_state = s_ldb2;
		s_ldb2:	 next_state = (mem_resp == 1)? s_ldb3 : s_ldb2;
		s_ldb3:	 next_state = fetch1;
//STB		
		s_stb1:	 next_state = s_stb2;
		s_stb2:	 next_state = s_stb3;
		s_stb3:	 next_state = (mem_resp == 1)? fetch1: s_stb3;
	endcase
end : next_state_logic

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
	 state <= next_state;
end : next_state_assignment

endmodule : cpu_control

