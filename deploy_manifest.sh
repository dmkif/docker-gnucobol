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
    i386) goarch="386" 
          ;;
    arm32v7) goarch="arm"
           ;;
    arm64v8) goarch="arm64"
             ;;
    *) goarch=$ARCH
       ;;
esac

   
docker manifest annotate --arch=$goarch $manifestname $REPO:$platform-$TRAVIS_BUILD_NUMBER
done;

docker manifest inspect "${REPO}:${PUBTAG}"
docker manifest push -p "${REPO}:${PUBTAG}"
docker logout
