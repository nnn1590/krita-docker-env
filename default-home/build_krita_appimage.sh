#!/bin/bash

(
    echo "### Building krita..."
    cd ~/appimage-workspace/krita-build
    make -j8 install || exit 1
)

echo "### Building AppImage..."
~/persistent/krita/packaging/linux/appimage/build-image.sh ~/appimage-workspace/ ~/persistent/krita || exit 2

echo "### Move AppImage to persistent location:" `ls ~/appimage-workspace/*.appimage`
mv ~/appimage-workspace/*.appimage ~/persistent/ || exit 3

echo "### Clean up build directory..."
rm -rf ~/appimage-workspace/krita.appdir/* || exit 4

(
    echo "### Repopulate build directory..."
    cd ~/appimage-workspace/krita-build
    make -j8 install/fast > /dev/null || exit 5
)
