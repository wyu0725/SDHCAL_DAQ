library verilog;
use verilog.vl_types.all;
entity HoldGen is
    port(
        Clk             : in     vl_logic;
        Clk_320M        : in     vl_logic;
        reset_n         : in     vl_logic;
        TrigIn          : in     vl_logic;
        Hold_en         : in     vl_logic;
        HoldDelay       : in     vl_logic_vector(7 downto 0);
        HoldTime        : in     vl_logic_vector(15 downto 0);
        HoldOut         : out    vl_logic
    );
end HoldGen;
