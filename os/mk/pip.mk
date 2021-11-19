PIP_PACKAGES="pybind11"
#PIP_INSTALL_PATH=${INSTALL_PATH}usr/lib/python2.7/site-packages/
PIP_INSTALL_PATH=${INSTALL_PATH}usr/lib/python3.6/site-packages/
pip_install:
	sudo pip3 install --target=${PIP_INSTALL_PATH} ${PIP_PACKAGES}
	sudo pip3 install --upgrade "pip<21.0"
	sudo pip3 install --upgrade setuptools==42.0.1
	sudo pip3 install --force-reinstall importlib_metadata packaging click==7.1.2 click_didyoumean pytest==4.6.9

