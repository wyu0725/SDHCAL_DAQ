library verilog;
use verilog.vl_types.all;
entity AdcControl is
    port(
        Clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        Hold            : in     vl_logic;
        StartAcq        : in     vl_logic;
        AdcStartDelay   : in     vl_logic_vector(3 downto 0);
        AdcDataNumber   : in     vl_logic_vector(7 downto 0);
        ADC_DATA        : in     vl_logic_vector(11 downto 0);
        ADC_OTR         : in     vl_logic;
        ADC_CLK         : out    vl_logic;
        Data            : out    vl_logic_vector(15 downto 0);
        Data_en         : out    vl_logic
    );
end AdcControl;
