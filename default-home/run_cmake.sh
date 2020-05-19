#!/bin/bash

cmake -DCMAKE_INSTALL_PREFIX=${KRITADIR} \
      -DCMAKE_BUILD_TYPE=Debug \
      -DKRITA_DEVS=ON \
      -DBUILD_TESTING=TRUE \
      -DHIDE_SAFE_ASSERTS=FALSE \
      -DPYQT_SIP_DIR_OVERRIDE=~/appimage-workspace/deps/usr/share/sip \
      $@
