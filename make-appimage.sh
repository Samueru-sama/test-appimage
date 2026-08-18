#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q webapp-manager | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/webapp-manager.svg
export DESKTOP=/usr/share/applications/webapp-manager.desktop
export DEPLOY_PYTHON=1
export PATH_MAPPING='
	/usr/share/webapp-manager:${SHARUN_DIR}/share/webapp-manager
	/usr/share/locale:${SHARUN_DIR}/share/locale
'

# Deploy dependencies
quick-sharun \
	/usr/bin/webapp-manager   \
	/usr/lib/webapp-manager   \
	/usr/share/webapp-manager \
	/usr/lib/libgtk-3.so*     \
	/usr/lib/libxapp.so* # is this needed?
sed -i -e 's|/usr|"$APPDIR"|g' ./AppDir/bin/webapp-manager

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
