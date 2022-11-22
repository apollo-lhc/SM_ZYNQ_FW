set apollo_root_path [file normalize "[file normalize [file dirname [info script]]]/../../"]
set BUILD_SCRIPTS_PATH $apollo_root_path/build-scripts/
set build_name rev1_xc7z035
set outputDir $apollo_root_path/Projects/rev1_xc7z035

puts $build_name
puts ${build_name}

proc pause {{message "Hit Enter to continue ==> "}} {
    puts -nonewline $message
    flush stdout
    gets stdin
}

#pause "Hurry, hit enter: "; # Sample usage 1
pause;                      # Sample usage 2, use default message

#report_timing_summary -file $outputDir/post_route_timing_summary.rpt
#report_timing -sort_by group -max_paths 100 -path_type summary -file $outputDir/post_route_timing.rpt
#report_clock_utilization -file $outputDir/clock_util.rpt
#report_utilization -file $outputDir/post_route_util.rpt
#report_power -file $outputDir/post_route_power.rpt
#report_drc -file $outputDir/post_imp_drc.rpt
write_verilog -force $outputDir/bft_impl_netlist.v
write_xdc -no_fixed_only -force $outputDir/bft_impl.xdc
write_checkpoint -force $outputDir/post_route


source ${BUILD_SCRIPTS_PATH}/Generate_hwInfo.tcl

#file mkdir $apollo_root_path/bit
#file copy -force $apollo_root_path/Projects/rev1_xc7z035/rev1_xc7z035.runs/impl_1/top.bit $apollo_root_path/bit/top_rev1_xc7z035.bit
#file copy -force $apollo_root_path/Projects/rev1_xc7z035/rev1_xc7z035.runs/impl_1/top.hwdef $apollo_root_path/kernel/hw/top.hwdef
#file copy -force $apollo_root_path/Projects/rev1_xc7z035/rev1_xc7z035.runs/impl_1/top.hwdef $apollo_root_path/kernel/hw/top.xsa
#file copy -force $apollo_root_path/Projects/rev1_xc7z035/rev1_xc7z035.runs/impl_1/top.hwdef $apollo_root_path/kernel/hw/top.sysdef

