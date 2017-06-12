library verilog;
use verilog.vl_types.all;
entity Hold_Gen is
    port(
        Clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        Hold_en         : in     vl_logic;
        TrigCoincid     : in     vl_logic_vector(1 downto 0);
        HoldDelay       : in     vl_logic_vector(8 downto 0);
        OUT_TRIG0B      : in     vl_logic;
        OUT_TRIG1B      : in     vl_logic;
        OUT_TRIG2B      : in     vl_logic;
        Ext_TRIGB       : in     vl_logic;
        HOLD            : out    vl_logic;
        ExternalRaz_en  : in     vl_logic;
        ExternalRazDelayTime: in     vl_logic_vector(9 downto 0);
        SingleRaz_en    : out    vl_logic
    );
end Hold_Gen;
