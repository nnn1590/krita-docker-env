# Krita developer environment Docker image

This *Dockerfile* is based on the official KDE build environmet [0]
that in used on KDE CI for building official AppImage packages.
Therefore running this image in a docker container is the best way
to reproduce AppImage-only bugs in Krita.

[0] - https://binary-factory.kde.org/job/Krita_Nightly_Appimage_Dependency_Build/

## Prerequisites

Firstly make sure you have Docker installed

```bash
sudo apt install docker docker.io
```

Then you need to download deps and Krita source tree. These steps are not
included into the *Dockerfile* to save internal bandwidth (most Krita
developers already have al least one clone of Krita source tree).

```bash
# create directory structure for container control directory
git clone https://invent.kde.org/dkazakov/krita-docker-env.git krita-auto-1

cd krita-auto-1
mkdir persistent

# copy/chechout Krita sources to 'persistent/krita'
cp -r /path/to/sources/krita ./persistent/krita

## or ...
# git clone kde:krita persistent/krita

# download the deps archive
./bin/bootstrap-deps.sh
```

## Build the docker image and run the container

```bash
./bin/build_image krita-deps
./bin/run_container krita-deps krita-auto-1
```

## Enter the container and build Krita

```bash
# enter the docker container (the name will be
# fetched automatically from '.container_name' file)

./bin/enter

# ... now your are inside the container with all the deps prepared ...

# build Krita as usual
cd appimage-workspace/krita-build/
run_cmake.sh ~/persistent/krita
make -j8 install

# start Krita
krita

```

## Building AppImage package for your version of Krita

If you want to build a portable package for your version of Krita, just enter
the container and type:

```bash
run_cmake.sh ~/persistent/krita
~/bin/build_krita_appimage.sh
```

The built package will be copied to `./persistent/` folder.

By default, the package will be built in release mode. If you want to
add debugging information, add `--debug` option to the command line:

```bash
~/bin/build_krita_appimage.sh --debug
```

## Creating a full clone of the container

It is possible to copy the container with the entire environment, sources,
build directory and QtCreator installation and configuration. After cloning,
no rebuild of Krita is needed!

To copy container to `../krita-auto-2`, just type in the host system

```bash
./bin/spawn-clone -d ../krita-auto-2
```

`spawn-clone` will make an image from the current container and create a
new one out of it. This image will be cached for further usages. If you need 
to flush the cache, pass '-f' option to `spawn-clone`:

```bash
./bin/spawn-clone -f -d ../krita-auto-2
```

You can start several instances of `spawn-clone` on the same container
concurrently (e.g. for building multiple merge requests). It has internal
locking mechanism for resolving concurrency problems

## Testing merge requests using container clones

To quickly build a merge request '123' basing on the current state of the 
container type in the host system

```bash
./bin/spawn-clone -m 123 -be
```

The script will clone the container, checkout the merge request branch,
build it and provide you a terminal for running Krita. The container 
will be created at `./clones/clone-mr-123` subfolder of the current container.

If you also want to build an AppImage, add '--release-appimage' option:

```bash
./bin/spawn-clone -m 123 --release-appimage -be
```

AppImage will be places at `./persistent` subfolder of the clone.

When finished with testing the merge request, you can remove the clone
completely by running

```bash
./bin/discard-clone /clones/clone-mr-123
```

You can build multiple merge requests at once!

## Extra developer tools

To install QtCreator, enter container and start the installer, downloaded while
fetching dependencies. Make sure you install it into '~/qtcreator' directory
without any version suffixes, then you will be able to use the script below:

```bash
# inside the container
./persistent/qt-creator-opensource-linux-x86_64.run
```

To start QtCreator:

```bash
# from the host
./bin/qtcreator
```

To copy your local QtCreator's config into the container:

```bash
# from the host
./bin/copy_qtcreator_config.sh
```

## Stopping the container and cleaning up

When not in use you can stop the container. All your filesystem state is saved, but
all the currently running processes are killed (just ensure you logout from all the
terminals before stopping).

```bash
# stop the container
./bin/stop

# start the container
./bin/start
```

If you don't need your container/image anymore, you can delete them from the docker

```bash
# remove the container
sudo docker rm krita-auto-1

# remove the image
sudo docker rmi krita-deps
```

TODO: do we need some extra cleaups for docker's caches?


## Troubleshooting

### Krita binary is not found after the first build

Either relogin to the container or just execute `source ~/.devenv.inc`

### OpenGL doesn't work on NVidia GPU with proprietary drivers

The docker run script automatically forwards the GPU devices into the container, but it
doesn't install the drivers for the GPU. You should install exactly the same version of
the driver that is installed on your host system. Just run the following script when you
are on host:

```bash
./bin/install_nvidia_drivers.sh
```

### Not enough space on root partition

All the docker images and containers are stored in a special docker-daemon controlled
folder under */var* directory. You might not have enough space there for building Krita
(it needs about 10 GiB). In such a case it is recommended to move the docker images
folder into another location, where there is enough space.

Add the following to `/etc/docker/daemon.json`:

```json
{
    "data-root" : "/home/devel5/docker"
}
```

If you have older version of OS (Ubuntu 16.04 and earlier), then you should 
do the following:

```bash
echo 'DOCKER_OPTS="-g /home/devel5/docker"' >> /etc/default/docker
```
