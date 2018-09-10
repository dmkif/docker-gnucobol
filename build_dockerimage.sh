#!/bin/sh
#Export TAG
if [ $TRAVIS_PULL_REQUEST="false" ] && [ $TRAVIS_BRANCH="master" ] 
then 
	export TAG="latest"
else 
	export TAG=$TRAVIS_BRANCH
fi
echo "Set TAG to $TAG"

#Build dockerimage 
travis_wait 60 docker build --compress --squash -t "${REPO}:${ARCH}-${TAG}" -f Dockerfile."${ARCH}" .
