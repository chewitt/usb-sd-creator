#!/bin/bash
# Install dependencies and build a static Qt 6 for LibreELEC USB-SD Creator.
# Produces a self-contained Qt prefix that eliminates runtime Qt package dependencies.
#
# Environment variables (all optional):
#   QT_VERSION   - Qt version to build (default: 6.7.2)
#   QT_PREFIX    - installation prefix (default: /opt/qt6-static)
#   QT_SRCDIR    - temporary directory for sources/build (default: /tmp/qt-build)
#   PARALLEL     - parallel build jobs (default: nproc)

set -euo pipefail

QT_VERSION="${QT_VERSION:-6.7.2}"
QT_MAJOR_MINOR="${QT_VERSION%.*}"
QT_PREFIX="${QT_PREFIX:-/opt/qt6-static}"
QT_SRCDIR="${QT_SRCDIR:-/tmp/qt-build}"
PARALLEL="${PARALLEL:-$(nproc)}"

# -- install dependencies --

sudo apt-get update
sudo apt-get install -y \
    build-essential cmake ninja-build curl xz-utils \
    libfontconfig1-dev libfreetype-dev \
    libx11-dev libx11-xcb-dev libxext-dev libxfixes-dev \
    libxi-dev libxrender-dev libxcb1-dev \
    libxcb-cursor-dev libxcb-glx0-dev libxcb-icccm4-dev \
    libxcb-image0-dev libxcb-keysyms1-dev libxcb-randr0-dev \
    libxcb-render-util0-dev libxcb-shape0-dev libxcb-shm0-dev \
    libxcb-sync-dev libxcb-xfixes0-dev libxcb-xinerama0-dev \
    libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev \
    libssl-dev libdbus-1-dev \
    libgl-dev \
    libatspi2.0-dev

echo "CC=gcc" >> "$GITHUB_ENV"
echo "CXX=g++" >> "$GITHUB_ENV"
echo "CMAKE_PREFIX_PATH=${QT_PREFIX}" >> "$GITHUB_ENV"

# -- download Qt sources --

QT_DOWNLOAD_BASE="https://download.qt.io/archive/qt/${QT_MAJOR_MINOR}/${QT_VERSION}/submodules"

mkdir -p "$QT_SRCDIR"
cd "$QT_SRCDIR"

for module in qtbase qttools; do
    tarball="${module}-everywhere-src-${QT_VERSION}.tar.xz"
    if [ ! -d "${module}-everywhere-src-${QT_VERSION}" ]; then
        echo "Downloading ${module}..."
        curl -sSL "${QT_DOWNLOAD_BASE}/${tarball}" -o "${tarball}"
        tar xJf "${tarball}"
        rm "${tarball}"
    fi
done

# -- build qtbase --

echo "=== Building qtbase ==="
cd "${QT_SRCDIR}/qtbase-everywhere-src-${QT_VERSION}"

./configure \
    -static \
    -release \
    -prefix "$QT_PREFIX" \
    -opensource -confirm-license \
    -nomake examples \
    -nomake tests \
    -xcb \
    -fontconfig \
    -system-freetype \
    -openssl-linked \
    -dbus-linked \
    -qt-libpng \
    -qt-libjpeg \
    -optimize-size

cmake --build . --parallel "$PARALLEL"
cmake --install .

# -- build qttools (provides lrelease for translations) --

echo "=== Building qttools ==="
cd "${QT_SRCDIR}/qttools-everywhere-src-${QT_VERSION}"

"${QT_PREFIX}/bin/qt-configure-module" . -- \
    -DCMAKE_DISABLE_FIND_PACKAGE_Clang=TRUE \
    -DCMAKE_DISABLE_FIND_PACKAGE_WrapLibClang=TRUE \
    -DFEATURE_assistant=OFF \
    -DFEATURE_designer=OFF \
    -DFEATURE_distancefieldgenerator=OFF \
    -DFEATURE_pixeltool=OFF \
    -DFEATURE_qdoc=OFF
cmake --build . --parallel "$PARALLEL"
cmake --install .

# -- cleanup --

rm -rf "$QT_SRCDIR"

echo ""
echo "Static Qt ${QT_VERSION} installed to ${QT_PREFIX}"
