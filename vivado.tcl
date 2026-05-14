
# Note: This is a non-project script
# For more information, please refer to the Xilinx document UG894
# "Vivado Design Suite User Guide: Using TCL Scripting", version 2014.1, page 11
# For details about the TCL commands, please refer to the Xilinx document UG835
# "Vivado Design Suite Tcl Command Reference Guide"

# Miscellaneous useful variables
set top $env(TOP)
# Define the output directory area. Mostly for debug purposes.
set outputDir "./build_vivado"
file mkdir $outputDir

set part $env(PART)
## This is board Zybo
#set part xc7z010clg400-1
## This is board Zedboard
#set part xc7z020clg484-1
## This is board ZC706
#set part xc7z045ffg900-2

# Set target part to fake current project, to read IPs
# More details: http://www.xilinx.com/support/answers/54317.html
set_part $part
set_property part $part [current_project]

# Setup design sources

#set sources_vhd [glob ./hdl/*.vhd]
set sources_vhd [glob ./*.vhd]

foreach f $sources_vhd {
	read_vhdl -vhdl2008 $f
}

set sources_v [glob ./vm80a/*.v]

foreach f $sources_v {
	read_verilog $f
}

# Setup constraints
read_xdc $env(XDC)

# No limit for message: Sequential element unused
set_msg_config -id {[Synth 8-3333]} -limit 1000000
# No limit for message: Constant propagation
set_msg_config -id {[Synth 8-3332]} -limit 1000000
# No limit for message: Unconnected port
set_msg_config -id {[Synth 8-3331]} -limit 1000000
# No limit for message: Tying undriven pin to constant 0
set_msg_config -id {[Synth 8-3295]} -limit 1000000
# Hide messages: Sub-optimal pipelining for BRAM
set_msg_config -id {[Synth 8-4480]} -suppress

# Run logic synthesis
synth_design -top $top -keep_equivalent_registers -resource_sharing on
#synth_design -top $top -keep_equivalent_registers -flatten_hierarchy full -resource_sharing on
#synth_design -top $top -keep_equivalent_registers -resource_sharing on -directive AreaOptimized_high

# Run logic optimization
opt_design
# Warning : This seems not useful with 2015.3, and crashes with 2017.2
#opt_design -directive ExploreArea

# Report timing and utilization estimates
report_utilization     -file $outputDir/post_synth_util.rpt
report_timing_summary  -file $outputDir/post_synth_timing_summary.rpt

# Write design checkpoint
write_checkpoint -force $outputDir/post_synth.dcp

# Note: For debug purposes, if you want to start from post- logic synthesis state,
# uncomment these lines and remove all above commands (except setting of parameters)
#read_checkpoint $outputDir/post_synth.dcp
#link_design -top $top -part $part



# Use this option if you really want Vivado to try
#set_param place.skipUtilizationCheck 1

# Run automated placement of the remaining of the design
place_design
#place_design -directive Explore
#place_design -directive WLDrivenBlockPlacement
#place_design -directive ExtraNetDelay_high

# Physical logic optimization
phys_opt_design -directive AggressiveExplore

# Report utilization and timing estimates
report_utilization       -file $outputDir/post_place_util.rpt
report_clock_utilization -file $outputDir/clock_util.rpt
report_timing_summary    -file $outputDir/post_place_timing_summary.rpt

# Write design checkpoint
write_checkpoint -force $outputDir/post_place.dcp



# Note: For debug purposes, if you want to start from post- placement state,
# uncomment these lines and remove all above commands (except setting of parameters)
#read_checkpoint $outputDir/post_place.dcp
#link_design -top $top -part $part

# Run first routing
#route_design
route_design -tns_cleanup -directive Explore
#route_design -tns_cleanup -preserve

# Note: For more optimization, perform another placement optimization and re-route
#place_design -post_place_opt
#phys_opt_design -directive AggressiveExplore
#route_design

# Report the routing status, timing, power, design rule check
report_route_status   -file $outputDir/post_route_status.rpt
report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_power          -file $outputDir/post_route_power.rpt
report_drc            -file $outputDir/post_route_drc.rpt

# Write the post-route design checkpoint
write_checkpoint -force $outputDir/post_route.dcp



# Note: For debug purposes, if you want to start from post- routing state,
# uncomment these lines and remove all above commands (except setting of parameters)
#read_checkpoint $outputDir/post_route.dcp
#link_design -top $top -part $part

# Optionally generate post- routing simulation model
#set postparDir $outputDir/vhdl-postpar/
#file mkdir $postparDir
#write_vhdl -force $postparDir/top.vhd
#write_sdf -force $postparDir/top.sdf

# Generate the bitstream
write_bitstream -force $outputDir/$top.bit

