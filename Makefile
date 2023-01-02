TARGET = iphone:clang:latest:13.0

ARCHS = arm64 arm64e

DEBUG = 0
FINALPACKAGE = 1

PREFIX=$(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

SYSROOT=$(THEOS)/sdks/iphoneos14.2.sdk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = VolVibes
$(TWEAK_NAME)_FILES = Tweak.xm
$(TWEAK_NAME)_EXTRA_FRAMEWORKS += Cephei
$(TWEAK_NAME)_FRAMEWORKS = UIKit
$(TWEAK_NAME)_LIBRARIES += sparkcolourpicker


include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Preferences && killall -9 SpringBoard"
SUBPROJECTS += volvibesprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

