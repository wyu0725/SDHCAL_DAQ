library verilog;
use verilog.vl_types.all;
entity TestCyclicShift_tb is
    generic(
        PEROID          : integer := 20
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of PEROID : constant is 1;
end TestCyclicShift_tb;
