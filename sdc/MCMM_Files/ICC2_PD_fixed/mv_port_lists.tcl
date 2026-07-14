# ==========================================================================
# PORT LISTS
# ==========================================================================
set mv_ports(clocks)          [get_ports clk]
set mv_ports(mode_reset)      [get_ports rst_n]
set mv_ports(sys_inputs)      [get_ports sys_data_in*]
set mv_ports(context_outputs) [get_ports context_sig_out*]
set mv_ports(pci_outputs)     [get_ports pci_sig_out*]
set mv_ports(sdram_outputs)   [get_ports sdram_sig_out*]
set mv_ports(reg_outputs)     [get_ports reg_sig_out*]

# Safely grab scan ports if they exist
set mv_ports(test_si) [get_ports scan_in_1 -quiet]
set mv_ports(test_so) [get_ports scan_out_1 -quiet]
set mv_ports(test_se) [get_ports scan_en -quiet]