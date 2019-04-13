#!/bin/bash
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
cd "$DIR"

REPONAME="hmlendea"

echo "Cleaning the current repository database"
rm -rf $DIR/repo/*

for PKGDIR in pkg/*; do
    if [ ! -f "$PKGDIR/PKGBUILD" ]; then
        continue
    fi

    cd $PKGDIR
    echo "Making package in $PKGDIR..."
    makepkg -Csrf --noconfirm

    PKGNAME=$(cat PKGBUILD | grep "^pkgname=" | awk -F'=' '{print $2}')
    PKGVER=$(cat PKGBUILD | grep "^pkgver=" | awk -F'=' '{print $2}')
    PKGREL=$(cat PKGBUILD | grep "^pkgrel=" | awk -F'=' '{print $2}')

    for PKGFILE in $PKGNAME-$PKGVER-$PKGREL-*.pkg.tar.xz; do
        echo "Registering $PKGFILE"
        cp $PKGFILE "$DIR/repo/"

        cd $DIR
        repo-add "repo/$REPONAME.db.tar.gz" "repo/$PKGFILE"
    done
done

rm "$DIR/repo/$REPONAME.db"
cp "$DIR/repo/$REPONAME.db.tar.gz" "$DIR/repo/$REPONAME.db"

if [ -f "$DIR/repo/*.old" ]; then
    rm "$DIR/repo/*.old"
fi

echo "Recommended release tag: " $(date +%Y-%m-%d_%H-%M-%S)
