module arbitor(
	input logic				clk,
								i_mem_write,
								d_mem_write,
								i_mem_read,
								d_mem_read,
								L2_resp,
						
	input logic [127:0]	L2_rdata,
								i_rdata,
								d_rdata,
						
	input logic [15:0]	i_raddr,
								d_raddr,
						
	output logic			L2_read,
								L2_write,
								i_resp,
								d_resp,
	
	output logic [127:0]	L2_wdata,
								i_wdata,
								d_wdata,
				
	output logic [15:0] 	L2_addr
						
);

enum {
	READY,
	WB,
	L2_READ
} state, next_state;

enum {
	NONE,
	INST,
	DATA
} req_type, next_req_type;

always_ff @ (posedge clk) begin
	state <= next_state;
end

always_comb begin : next_state_logic
	case(state)
		READY: begin
			if(d_mem_read == 1 || i_mem_read == 1) begin
				next_state = L2_READ;
				if(d_mem_read == 1) begin
					req_type = DATA;
				end
				else begin
					req_type = INST;
				end
			end
			else if(d_mem_write == 1 || i_mem_write == 1) begin
				next_state = WB;
				if(d_mem_write == 1) begin
					req_type = DATA;
				end
				else begin
					req_type = INST;
				end
			end
		end
		WB: begin
			if(L2_resp == 1) begin
				next_state = L2_READ;
			end
			else begin
				next_state = WB;
			end
		end
		L2_READ: begin
			if(L2_resp == 1) begin
				next_state = READY;
			end
			else begin
				next_state = L2_READ;
			end
		end
	endcase
end : next_state_logic

always_comb begin : state_actions
	/* SIG DEFAULTS */
	L2_read = 0;
	L2_write = 0;
	i_resp = 0;
	d_resp = 0;
	
	case(state)
		READY: begin
			/* WAIT */
		end
		WB: begin
			if(req_type == DATA) begin
				d_resp = L2_resp;
				L2_addr = d_raddr;
				L2_wdata = d_rdata;
			end
			else begin
				i_resp = L2_resp;
				L2_addr = i_raddr;
				L2_wdata = i_rdata;
			end
		end
		L2_READ: begin
			if(req_type == DATA) begin
				d_resp = L2_resp;
				L2_addr = d_raddr;
				d_wdata = L2_rdata;
			end
		end
	endcase
end : state_actions

endmodule
