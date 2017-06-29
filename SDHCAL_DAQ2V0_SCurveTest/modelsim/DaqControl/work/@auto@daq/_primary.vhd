library verilog;
use verilog.vl_types.all;
entity AutoDaq is
    port(
        Clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        start           : in     vl_logic;
        End_Readout     : in     vl_logic;
        Chipsatb        : in     vl_logic;
        T_acquisition   : in     vl_logic_vector(15 downto 0);
        Reset_b         : out    vl_logic;
        Start_Acq       : out    vl_logic;
        Start_Readout   : out    vl_logic;
        Pwr_on_a        : out    vl_logic;
        Pwr_on_d        : out    vl_logic;
        Pwr_on_adc      : out    vl_logic;
        Pwr_on_dac      : out    vl_logic;
        Once_end        : out    vl_logic
    );
end AutoDaq;
