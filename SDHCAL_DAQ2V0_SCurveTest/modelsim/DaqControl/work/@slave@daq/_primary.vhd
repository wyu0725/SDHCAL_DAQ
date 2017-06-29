library verilog;
use verilog.vl_types.all;
entity SlaveDaq is
    port(
        Clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        ModuleStart     : in     vl_logic;
        AcqStart        : in     vl_logic;
        EndReadout      : in     vl_logic;
        CHIPSATB        : in     vl_logic;
        AcquisitionTime : in     vl_logic_vector(15 downto 0);
        EndHoldTime     : in     vl_logic_vector(15 downto 0);
        RESET_B         : out    vl_logic;
        START_ACQ       : out    vl_logic;
        StartReadout    : out    vl_logic;
        PWR_ON_A        : out    vl_logic;
        PWR_ON_D        : out    vl_logic;
        PWR_ON_ADC      : out    vl_logic;
        PWR_ON_DAC      : out    vl_logic;
        OnceEnd         : out    vl_logic;
        AllDone         : out    vl_logic;
        DataTransmitDone: in     vl_logic
    );
end SlaveDaq;
