library verilog;
use verilog.vl_types.all;
library work;
entity control is
    port(
        clk             : in     vl_logic;
        pcmux_sel       : out    vl_logic;
        load_pc         : out    vl_logic;
        storemux_sel    : out    vl_logic;
        load_ir         : out    vl_logic;
        marmux_sel      : out    vl_logic;
        load_mar        : out    vl_logic;
        mdrmux_sel      : out    vl_logic;
        load_mdr        : out    vl_logic;
        load_regfile    : out    vl_logic;
        alumux_sel      : out    vl_logic;
        alu_op          : out    work.lc3b_types.lc3b_aluop;
        regfilemux_sel  : out    vl_logic;
        load_cc         : out    vl_logic;
        opcode          : in     work.lc3b_types.lc3b_opcode;
        br_en           : in     vl_logic;
        mem_resp        : in     vl_logic;
        mem_read        : out    vl_logic;
        mem_write       : out    vl_logic;
        mem_byte_enable : out    vl_logic_vector(1 downto 0)
    );
end control;
