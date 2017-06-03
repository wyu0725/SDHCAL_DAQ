library verilog;
use verilog.vl_types.all;
entity TestCyclicShift is
    port(
        Clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        MaskChoise      : in     vl_logic_vector(2 downto 0);
        MaskChannel     : in     vl_logic_vector(5 downto 0);
        MaskOrUnmask    : in     vl_logic_vector(1 downto 0);
        ChannelMask     : out    vl_logic_vector(191 downto 0)
    );
end TestCyclicShift;
