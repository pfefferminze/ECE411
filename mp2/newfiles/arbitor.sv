module arbitor(
	input logic 		 clk,
				 i_mem_write,		//
				 d_mem_write,		//
				 i_mem_read,		//
				 d_mem_read,		//
				 L2_resp,		//
						
	input logic [127:0]      L2_rdata,              //input from L2
				 d_wdata, //data from dcache to L2 cache
			   
	output logic [127:0]     i_rdata,               //output to icache
				 d_rdata,		//output to dcache
						
	input logic [15:0] 	 i_raddr,		//
				 d_raddr,		//
						
	output logic 		 L2_read,		//
				 L2_write,		//
				 i_resp,		//
				 d_resp,		//
	
	output logic [127:0] 	L2_wdata,		//from L1 to L2
						 
	input logic [127:0]     i_wdata, 		//data from icache to L2 cache
	output logic [15:0]  	L2_addr 		//address to send to L2
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

   assign i_rdata = L2_rdata;
   assign d_rdata = L2_rdata;

always_comb begin : next_state_logic
   req_type = NONE;
   
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
			else begin
			   next_state = READY;
			end
		end
		WB: begin
		   if(L2_resp == 1) begin
			  next_state = L2_READ;
		   end
		   else begin
			  next_state = WB;
		   end
		   if(d_mem_write == 1) begin
			  req_type = DATA;
		   end
		   else begin
			  req_type = INST;
		   end
		end
		L2_READ: begin
		   if(L2_resp == 1) begin
			  next_state = READY;
		   end
		   else begin
			  next_state = L2_READ;
		   end
		   if(d_mem_read == 1) begin
			  req_type = DATA;
		   end
		   else begin
			  req_type = INST;
		   end
		end
	  default:;
	  
	endcase
end : next_state_logic

always_comb begin : state_actions
	/* SIG DEFAULTS */
   L2_read = 0;
   L2_write = 0;
   i_resp = 0;
   d_resp = 0;
   L2_addr = 16'h0;
   L2_wdata = 16'h0;

	case(state)
		READY: begin
			/* WAIT */
		end
		WB: begin
		   L2_write = 1;
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
		   L2_read = 1;
		   if(req_type == DATA) begin
			  d_resp = L2_resp;
			  L2_addr = d_raddr;
	           end
		   else begin
                          i_resp = L2_resp;
                          L2_addr = i_raddr;
                   end
	        end
	endcase
end : state_actions

endmodule
