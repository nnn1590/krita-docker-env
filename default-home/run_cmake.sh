#!/bin/bash

cmake -DCMAKE_INSTALL_PREFIX=${KRITADIR} \
      -DCMAKE_BUILD_TYPE=Release \
      -DKRITA_DEVS=OFF \
      -DBUILD_TESTING=FALSE \
      -DHIDE_SAFE_ASSERTS=TRUE \
      -DPYQT_SIP_DIR_OVERRIDE=~/appimage-workspace/deps/usr/share/sip \
      $@
