# mv_m_test.tcl
if {[sizeof_collection $mv_ports(test_se)] > 0} { set_case_analysis 1 $mv_ports(test_se) }
create_clock -period 10.0 -name test_clk $mv_ports(clocks)