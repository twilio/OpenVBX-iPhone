#!/bin/sh

cd `dirname $0`

SETTINGS_PLIST=`pwd`/Settings.bundle/Root.plist

agvtool bump

MARKETING_VERSION=`agvtool what-marketing-version -terse | grep OpenVBX | sed "s/[^=]*=//"`
BUILD_NUMBER=`agvtool what-version -terse`
REV=`svnversion -n`

VERSION_STRING="$MARKETING_VERSION.$BUILD_NUMBER.$REV"

echo "Version: $VERSION_STRING"

# PlistBuddy makes it easy for us to edit nested values w/in plists.  It seems to come
# standard with Mac OS X, but maybe it comes from the Dev Tools.  Not sure.
/usr/libexec/PlistBuddy -c "Set PreferenceSpecifiers:1:DefaultValue $VERSION_STRING" Settings.bundle/Root.plist
