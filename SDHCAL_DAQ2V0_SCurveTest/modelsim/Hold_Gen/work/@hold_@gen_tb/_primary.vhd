library verilog;
use verilog.vl_types.all;
entity Hold_Gen_tb is
    generic(
        PERIOD          : integer := 2
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of PERIOD : constant is 1;
end Hold_Gen_tb;
