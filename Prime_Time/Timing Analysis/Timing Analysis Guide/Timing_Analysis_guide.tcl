# Steps to Execute Timing Analysis for Project : MV_MACRO_ENGINE 

1. Complete the Routing for the block and 
	
	Fix: issues in drc | shorts / open | floating wires
		- check_pg_drc -do_not_check_in_hier_blocks
		- check_lvs -max_errors 0
		- check_routes

2. Extract the RC parasitics using STARRC
	- create directories 
		- mkdir -p STARRC/{inputs,outputs/{spef,work},scripts}
	- scripts are available in STARRC folder 
	- copy extracted cbest.spef and cworst.spef to PRIMETIME inputs folder

3. PRIMETIME
	- create directories
		- mkdir -p PRIMETIME/{inputs,outputs,scripts,sessions}
	- copy the scripts available in the projects folder to PRIMETIME inputs in server
	- edit the paths where-ever required
	
	- copy the MV_MACRO_ENGINE.upf to the inputs directory of PRIMETIME
	- generate a routed netlist in icc2_shell for the routing+drc fixed block using
		- write_verilog ./PRIMETIME/inputs/routed_netlist.v
	
	// IMPORTANT: Export post-route SDCs. Do NOT use pre-route SDCs to avoid ideal clock issues (UITE-305)
	- generate a sdc file with 2 scenarios in icc2_shell { use either of one corners / scenarios }
		- to get scenarios in icc2_shell
			- get_scenarios
		- write_sdc -scenarios func.ss_125c -output ./PRIMETIME/ss_125_clean.sdc ; # setup
		- write_sdc -scenarios func.ff_m40c -output ./PRIMETIME/ff_m40_clean.sdc ; # hold
	
	- generating sessions 
	1. Invoke PRIMETIME shell using pt_shell
	2. Edit the paths in scripts like "func_max.tcl" and "func_min.tcl" 
		// CRITICAL FIX FOR SLG-303 CRASH: 
		// Ensure `link_library` ONLY contains 0.95V base cells, SRAM, and Level Shifters (including HVT ulvl).
		// Do NOT put 0.75V or 0.85V base cells in link_library, or scaling groups will fail.
		// Remove manual `set_propagated_clock` hacks from the script; the clean SDC handles it.
	3. source the func_max.tcl in pt_shell and verify the global timing
	4. once this completed, type `exit` to completely clear the shell memory, and repeat same for func_min.tcl
	
	- once the above two sessions are generated cleanly (func_max.sessions & func_min.sessions)
	1. Invoke the PRIMETIME in multi_scenario mode using 
		- pt_shell -multi_scenario 
	2. open the master dmsa.tcl script and execute line by line
	3. once all the fixes are done export the changes to icc2 using 
		- write_changes -format icc2tcl -output ./outputs/Multi_scenario_final_eco.tcl
	4. source this Multi_scenario_final_eco.tcl file on the icc2_shell with the last_block
	
	5. once script is sourced (ONLY if the ECO file actually contains changes), do below steps:
		- check_legality
		- legalize_placement -incremental -movable_distance 50
		- connect_pg_net
		- check_legality
		- route_eco -utilize_dangling_wires true -reuse_existing_global_route true -reroute modified_nets_first_then_others
		- check_lvs -max_errors 0
			- fix all the violations
		- check_routes
			- fix all the violations
		- check_pg_drc -do_not_check_in_hier_blocks
			- fix the drc vios
		- save the block
		
	6. WAIVERS (Don't worry about the following):
		- report_global_timing in icc2: If you are getting "No setup and Hold Vios" in PRIMETIME, ignore ICC2.
			- Note: In PRIMETIME we will get "1" Hold violation which can be ignored as it is ~5 fs (femto seconds).
			- We don't have X1 drive strength available in the library to fix this microscopic violation.
			- If we force the tool to use an X2 buffer (min ~15ps delay), it instantly creates a setup violation. The ECO tool will correctly abort the fix. Waive this 5fs path as OCV noise.
		
		- DRVs including max_trans & max_cap in icc2: 
			- ICC2 uses a fast, pessimistic TLU+ routing model to guess capacitance.
			- PRIMETIME uses the highly accurate 3D STARRC SPEF extraction. 
			- If you see 0 DRVs in PRIMETIME but ICC2 reports violations on `ropt_mc` cells, PrimeTime is the golden standard. Waive the ICC2 violations as TLU+ pessimism.
	
	7. Dont fix again once the PRIMETIME ECO fixes are done in icc2, just do 5th step and tape out!