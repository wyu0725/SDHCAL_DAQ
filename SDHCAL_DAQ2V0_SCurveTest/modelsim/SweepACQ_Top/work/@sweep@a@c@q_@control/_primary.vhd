library verilog;
use verilog.vl_types.all;
entity SweepACQ_Control is
    port(
        Clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        SweepStart      : in     vl_logic;
        SingleACQStart  : out    vl_logic;
        ForceMicrorocAcqReset: out    vl_logic;
        OneDACDone      : out    vl_logic;
        ACQDone         : out    vl_logic;
        DataTransmitDone: in     vl_logic;
        StartDAC0       : in     vl_logic_vector(9 downto 0);
        EndDAC0         : in     vl_logic_vector(9 downto 0);
        MaxPackageNumber: in     vl_logic_vector(15 downto 0);
        ParallelData_en : in     vl_logic;
        OutDAC0         : out    vl_logic_vector(9 downto 0);
        LoadSCParameter : out    vl_logic;
        MicrorocConfigDone: in     vl_logic;
        SweepACQFifoData: in     vl_logic_vector(15 downto 0);
        SweepACQFifoData_rden: out    vl_logic;
        SweepACQData    : out    vl_logic_vector(15 downto 0);
        SweepACQData_en : out    vl_logic;
        UsbDataFifoFull : in     vl_logic
    );
end SweepACQ_Control;
