# petalinux-user-image.bbapend content
inherit extrausers
EXTRA_USERS_PARAMS = "\
usermod -P root root ; \
useradd -P cms cms ; \
useradd -P atlas atlas ; \
useradd -P mDwwMcxtqa6pY9ZG http ; \
useradd -P GJF4hXrtDtDSbKPf xvc ; \
"
