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
REPODIR="${DIR}/repo"
REPODB="${REPODIR}/${REPONAME}.db"

[ ! -d "${REPODIR}" ] && mkdir "${REPODIR}"
if [ -f "${REPODB}" ]; then
    echo "Cleaning the current repository database"

    rm "${REPODB}"
    rm "${REPODB}.tar.gz"
    rm "${REPODIR}/${REPONAME}.files"
    rm "${REPODIR}/${REPONAME}.files.tar.gz"
fi

for PKGDIR in ${DIR}/pkg/*; do
    if [ ! -f "${PKGDIR}/PKGBUILD" ]; then
        continue
    fi

    PKGNAME=$(cat "${PKGDIR}/PKGBUILD" | grep "^pkgname=" | awk -F'=' '{print $2}')
    PKGVER=$(cat "${PKGDIR}/PKGBUILD" | grep "^pkgver=" | awk -F'=' '{print $2}')
    PKGREL=$(cat "${PKGDIR}/PKGBUILD" | grep "^pkgrel=" | awk -F'=' '{print $2}')

    PKGID="${PKGNAME}-${PKGVER}-${PKGREL}"

    # TODO: Support other architectures
    if [ ! -f "${REPODIR}/${PKGID}-any.pkg.tar.xz" ] &&
       [ ! -f "${REPODIR}/${PKGID}-x86_64.pkg.tar.xz" ]; then
        echo "Making ${PKGID}..."
        cd "${PKGDIR}"
        makepkg -Csrf --noconfirm

        if [ -f ${REPODIR}/${PKGNAME}-*.pkg.tar.xz ]; then
            echo "Removing the old versions of ${PKGNAME}..."
            rm ${REPODIR}/${PKGNAME}-*.pkg.tar.xz
        fi

        for PKGFILE in ${PKGDIR}/${PKGID}-*.pkg.tar.xz; do
            cp ${PKGFILE} "${REPODIR}/"
        done
    fi
done

for PKGFILE in ${REPODIR}/*.pkg.tar.xz; do
    echo "Registering ${PKGFILE}"
    repo-add "${REPODB}.tar.gz" "${PKGFILE}"
done

rm "${REPODB}"
cp "${REPODB}.tar.gz" "${REPODB}"

if [ -f "${REPODB}.tar.gz.old" ]; then
    rm "${REPODB}.tar.gz.old"
    rm "${REPODIR}/${REPONAME}.files.tar.gz.old"
fi

echo "Recommended release tag: " $(date +%Y-%m-%d_%H-%M-%S)
