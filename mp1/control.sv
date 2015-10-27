import lc3b_types::*; /* Import types defined in lc3b_types.sv */

module control
(
    /* Input and output port declarations */
	  input clk,
    
	 /*datapath control signals */
    output logic [1:0] pcmux_sel,
    output logic load_pc,
	 output logic storemux_sel,
	 output logic load_ir,
	 output logic marmux_sel,
	 output logic load_mar,
	 output logic mdrmux_sel,
	 output logic load_mdr,
	 output logic load_regfile,
	 output logic [1:0] alumux_sel,
	 output lc3b_aluop alu_op,
	 output logic [1:0] regfilemux_sel,
	 output logic load_cc,
	 input lc3b_opcode opcode,
	 input br_en,
	 input addand_immed,

	 /* memory signals */
	 input mem_resp,
	 output logic mem_read,
	 output logic mem_write,
	 output lc3b_mem_wmask mem_byte_enable
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
	s_jmp
} state, next_state;

always_comb
begin : state_actions
    /* Default output assignments */
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
	 marmux_sel = 1'b0;
	 mdrmux_sel = 1'b0;
	 alu_op = alu_add;
	 mem_read = 1'b0;
	 mem_write = 1'b0;
	 mem_byte_enable = 2'b11;
	 
	 /* Actions for each state */
	 case(state)
		fetch1: begin
			//MAR <= PC
			marmux_sel = 1;
			load_mar = 1;
			
			//PC<=PC+2
			pcmux_sel = 0;
			load_pc = 1;
		end
		
		fetch2: begin 
			//Read Memory
			mem_read = 1;
			mdrmux_sel = 1;
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
			mdrmux_sel = 1;
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

		default: ;//do nothing]
	endcase
end : state_actions

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
	  next_state = state;
	  
	case(state)
		fetch1: begin 
			next_state = fetch2;
		end
		fetch2: begin
			if(mem_resp == 1)
				next_state = fetch3;
			else
				next_state = fetch2;
		end
		fetch3: begin
			next_state = decode;
		end
		decode: begin
			case(opcode)
				op_add: begin
					next_state = s_add;
				end
				op_and: begin 
					next_state = s_and;
				end
				op_br: begin
					next_state = br;
				end
				op_not: begin
					next_state = s_not;
				end
				op_ldr: begin
					next_state = calc_addr;
				end
				op_str: begin
					next_state = calc_addr;
				end
				op_lea:	next_state = s_lea; 

				op_jmp: next_state = s_jmp;

				default: ; //nothing
			endcase	
		end
		s_add: begin
			next_state = fetch1;
		end
		s_and: begin
			next_state = fetch1;
		end
		s_not: begin
			next_state = fetch1;
		end
		calc_addr: begin
			if(opcode == op_ldr)
				next_state = ldr1;
			else
				next_state = str1;
		end
		ldr1:  begin
			if(mem_resp == 1)
				next_state = ldr2;
			else
				next_state = ldr1;
		end
		ldr2: begin
			next_state = fetch1;
		end
		str1: begin 
			next_state = str2;
		end
		str2: begin
			if(mem_resp == 1)
				next_state = fetch1;
			else
				next_state = str2;
		end
		br: begin
			if(br_en == 1)
				next_state = br_taken;
			else
				next_state = fetch1;
		end
		br_taken: begin 
			next_state = fetch1;
		end
		
		s_lea:	begin
			next_state = fetch1;
		end
		
		s_jmp:	begin
			next_state = fetch1;
		end
	endcase
end : next_state_logic

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
	 state <= next_state;
end : next_state_assignment

endmodule : control
