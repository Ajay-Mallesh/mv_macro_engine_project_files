# mv_m_func.tcl
if {[sizeof_collection $mv_ports(test_se)] > 0} { set_case_analysis 0 $mv_ports(test_se) }
create_clock -period 2.0 -name clk $mv_ports(clocks)