export GO_EASY_ON_ME = 1

ARCHS = armv7 arm64
TARGET = iphone:clang::8.1
SDKVERSION = 8.1

include /var/theos/makefiles/common.mk

PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

TWEAK_NAME = Helius2
Helius2_FILES = Tweak.xm Helius.m UIImageAverageColorAddition.m UIColor+ContrastingColor.m SBBlurryArtworkView.m
Helius2_FRAMEWORKS = UIKit Foundation CoreFoundation CoreGraphics QuartzCore CoreText MediaPlayer
Helius2_PRIVATE_FRAMEWORKS = MediaRemote Celestial
ADDITIONAL_OBJCFLAGS = -fobjc-arc

SUBPROJECTS = heliussettings

include /var/theos/makefiles/tweak.mk
include /var/theos/makefiles/aggregate.mk

after-install::
	install.exec "killall -9 backboardd"

after-stage::
	$(ECHO_NOTHING)mkdir -p "$(THEOS_STAGING_DIR)/Library/Application Support/Helius2"$(ECHO_END)
	$(ECHO_NOTHING)cp -r /var/root/Projects/Helius/Support/* "$(THEOS_STAGING_DIR)/Library/Application Support/Helius2"$(ECHO_END)