library verilog;
use verilog.vl_types.all;
entity SCurve_Test_Control is
    port(
        Clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        Test_Start      : in     vl_logic;
        Single_Test_Start: out    vl_logic;
        Single_Test_Done: in     vl_logic;
        SCurve_Data_fifo_empty: in     vl_logic;
        SCurve_Data_fifo_din: in     vl_logic_vector(15 downto 0);
        SCurve_Data_fifo_rd_en: out    vl_logic;
        Single_or_64Chn : in     vl_logic;
        SingleTest_Chn  : in     vl_logic_vector(5 downto 0);
        Microroc_CTest_Chn_Out: out    vl_logic_vector(63 downto 0);
        Microroc_10bit_DAC_Out: out    vl_logic_vector(9 downto 0);
        SC_Param_Load   : out    vl_logic;
        Microroc_Config_Done: in     vl_logic;
        usb_data_fifo_wr_din: out    vl_logic_vector(15 downto 0);
        usb_data_fifo_wr_en: out    vl_logic;
        SCurve_Test_Done: out    vl_logic
    );
end SCurve_Test_Control;
