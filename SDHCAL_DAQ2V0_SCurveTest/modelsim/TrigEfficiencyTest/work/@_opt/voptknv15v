library verilog;
use verilog.vl_types.all;
entity TrigEfficiencyTest is
    port(
        Clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        CLK_EXT         : in     vl_logic;
        OUT_TRIGGER0B   : in     vl_logic;
        OUT_TRIGGER1B   : in     vl_logic;
        OUT_TRIGGER2B   : in     vl_logic;
        Start           : in     vl_logic;
        CPT_MAX         : in     vl_logic_vector(15 downto 0);
        TriggerDelay    : in     vl_logic_vector(3 downto 0);
        TrigEfficiencyData: out    vl_logic_vector(15 downto 0);
        TrigEfficiencyData_en: out    vl_logic;
        TestDone        : out    vl_logic;
        DataTransmitDone: in     vl_logic
    );
end TrigEfficiencyTest;
