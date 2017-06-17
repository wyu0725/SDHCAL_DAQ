library verilog;
use verilog.vl_types.all;
entity HoldGen_tb is
    generic(
        PERIOD1         : integer := 2;
        PERIOD2         : integer := 16
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of PERIOD1 : constant is 1;
    attribute mti_svvh_generic_type of PERIOD2 : constant is 1;
end HoldGen_tb;
