library verilog;
use verilog.vl_types.all;
entity SCurve_Single_Test is
    port(
        Clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        CLK_EXT         : in     vl_logic;
        out_trigger0b   : in     vl_logic;
        out_trigger1b   : in     vl_logic;
        out_trigger2b   : in     vl_logic;
        SCurve_Test_Start: in     vl_logic;
        CPT_MAX         : in     vl_logic_vector(15 downto 0);
        SCurve_Data     : out    vl_logic_vector(15 downto 0);
        SCurve_Data_wr_en: out    vl_logic;
        One_Channel_Done: out    vl_logic
    );
end SCurve_Single_Test;
