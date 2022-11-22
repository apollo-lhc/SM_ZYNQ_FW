set apollo_root_path [file normalize "[file normalize [file dirname [info script]]]/../../"]
set BUILD_SCRIPTS_PATH $apollo_root_path/build-scripts/

cd $apollo_root_path

set PYTHONPATH $::env(PYTHONPATH)
set PYTHONHOME $::env(PYTHONHOME)
#set LD_LIBRARY_PATH  $::env(LD_LIBRARY_PATH)

#puts $LD_LIBRARY_PATH


puts "################ env(PATH) ################"
set env(PATH) "/usr/bin:$::env(PATH)" 
#puts $::env(PATH)


unset env(PYTHONPATH)
unset env(PYTHONHOME)
#unset env(LD_LIBRARY_PATH)

puts "################ LD_LIBRARY_PATH ################"
#set env(LD_LIBRARY_PATH) "/usr/lib:$::env(LD_LIBRARY_PATH)"
set LD_LIBRARY_PATH "/opt/cactus/lib"
#set env(LD_LIBRARY_PATH) $LD_LIBRARY_PATH

puts $::env(LD_LIBRARY_PATH) 

#set env(PYTHONPATH) "/usr/bin/python3"
puts "################ PYTHONPATH ################"
puts $PYTHONPATH

puts "################ PYTHON3 ################"
puts [exec python3 -V]

puts "################ starting pre-build ################"
exec make prebuild_rev2a_xczu7ev
#puts [exec bash -c "make -C $apollo_root_path prebuild_rev2a_xczu7ev"]
puts "################ ending pre-build ################"
  
set env(PYTHONPATH) $PYTHONPATH
set env(PYTHONHOME) $PYTHONHOME
#set env(LD_LIBRARY_PATH) $LD_LIBRARY_PATH

       
cd $BUILD_SCRIPTS_PATH      

