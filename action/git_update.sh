#!/bin/sh

VERSION=""

# get parameters
while getopts v: flag
do
  case "$flag" in
    v) VERSION="$OPTARG";;
  esac
done

# get highest tag number, and add v0.1.0 if it doesn't exist
git fetch --prune --unshallow 2>/dev/null
CURRENT_VERSION=$(git describe --abbrev=0 --tags 2>/dev/null)

if [ -z "$CURRENT_VERSION" ]
then
    CURRENT_VERSION='v0.1.0'
fi
echo "Current Version: $CURRENT_VERSION"

# replace . with space so it can be split into an array
CURRENT_VERSION_PARTS=$(echo "$CURRENT_VERSION" | tr '.' ' ')

# get number parts
VNUM1=$(echo "$CURRENT_VERSION_PARTS" | cut -d' ' -f1)
VNUM2=$(echo "$CURRENT_VERSION_PARTS" | cut -d' ' -f2)
VNUM3=$(echo "$CURRENT_VERSION_PARTS" | cut -d' ' -f3)

if [ "$VERSION" = 'major' ]
then
  VNUM1=$((VNUM1+1))
elif [ "$VERSION" = 'minor' ]
then
  VNUM2=$((VNUM2+1))
elif [ "$VERSION" = 'patch' ]
then
  VNUM3=$((VNUM3+1))
else
  echo "No version type (https://semver.org/) or incorrect type specified, try: -v [major, minor, patch]"
  exit 1
fi

# create a new tag
NEW_TAG="$VNUM1.$VNUM2.$VNUM3"
echo "($VERSION) updating $CURRENT_VERSION to $NEW_TAG"

# get the current hash and see if it already has a tag
GIT_COMMIT=$(git rev-parse HEAD)
NEEDS_TAG=$(git describe --contains "$GIT_COMMIT" 2>/dev/null)

# only tag if no tag already
if [ -z "$NEEDS_TAG" ]; then
  echo "Tagged with $NEW_TAG"
  git tag "$NEW_TAG"
  git push --tags
  git push
else
  echo "Already a tag on this commit"
fi

echo ::set-output name=new-version::$NEW_TAG

exit 0
