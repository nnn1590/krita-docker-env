#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/find_default_container_file.inc

container_name=$(parseContainerArgs $*)
if [ -z ${container_name} ]; then
    exit 1
fi

tryStartContainer $container_name

${DOCKER_BINARY} exec -ti ${container_name} mkdir -p /home/appimage/.config/QtProject/
${DOCKER_BINARY} cp ~/.config/QtProject/QtCreator.ini ${container_name}:/home/appimage/.config/QtProject/QtCreator.ini

