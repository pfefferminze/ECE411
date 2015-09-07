library verilog;
use verilog.vl_types.all;
entity memory is
    generic(
        DELAY_MEM       : integer := 200
    );
    port(
        clk             : in     vl_logic;
        read            : in     vl_logic;
        write           : in     vl_logic;
        byte_enable     : in     vl_logic_vector(1 downto 0);
        address         : in     vl_logic_vector(15 downto 0);
        wdata           : in     vl_logic_vector(15 downto 0);
        resp            : out    vl_logic;
        rdata           : out    vl_logic_vector(15 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DELAY_MEM : constant is 1;
end memory;
