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

if [ -f "${DIR}/repo/${REPONAME}.db" ]; then
    echo "Cleaning the current repository database"

    rm "${DIR}/repo/${REPONAME}.db"
    rm "${DIR}/repo/${REPONAME}.db.tar.gz"
    rm "${DIR}/repo/${REPONAME}.files"
    rm "${DIR}/repo/${REPONAME}.files.tar.gz"
fi

for PKGDIR in pkg/*; do
    if [ ! -f "$PKGDIR/PKGBUILD" ]; then
        continue
    fi

    PKGNAME=$(cat "${PKGDIR}/PKGBUILD" | grep "^pkgname=" | awk -F'=' '{print $2}')
    PKGVER=$(cat "${PKGDIR}/PKGBUILD" | grep "^pkgver=" | awk -F'=' '{print $2}')
    PKGREL=$(cat "${PKGDIR}/PKGBUILD" | grep "^pkgrel=" | awk -F'=' '{print $2}')

    PKGID="${PKGNAME}-${PKGVER}-${PKGREL}"

    # TODO: Support other architectures
    if [ ! -f "repo/${PKGID}-any.pkg.tar.xz" ] &&
       [ ! -f "repo/${PKGID}-x86_64.pkg.tar.xz" ]; then
        cd ${PKGDIR}

        echo "Making ${PKGID}..."
        makepkg -Csrf --noconfirm

        echo "Removing the old versions of ${PKGNAME}..."
        rm ${DIR}/repo/${PKGNAME}-*.pkg.tar.xz

        for PKGFILE in ${PKGID}-*.pkg.tar.xz; do
            cp ${PKGFILE} "$DIR/repo/"
        done
    fi
done

cd ${DIR}

for PKGFILE in repo/*.pkg.tar.xz; do
    echo "Registering ${PKGFILE}"
    repo-add "repo/${REPONAME}.db.tar.gz" "${PKGFILE}"
done

rm "$DIR/repo/$REPONAME.db"
cp "$DIR/repo/$REPONAME.db.tar.gz" "$DIR/repo/$REPONAME.db"

if [ -f "${DIR}/repo/${REPONAME}.db.tar.gz.old" ]; then
    rm "${DIR}/repo/${REPONAME}.db.tar.gz.old"
    rm "${DIR}/repo/${REPONAME}.files.tar.gz.old"
fi

echo "Recommended release tag: " $(date +%Y-%m-%d_%H-%M-%S)
