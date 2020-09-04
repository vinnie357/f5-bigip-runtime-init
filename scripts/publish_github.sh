#!/usr/bin/env bash


# Script is to be used during release time to process github release
# run script passing the following arguments:
if [ -z "$1" ]
then
    echo 'Git tag parameter is required'
    exit 1;
fi

GIT_TAG=$1
echo "RELEASE TAG: $GIT_TAG"

echo "Configuring SSH"
eval $(ssh-agent -s)
test "$GIT_SSH_USER_PRIVATE_KEY" && (echo "$GIT_SSH_USER_PRIVATE_KEY" | tr -d '\r' | ssh-add -)
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "$GIT_SSH_USER_PUBLIC_KEY" >> ~/.ssh/id_rsa.pub
echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config
git config user.name $GITLAB_USER_LOGIN
git config user.email $GITLAB_USER_EMAIL

echo "Cloning projects"
# Create temp dir
mkdir -p ./release/github/ && cd ./release/github/
git clone git@github.com:f5devcentral/f5-bigip-runtime-init.git
echo 'Completed cloning github repo'
cd ./f5-bigip-runtime-init
find . ! -name .git -delete
cd ../../../
cp -R ./src ./release/github/f5-bigip-runtime-init/
cp -R ./examples ./release/github/f5-bigip-runtime-init/
cp -R ./diagrams ./release/github/f5-bigip-runtime-init/
cp .gitignore ./release/github/f5-bigip-runtime-init/
cp package.json ./release/github/f5-bigip-runtime-init/
cp package-lock.json ./release/github/f5-bigip-runtime-init/
cp README.md ./release/github/f5-bigip-runtime-init/
cp tsconfig.json ./release/github/f5-bigip-runtime-init/
cd ./release/github/f5-bigip-runtime-init/
pwd
ls -la
git remote rm origin && git remote add origin git@github.com:f5devcentral/f5-bigip-runtime-init.git
git status
git add -f .
git commit -m "Release commited to $CI_COMMIT_REF_NAME tag" || echo "No changes, nothing to commit!"
git push -f origin HEAD:develop

