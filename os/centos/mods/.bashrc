# .bashrc

# User specific aliases and functions

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

CACTUS_ROOT=/opt/cactus
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${CACTUS_ROOT}/lib
PATH=${PATH}:/opt/BUTool/bin:/opt/mcu_tools/bin/
BUTOOL_PLUGIN_PATH=/opt/BUTool/lib

BUTOOL_AUTOLOAD_LIBRARY_LIST=$(find ${BUTOOL_PLUGIN_PATH} | grep -v "~" |grep "Device\.so" | awk '{list=list":"$0}{print substr(list, 1)}')

export LD_LIBRARY_PATH
export PATH
export BUTOOL_AUTOLOAD_LIBRARY_LIST
export SCREENDIR=$HOME/.screen
