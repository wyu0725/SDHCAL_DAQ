library verilog;
use verilog.vl_types.all;
entity ADC_AD9220 is
    port(
        Clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        start           : in     vl_logic;
        ADC_OTR         : in     vl_logic;
        ADC_DATA        : in     vl_logic_vector(11 downto 0);
        ADC_CLK         : out    vl_logic;
        data_ready      : out    vl_logic;
        data            : out    vl_logic_vector(11 downto 0)
    );
end ADC_AD9220;
