#!/bin/bash
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
cd "$DIR"

REPONAME="horatiuml"

for D in `find ./ -maxdepth 1 -type d`
do
    if [ -f "$D/PKGBUILD" ]; then
        cd $D
        echo "Making package in $D..."
        makepkg -Csrf --noconfirm

        cd $DIR
        repo-add -n -R $REPONAME.db.tar.gz $D/*.tar.xz
    fi
done

echo "Recommended release tag: " $(date +%Y-%m-%d_%H-%M-%S)
