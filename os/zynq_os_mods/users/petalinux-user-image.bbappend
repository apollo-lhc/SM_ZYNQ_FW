# petalinux-user-image.bbappend content
inherit extrausers
EXTRA_USERS_PARAMS = "\
usermod -P root root; \
"
