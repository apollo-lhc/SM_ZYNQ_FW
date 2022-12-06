APOLLO_UPDATER_BRANCH=v1.0.0
APOLLO_UPDATER_URI=https://gitlab.com/apollo-lhc/soc-tools/apollo-updater.git
APOLLO_UPDATER_NAME=apollo-updater

%/opt/${APOLLO_UPDATER_NAME}: OPT_PATH=$*/opt/

%/opt/${APOLLO_UPDATER_NAME}: %/opt/
	cd ${OPT_PATH} && \
		git clone --branch ${APOLLO_UPDATER_BRANCH} ${APOLLO_UPDATER_URI} ${APOLLO_UPDATER_NAME}
