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


######################
echo "Configuring SSH"
eval $(ssh-agent -s)
test "$GIT_SSH_USER_PRIVATE_KEY" && (echo "$GIT_SSH_USER_PRIVATE_KEY" | tr -d '\r' | ssh-add -)
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "$GIT_SSH_USER_PUBLIC_KEY" >> ~/.ssh/id_rsa.pub
echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config
git config user.name $GITLAB_USER_LOGIN
git config user.email $GITLAB_USER_EMAIL
######################

ALLOWED_DIRS=(src examples diagrams)
ALLOWED_FILES=(.gitignore .gitallowed package.json package-lock.json README.md tsconfig.json)

echo "Setting git origin"
git remote rm origin && git remote add origin git@github.com:f5devcentral/f5-bigip-runtime-init.git
echo "Removing everything from git"
git rm -rf .

echo "Adding allowed directories"
for dir in "${ALLOWED_DIRS[@]}"; do
    git checkout HEAD dir
done

echo "Adding allowed files"
for file in "${ALLOWED_FILES[@]}"; do
    git checkout HEAD file
done

git status
git add -f .
git commit -m "Release commited to $CI_COMMIT_REF_NAME tag" || echo "No changes, nothing to commit!"
git push -f origin HEAD:develop

