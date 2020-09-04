#!/usr/bin/env bash


# Script is to be used during release time to process github release
# run script passing the following arguments:
if [ -z "$1" ]
then
    echo 'Git tag parameter is required'
    exit 1;
fi

GIT_TAG=$1

echo "Cloning projects"
# Create temp dir
mkdir -p ./release/github/ && cd ./release/github/
git clone git@github.com:f5devcentral/f5-bigip-runtime-init.git
find . ! -name .git -delete
cd ../../
pwd
ls -la
ls -la ./release/github/f5-bigip-runtime-init/
cp -R ./src ./release/github/f5-bigip-runtime-init/
cp -R ./examples ./release/github/f5-bigip-runtime-init/
cp .gitignore ./release/github/f5-bigip-runtime-init/
cp package.json ./release/github/f5-bigip-runtime-init/
cp package-lock.json ./release/github/f5-bigip-runtime-init/
cp README.md ./release/github/f5-bigip-runtime-init/
cp tsconfig.json ./release/github/f5-bigip-runtime-init/

cd ./release/github/f5-bigip-runtime-init/
ls -la
git status
#git add .
#git commit -a -m"View release notes for $GIT_TAG"
#echo "Adding tag $GIT_TAG"
#git tag -a -m"Release $GIT_TAG" $GIT_TAG

