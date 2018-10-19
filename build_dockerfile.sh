#!/bin/bash
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

sed s/"@@ARCH_2@@"/"$goarch"/g Dockerfile > Dockerfile.$ARCH
sed -i s/"@@ARCH@@"/"$ARCH"/g Dockerfile.$ARCH

