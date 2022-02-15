#!/bin/bash
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
cd "$DIR"

REPODIR="${DIR}/repo"

[ ! -d "${REPODIR}" ] && mkdir "${REPODIR}"
for PKGDIR in ${DIR}/pkg/*; do
    if [ ! -f "${PKGDIR}/PKGBUILD" ]; then
        continue
    fi

    PKGNAME=$(cat "${PKGDIR}/PKGBUILD" | grep "^pkgname=" | awk -F'=' '{print $2}')
    PKGVER=$(cat "${PKGDIR}/PKGBUILD" | grep "^pkgver=" | awk -F'=' '{print $2}')
    PKGREL=$(cat "${PKGDIR}/PKGBUILD" | grep "^pkgrel=" | awk -F'=' '{print $2}')
    PKGARCHES=$(grep "^arch=" "${PKGDIR}/PKGBUILD" | sed -e 's/^arch=//g' -e 's/[\(\)]//g' -e 's/'\''//g')

    PKGID="${PKGNAME}-${PKGVER}-${PKGREL}"

    for PKGARCH in ${PKGARCHES}; do
        PACKAGE_FILE_NAME="${PKGID}-${PKGARCH}.pkg.tar.zst"

        if [ ! -f "${REPODIR}/${PACKAGE_FILE_NAME}" ]; then
            echo "Making ${PKGID} for ${PKGARCH}..."
            cd "${PKGDIR}"
            CARCH="${PKGARCH}" makepkg -Csrf --noconfirm

            [ -f "${REPODIR}/${PACKAGE_FILE_NAME}" ] && rm "${REPODIR}/${PACKAGE_FILE_NAME}"

            cp "${PKGDIR}/${PACKAGE_FILE_NAME}" "${REPODIR}/${PACKAGE_FILE_NAME}"
        fi
    done

    # Remove the builds for other versions
    for REPO_PACKAGE in $(find "${REPODIR}" -name "${PKGNAME}-*" | grep -v "/${PKGID}"); do
        echo "Removing ${REPO_PACKAGE}..."
        rm "${REPO_PACKAGE}"
    done

    # Remove the builds for architectures that are not supported in the current version
    for REPO_PACKAGE in $(find "${REPODIR}" -name "${PKGID}-*" | grep -v "\(${PKGARCHES// /\\\|}\).pkg.tar.zst"); do
        echo "Removing ${REPO_PACKAGE}..."
        rm "${REPO_PACKAGE}"
    done
done

REPO_NAME="hmlendea"

for ARCH in "any" "aarch64" "armv7h" "i686" "x86_64"; do
    REPODB_NAME="${REPO_NAME}-${ARCH}"
    REPODB_PATH="${REPODIR}/${REPODB_NAME}.db"

    if [ -f "${REPODB_PATH}" ]; then
        echo "Cleaning the current repository database"

        rm "${REPODB_PATH}"
        rm "${REPODB_PATH}.tar.gz"
        rm "${REPODIR}/${REPODB_NAME}.files"
        rm "${REPODIR}/${REPODB_NAME}.files.tar.gz"
    fi

    for PKGFILE in ${REPODIR}/*-${ARCH}.pkg.tar.zst; do
        echo "Registering ${PKGFILE} into ${REPODB_NAME}"
        repo-add "${REPODB_PATH}.tar.gz" "${PKGFILE}"
    done

    rm "${REPODB_PATH}"
    cp "${REPODB_PATH}.tar.gz" "${REPODB_PATH}"

    if [ -f "${REPODB_PATH}.tar.gz.old" ]; then
        rm "${REPODB_PATH}.tar.gz.old"
        rm "${REPODIR}/${REPODB_NAME}.files.tar.gz.old"
    fi
done

echo "Recommended release tag: " $(date +%Y-%m-%d_%H-%M-%S)
