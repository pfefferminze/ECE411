library verilog;
use verilog.vl_types.all;
entity nzp_comp is
    port(
        n               : in     vl_logic;
        inst_n          : in     vl_logic;
        z               : in     vl_logic;
        inst_z          : in     vl_logic;
        p               : in     vl_logic;
        inst_p          : in     vl_logic;
        br_en           : out    vl_logic
    );
end nzp_comp;
