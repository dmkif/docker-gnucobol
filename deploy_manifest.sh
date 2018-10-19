#!/bin/bash
#Login to DockerHub 
echo "$DOCKER_PASSWORT" | docker login -u "$DOCKER_USER" --password-stdin
manifestname="$REPO:$PUBTAG"
manifeststring=$manifestname

for platform in $ARCH
do
echo $platform
#get latest image
docker pull $REPO:$platform-$TRAVIS_BUILD_NUMBER
#build manifest
manifeststring="$manifeststring $REPO:$platform-$TRAVIS_BUILD_NUMBER"
done;

docker manifest create $manifeststring
for platform in $ARCH
do
#annotate manifest with correct arch
case $ARCH in
    i386) qemu_arch=$ARCH 
          go_arch="386"
          ;;
    amd64) qemu_arch="x86_64" 
           go_arch=$ARCH
          ;;
    arm32v7) qemu_arch="arm" 
             go_arch="arm"
          ;;
    arm64v8) qemu_arch="aarch64" 
             go_arch="arm64"
          ;;
    ppc64el) qemu_arch="ppc64le" 
             go_arch="ppc64le"
          ;;
    *) qemu_arch=$ARCH
       go_arch=$ARCH
       ;;
esac

   
docker manifest annotate --arch=$go_arch $manifestname $REPO:$platform-$TRAVIS_BUILD_NUMBER
done;

docker manifest inspect "${REPO}:${PUBTAG}"
docker manifest push -p "${REPO}:${PUBTAG}"
docker logout
