library verilog;
use verilog.vl_types.all;
entity SCurve_Test_Top is
    port(
        Clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        Test_Start      : in     vl_logic;
        SingleTest_Chn  : in     vl_logic_vector(5 downto 0);
        Single_or_64Chn : in     vl_logic;
        CPT_MAX         : in     vl_logic_vector(15 downto 0);
        usb_data_fifo_wr_en: out    vl_logic;
        usb_data_fifo_wr_din: out    vl_logic_vector(15 downto 0);
        Microroc_Config_Done: in     vl_logic;
        Microroc_CTest_Chn_Out: out    vl_logic_vector(63 downto 0);
        Microroc_10bit_DAC_Out: out    vl_logic_vector(9 downto 0);
        SC_Param_Load   : out    vl_logic;
        CLK_EXT         : in     vl_logic;
        out_trigger0b   : in     vl_logic;
        out_trigger1b   : in     vl_logic;
        out_trigger2b   : in     vl_logic;
        SCurve_Test_Done: out    vl_logic
    );
end SCurve_Test_Top;
