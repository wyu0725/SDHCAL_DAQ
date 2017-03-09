library verilog;
use verilog.vl_types.all;
entity SCurve_Data_FIFO_tb is
    generic(
        PEROID          : integer := 25
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of PEROID : constant is 1;
end SCurve_Data_FIFO_tb;
