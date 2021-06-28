USERS_FILES=${HOME_PATH}/cms ${HOME_PATH}/atlas

CMS_UID=1000
CMS_GID=1000
ATLAS_UID=1001
ATLAS_GID=1001

users: ${ETC_PATH}/group ${ETC_PATH}/gshadow ${ETC_PATH}/passwd ${ETC_PATH}/shadow${HOME_PATH}/cms ${HOME_PATH}/atlas 
	# setup cms account
	sudo chown ${CMS_UID}:${CMS_GID} ${HOME_PATH}/cms
	sudo chmod u+wX ${HOME_PATH}/cms
	# setup atlas account
	sudo chown ${ATLAS_UID}:${ATLAS_GID} ${HOME_PATH}/atlas
	sudo chmod u+wX ${HOME_PATH}/atlas
