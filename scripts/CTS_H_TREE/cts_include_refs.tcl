# ==========================================================================
# FILE: scripts/cts_include_refs.tcl
# DESC: Authorized cell list for CTS in Multi-Voltage Crypto Core
# AUTHOR: Ajay Mallesh
# VERSION: 1.0
# DATE: May 19, 2026 | 21:55 IST
# ==========================================================================

# Clear previous CTS purposes
set_lib_cell_purpose -exclude cts [get_lib_cells */*]

# This file authorizes the specific buffer/inverter variants used during tree balancing
set_lib_cell_purpose -include cts [get_lib_cells "*/NBUFF*LVT */NBUFF*RVT */INVX*_LVT */INVX*_RVT */DFF*"]

# Expand here to match your specific library variants (add as needed):
set_lib_cell_purpose -include cts [get_lib_cells "*/AND2X2_RVT */AND2X1_RVT */AND2X4_RVT"]
set_lib_cell_purpose -include cts [get_lib_cells "*/AO22X1_RVT */AO22X2_RVT */AOI22X1_RVT"]
set_lib_cell_purpose -include cts [get_lib_cells "*/CGLNPRX2_RVT */CGLNPRX8_RVT */CGLPPRX2_RVT"]
set_lib_cell_purpose -include cts [get_lib_cells "*/MUX21X1_RVT */MUX21X2_RVT"]
set_lib_cell_purpose -include cts [get_lib_cells "*/LSUPX1_RVT */LSUPX2_RVT */LSUPX4_RVT"]

# Include LVT counterparts for the high-speed paths
set_lib_cell_purpose -include cts [get_lib_cells "*/AND2X2_LVT */AND2X1_LVT */AND2X4_LVT"]
set_lib_cell_purpose -include cts [get_lib_cells "*/AO22X1_LVT */AO22X2_LVT */AOI22X1_LVT"]
set_lib_cell_purpose -include cts [get_lib_cells "*/CGLNPRX2_LVT */CGLNPRX8_LVT */CGLPPRX8_LVT"]
set_lib_cell_purpose -include cts [get_lib_cells "*/MUX21X1_LVT */MUX21X2_LVT"]
set_lib_cell_purpose -include cts [get_lib_cells "*/LSUPX1_LVT */LSUPX2_LVT */LSUPX4_LVT */LSUPX8_LVT"]