#!/usr/bin/env bash


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

RELEASE_VERSION=$(echo $CI_COMMIT_REF_NAME | awk -F"-" '{ print $2 }')
RELEASE_BUILD=$(echo $CI_COMMIT_REF_NAME | awk -F"-" '{ print $3 }')
ALLOWED_DIRS=(src examples diagrams)
ALLOWED_FILES=(.gitignore .gitallowed package.json package-lock.json README.md tsconfig.json)

echo "Setting git origin"
git remote rm origin && git remote add origin git@github.com:f5devcentral/f5-bigip-runtime-init.git
echo "Removing everything from git"
git rm -rf .

echo "Adding allowed directories"
for dir in "${ALLOWED_DIRS[@]}"; do
    git checkout HEAD ${dir}
    git add ${dir}
done

echo "Adding allowed files"
for file in "${ALLOWED_FILES[@]}"; do
    git checkout HEAD ${file}
    git add ${file}
done

echo "Committing source code"
git status
git commit -m "Release commited to $RELEASE_VERSION tag" || echo "No changes, nothing to commit!"
git push -f origin HEAD:develop

echo "Publishing tag"
git tag -d $(git tag -l)
git tag -a $RELEASE_VERSION -m "Release of version $RELEASE_VERSION"
git push --tags


echo "Creating release"
git config --global github.token $GIT_HUB_API_TOKEN_AK

echo "Getting release info"
release_description=$(curl --header "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN_AK" "https://gitlab.example.com/api/v4/projects/24/releases/$CI_COMMIT_REF_NAME" | jq .description)

version=$RELEASE_VERSION
text="This is test Release for Runtime Init"

generate_post_data()
{
  cat <<EOF
{
  "tag_name": "$version",
  "target_commitish": "develop",
  "name": "$version",
  "body": "$release_description",
  "draft": false,
  "prerelease": false
}
EOF
}

echo "Create release $version"
curl -X POST -d "$(generate_post_data)" "https://api.github.com/repos/f5devcentral/f5-bigip-runtime-init/releases?access_token=$GIT_HUB_API_TOKEN_AK"

