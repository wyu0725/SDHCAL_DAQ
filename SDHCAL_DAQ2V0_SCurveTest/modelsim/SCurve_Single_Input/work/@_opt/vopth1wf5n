library verilog;
use verilog.vl_types.all;
entity SCurve_Single_Input is
    port(
        Clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        TrigEffi_or_CountEffi: in     vl_logic;
        Trigger         : in     vl_logic;
        CLK_EXT         : in     vl_logic;
        Test_Start      : in     vl_logic;
        CPT_MAX         : in     vl_logic_vector(15 downto 0);
        TriggerDelay    : in     vl_logic_vector(3 downto 0);
        CPT_PULSE       : out    vl_logic_vector(15 downto 0);
        CPT_TRIGGER     : out    vl_logic_vector(15 downto 0);
        CPT_DONE        : out    vl_logic
    );
end SCurve_Single_Input;
