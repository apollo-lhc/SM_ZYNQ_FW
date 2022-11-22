#DRP ip

#Check if a path already exists for this IP
if {![info exists ip_repo_path]} {
    set ip_repo_path IP/packaged_ip/
}
puts "AXI_DRP_include IP path:  $ip_repo_path"
set_property  ip_repo_paths ${ip_repo_path}  [current_project]
update_ip_catalog
