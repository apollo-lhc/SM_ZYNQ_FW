USERS_FILES=${HOME_PATH}/cms ${HOME_PATH}/atlas

CMS_UID=1000
CMS_GID=1000
ATLAS_UID=1001
ATLAS_GID=1001

users: ${ETC_PATH}/group ${ETC_PATH}/gshadow ${ETC_PATH}/passwd ${ETC_PATH}/shadow${HOME_PATH}/cms ${HOME_PATH}/atlas 
	sudo install                                 -m 774 ${MODS_PATH}/.bashrc       ${INSTALL_PATH}/root
	sudo install                                 -m 774 ${MODS_PATH}/.bash_profile ${INSTALL_PATH}/root
	sudo install -g ${CMS_UID}   -o ${CMS_GID}   -m 774 ${MODS_PATH}/.bashrc       ${HOME_PATH}/cms
	sudo install -g ${CMS_UID}   -o ${CMS_GID}   -m 774 ${MODS_PATH}/.bash_profile ${HOME_PATH}/cms
	sudo install -g ${CMS_UID}   -o ${CMS_GID}   -m 700 -d ${HOME_PATH}/cms/.screen
	sudo install -g ${ATLAS_UID} -o ${ATLAS_GID} -m 774 ${MODS_PATH}/.bashrc       ${HOME_PATH}/atlas
	sudo install -g ${ATLAS_UID} -o ${ATLAS_GID} -m 774 ${MODS_PATH}/.bash_profile ${HOME_PATH}/atlas
	sudo install -g ${ATLAS_UID} -o ${ATLAS_GID} -m 700 -d ${HOME_PATH}/cms/.screen
