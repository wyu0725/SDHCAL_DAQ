library verilog;
use verilog.vl_types.all;
entity TrigEfficiencyTest_tb is
    generic(
        High_T          : integer := 12;
        Low_T           : integer := 13
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of High_T : constant is 1;
    attribute mti_svvh_generic_type of Low_T : constant is 1;
end TrigEfficiencyTest_tb;
