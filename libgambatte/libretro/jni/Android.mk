LOCAL_PATH := $(call my-dir)

ROOT_DIR     := $(LOCAL_PATH)/../../..
CORE_DIR     := $(ROOT_DIR)/libgambatte/src
LIBRETRO_DIR := $(ROOT_DIR)/libgambatte/libretro

HAVE_NETWORK := 1

include $(ROOT_DIR)/Makefile.common

COREFLAGS := -DINLINE=inline -DHAVE_STDINT_H -DHAVE_INTTYPES_H -D__LIBRETRO__ -DVIDEO_RGB565 -DCC_RESAMPLER_NO_HIGHPASS -Wno-c++11-narrowing

ifeq ($(HAVE_NETWORK),1)
  COREFLAGS += -DHAVE_NETWORK
endif

GIT_VERSION := " $(shell git rev-parse --short HEAD || echo unknown)"
ifneq ($(GIT_VERSION)," unknown")
  COREFLAGS += -DGIT_VERSION=\"$(GIT_VERSION)\"
endif

# ff-bgm1x: 연결 코드 (C++17, 본체와 따로 빌드)
include $(CLEAR_VARS)
LOCAL_MODULE    := ffbgm
LOCAL_SRC_FILES := $(LIBRETRO_DIR)/ff_bgm1x_gb.cpp $(LIBRETRO_DIR)/ffbgm/gb_driver_bgm.cpp $(LIBRETRO_DIR)/ffbgm/gsc_player.cpp                    $(LIBRETRO_DIR)/ffbgm/gb_driver_generic.cpp $(LIBRETRO_DIR)/ffbgm/gb_shadow_cpu.cpp \
                   $(LIBRETRO_DIR)/ffbgm/sound_catalog.cpp $(LIBRETRO_DIR)/ffbgm/catalog_command.cpp
LOCAL_CPPFLAGS  := $(COREFLAGS) $(INCFLAGS) -std=c++17
LOCAL_C_INCLUDES := $(ROOT_DIR)/libgambatte/include $(LIBRETRO_DIR)/ffbgm
include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE    := retro
LOCAL_SRC_FILES := $(SOURCES_CXX) $(SOURCES_C)
LOCAL_CXXFLAGS  := $(COREFLAGS) $(INCFLAGS)
LOCAL_CFLAGS    := $(INCFLAGS)
LOCAL_LDFLAGS   := -Wl,-version-script=$(LIBRETRO_DIR)/link.T
LOCAL_STATIC_LIBRARIES := ffbgm
include $(BUILD_SHARED_LIBRARY)
