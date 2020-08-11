# petalinux-user-image.bbapend content
inherit extrausers
EXTRA_USERS_PARAMS = "\
usermod -P BbB5DG55 root ; \
useradd -P cms cms ; \
usermod -a -G dialout cms ; \
useradd -P atlas atlas ; \
usermod -a -G dialout atlas ; \
useradd -P pnVCE2vYffpqAbK3g7acpSGn http ; \
usermod -a -G dialout http ; \
useradd -P FSXPXKmBE7KdUjB64TP87qht xvc ; \
usermod -a -G dialout xvc ; \
"
