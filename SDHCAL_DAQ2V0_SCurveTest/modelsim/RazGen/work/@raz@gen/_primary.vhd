library verilog;
use verilog.vl_types.all;
entity RazGen is
    port(
        Clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        TrigIn          : in     vl_logic;
        ExternalRaz_en  : in     vl_logic;
        ExternalRazDelayTime: in     vl_logic_vector(3 downto 0);
        SingleRaz_en    : out    vl_logic
    );
end RazGen;
