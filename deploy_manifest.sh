#!/bin/sh
#Login to DockerHub 
echo "$DOCKER_PASSWORT" | docker login -u "$DOCKER_USER" --password-stdin
manifestname="$REPO:$PUBTAG"
manifeststring=$manifestname

for platform in $ARCH
do
#get latest image
docker pull $REPO:$ARCH-$TRAVIS_BUILD_NUMBER
#build manifest
manifeststring="$manifeststring $REPO:$ARCH-$TRAVIS_BUILD_NUMBER"
done;

docker manifest create $manifeststring
for platform in $ARCH
do
#annotate manifest with correct arch
docker manifest annotate --arch=$platform --os=linux $manifestname $REPO:$ARCH-$TRAVIS_BUILD_NUMBER
done;

docker manifest inspect "${REPO}:${PUBTAG}"
docker manifest push -p "${REPO}:${PUBTAG}"
docker logout
