* ==========================================================
* StarRC Command File for C-Worst (Setup) Extraction
* ==========================================================
BLOCK: mv_macro_engine_top

* 1. Inputs from ICC2
NETLIST_FORMAT: DEF
DEF_FILE: ../outputs/mv_macro_engine_routed.def

* 2. Technology Files (Foundry specific)
MAPPING_FILE: ../inputs/tech/saed32nm_tf_to_nxtgrd.map
TCAD_GRD_FILE: ../inputs/tech/Cmax.nxtgrd

* 3. Extraction Settings
EXTRACTION: RC
OPERATING_TEMPERATURE: 125
COUPLE_TO_GROUND: NO 
COUPLING_MULTIPLIER: 1.0

* 4. Output Generation
NETLIST_NODE_SECTION: YES
NETLIST_FILE: ../outputs/starrc/mv_macro_engine_cworst.spef