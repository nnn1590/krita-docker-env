#!/bin/bash

usage=\
"Usage: $(basename "$0") [OPTION]...\n
Build Krita AppImage\n
\n
where:\n
    -h,      --help              show this help text\n
    -jN,     --jobs=N            use N parallel jobs, default value is \`nproc\`\n
             --debug             include debugging information into AppImage\n
                                 (off by default)\n
"

INCLUDE_DEBUG_SYMBOLS=0
JOBS=`nproc`

# Call getopt to validate the provided input. 
options=$(getopt -o j:h --long debug,jobs:,help -- "$@")
[ $? -eq 0 ] || { 
    echo "Incorrect options provided"
    exit 1
}
eval set -- "$options"
while true; do
    case "$1" in
    --debug)
        INCLUDE_DEBUG_SYMBOLS=1
        ;;
    -j | --jobs)
        shift;
        JOBS=$1
        ;;
    -h | --help)
        echo -e $usage >&2
        exit 1
        ;;
    --)
        shift
        break
        ;;
    esac
    shift
done

if [ $INCLUDE_DEBUG_SYMBOLS -eq 0 ]; then
    export STRIP_APPIMAGE=1
fi

(
    echo "### Building krita..."
    cd ~/appimage-workspace/krita-build
    make -j$JOBS install || exit 1
)

echo "### Building AppImage..."

cd ~/appimage-workspace
~/persistent/krita/packaging/linux/appimage/build-image.sh ~/appimage-workspace/ ~/persistent/krita || exit 2

echo "### Move AppImage to persistent location:" `ls ~/appimage-workspace/*.appimage`
mv ~/appimage-workspace/*.appimage ~/persistent/ || exit 3

echo "### Clean up build directory..."
rm -rf ~/appimage-workspace/krita.appdir/* || exit 4

(
    echo "### Repopulate build directory..."
    cd ~/appimage-workspace/krita-build
    make -j$JOBS install/fast > /dev/null || exit 5
)
