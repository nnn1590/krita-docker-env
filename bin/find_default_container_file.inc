#!/bin/bash

if groups | grep docker > /dev/null 2>&1; then
    DOCKER_BINARY=docker
else
    DOCKER_BINARY=sudo docker
fi

function findContainerName {
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    container_file=`${DIR}/find_up ./ -name .container_name`

    if [ ! -z ${container_file} ]; then
        cat ${container_file}
    fi
}

function parseContainerArgs {
    container_name=

    if [ "$#" -ne 1 ]; then
        if [ "$#" -eq 0 ]; then
            DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
            container_name=$(findContainerName)
        fi

        if [ -z ${container_name} ]; then
            echo "Usage: $0 CONTAINER_NAME" >&2
            exit 1
        fi
    else
        container_name=$1
    fi
    echo ${container_name}
}

function tryStartContainer {
    container_name=$1

    container_id=$(${DOCKER_BINARY} ps -q -f "status=running" -f "name=$container_name")

    if [ -z ${container_id} ]; then
        ${DOCKER_BINARY} start ${container_name}
    fi
}
