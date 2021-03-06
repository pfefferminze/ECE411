

module arbitor(
			   input logic 			clk,
									i_mem_write, //
									d_mem_write, //
									i_mem_read, //
									d_mem_read, //
									L2_resp, //
			   input logic [127:0] 	L2_rdata, //input from L2
									d_wdata, //data from dcache to L2 cache
			   output logic [127:0] i_rdata, //output to icache
									d_rdata, //output to dcache
			   input logic [15:0] 	i_raddr, //
									d_raddr, //
			   output logic 		L2_read, //
									L2_write, //
									i_resp, //
									d_resp, //
			   output logic [127:0] L2_wdata, //from L1 to L2
			   input logic [127:0] 	i_wdata, //data from icache to L2 cache
			   output logic [15:0] 	L2_addr //address to send to L2
			   );
   enum { READY, WB, L2_READ } state, next_state;
   typedef enum logic [1:0]{NONE = 2'd0,INST = 2'd1,DATA = 2'd2	} request;

   logic 		reg_load, req_type_load;
   logic [15:0] address_out,address_mux_out;
   logic 		address_sel, addressmux_sel;
   request req_type, req_type_stable;

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
	  // L2_addr = 16'h0;
	  L2_wdata = d_wdata;
	  req_type_load = 0;
	  case(state)
		READY: begin
		   /* WAIT */
		   reg_load = 1'b1;
		   req_type_load = 1;
		end
		WB: begin
		   reg_load = 1'b0;
		   L2_write = 1;
		   if(req_type_stable == DATA) begin
			  d_resp = L2_resp;
			  // L2_addr = d_raddr;
			  L2_wdata = d_wdata;
		   end
		   else begin
			  i_resp = L2_resp;
			  // L2_addr = i_raddr;
			  L2_wdata = i_wdata;
		   end
		end
		L2_READ: begin
		   L2_read = 1;
		   reg_load = 1'b0;
		   if(req_type_stable == DATA) begin
			  d_resp = L2_resp;
			  // L2_addr = d_raddr;
		   end
		   else begin
			  i_resp = L2_resp;
			  // L2_addr = i_raddr;
		   end
		end
	  endcase
   end : state_actions

   assign address_sel = (req_type == DATA)? 1'b0:1'b1;
   assign L2_addr = address_mux_out;

   //register #(2) req_type_register(
   // .clk(clk),
   // .load(req_type_load),
   // .in(req_type),
   // .out(req_type_stable)
   //);

   always_ff @ (posedge clk) begin : req_type_register
	  req_type_stable = req_type_stable;
	  if(req_type_load) req_type_stable = req_type;
   end
   register #(1) address_register(
								  .clk(clk),
								  .load(reg_load),
								  .in(address_sel),
								  .out(addressmux_sel)
								  );
   mux2 #(16) address_mux(
						  .sel(addressmux_sel),
						  .a(d_raddr), .b(i_raddr),
						  .f(address_mux_out)
						  );
   //mux2 #(16) data_mux(
   ///*input*/ .sel(addressmux_sel),
   ///*input [width-1:0]*/ .a(d_raddr), .b(i_raddr),
   ///*output logic [width-1:0]*/ .f(data_mux_out)
   //);
endmodule
