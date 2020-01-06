#!/bin/bash
localedef --list-archive | grep -E -v "^en" | xargs localedef --delete-from-archive
cp /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl
build-locale-archive 

ls -p1d /usr/share/locale/*/  | grep -v "/en" | xargs rm -rf
