library verilog;
use verilog.vl_types.all;
entity magic_memory is
    port(
        clk             : in     vl_logic;
        read            : in     vl_logic;
        write           : in     vl_logic;
        wmask           : in     vl_logic_vector(1 downto 0);
        address         : in     vl_logic_vector(15 downto 0);
        wdata           : in     vl_logic_vector(15 downto 0);
        resp            : out    vl_logic;
        rdata           : out    vl_logic_vector(15 downto 0)
    );
end magic_memory;
