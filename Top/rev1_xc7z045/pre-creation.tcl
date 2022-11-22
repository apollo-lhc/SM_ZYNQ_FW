set apollo_root_path [file normalize "[file normalize [file dirname [info script]]]/../../"]
set BUILD_SCRIPTS_PATH $apollo_root_path/build-scripts/

cd $apollo_root_path

set PYTHONPATH $::env(PYTHONPATH)
set PYTHONHOME $::env(PYTHONHOME)
set PATH       $::env(PATH)

unset env(PYTHONPATH)
unset env(PYTHONHOME)

unset env(PATH)

puts "################         ################"

set test [puts [exec which python3]]

puts "################ PYTHON3 ################"
puts [exec python3 -V]

puts "################ starting pre-build ################"
exec make prebuild_rev1_xc7z045 
puts "################ ending pre-build ################"

set env(PYTHONPATH) $PYTHONPATH
set env(PYTHONHOME) $PYTHONHOME
set env(PATH) $PATH
  
cd $BUILD_SCRIPTS_PATH      
