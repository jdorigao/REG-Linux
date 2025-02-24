################################################################################
#
# qt6
#
################################################################################
# reglinux -  bump
QT6_VERSION_MAJOR = 6.7
QT6_VERSION = $(QT6_VERSION_MAJOR).3
QT6_SOURCE_TARBALL_PREFIX = everywhere-src
QT6_SITE = https://download.qt.io/archive/qt/$(QT6_VERSION_MAJOR)/$(QT6_VERSION)/submodules

QT6_GIT = git://code.qt.io

include $(sort $(wildcard package/qt6/*/*.mk))
