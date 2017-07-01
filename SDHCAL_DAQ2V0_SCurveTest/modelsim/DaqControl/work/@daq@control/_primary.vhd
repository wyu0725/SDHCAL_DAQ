library verilog;
use verilog.vl_types.all;
entity DaqControl is
    port(
        Clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        DaqSelect       : in     vl_logic;
        UsbAcqStart     : in     vl_logic;
        UsbStartStop    : out    vl_logic;
        EndReadout      : in     vl_logic;
        StartReadout    : out    vl_logic;
        CHIPSATB        : in     vl_logic;
        RESET_B         : out    vl_logic;
        START_ACQ       : out    vl_logic;
        PWR_ON_A        : out    vl_logic;
        PWR_ON_D        : out    vl_logic;
        PWR_ON_ADC      : out    vl_logic;
        PWR_ON_DAC      : out    vl_logic;
        AcquisitionTime : in     vl_logic_vector(15 downto 0);
        EndHoldTime     : in     vl_logic_vector(15 downto 0);
        OnceEnd         : out    vl_logic;
        AllDone         : out    vl_logic;
        DataTransmitDone: in     vl_logic;
        UsbFifoEmpty    : in     vl_logic;
        MicrorocData    : in     vl_logic_vector(15 downto 0);
        MicrorocData_en : in     vl_logic;
        DaqData         : out    vl_logic_vector(15 downto 0);
        DaqData_en      : out    vl_logic;
        ExternalTrigger : in     vl_logic
    );
end DaqControl;
