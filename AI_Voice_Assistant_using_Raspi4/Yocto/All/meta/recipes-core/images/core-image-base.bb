SUMMARY = "A console-only image that fully supports the target device \
hardware."

IMAGE_FEATURES += "splash"

LICENSE = "MIT"

inherit core-image

inherit qt6-qmake qt6-cmake populate_sdk_qt6

