library verilog;
use verilog.vl_types.all;
entity ACQ_or_SCTest_Switch is
    port(
        ACQ_or_SCTest   : in     vl_logic;
        USB_Acq_Start_Stop: in     vl_logic;
        Microroc_Acq_Start_Stop: out    vl_logic;
        SCTest_Start_Stop: out    vl_logic;
        Microroc_usb_data_fifo_wr_din: in     vl_logic_vector(15 downto 0);
        Microroc_usb_data_fifo_wr_en: in     vl_logic;
        SCTest_usb_data_fifo_wr_din: in     vl_logic_vector(15 downto 0);
        SCTest_usb_data_fifo_wr_en: in     vl_logic;
        out_to_usb_data_fifo_wr_din: out    vl_logic_vector(15 downto 0);
        out_to_usb_data_fifo_wr_en: out    vl_logic;
        USB_Microroc_CTest_Chn_Out: in     vl_logic_vector(63 downto 0);
        SCTest_Microroc_CTest_Chn_Out: in     vl_logic_vector(63 downto 0);
        out_to_Microroc_CTest_Chn_Out: out    vl_logic_vector(63 downto 0);
        USB_Microroc_10bit_DAC0_Out: in     vl_logic_vector(9 downto 0);
        USB_Microroc_10bit_DAC1_Out: in     vl_logic_vector(9 downto 0);
        USB_Microroc_10bit_DAC2_Out: in     vl_logic_vector(9 downto 0);
        SCTest_Microroc_10bit_DAC_Out: in     vl_logic_vector(9 downto 0);
        out_to_Microroc_10bit_DAC0_Out: out    vl_logic_vector(9 downto 0);
        out_to_Microroc_10bit_DAC1_Out: out    vl_logic_vector(9 downto 0);
        out_to_Microroc_10bit_DAC2_Out: out    vl_logic_vector(9 downto 0);
        USB_SC_Param_Load: in     vl_logic;
        SCTest_SC_Param_Load: in     vl_logic;
        out_to_Microroc_SC_Param_Load: out    vl_logic
    );
end ACQ_or_SCTest_Switch;
