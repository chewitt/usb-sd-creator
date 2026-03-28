#!/usr/bin/env bash

qtVersion='6.11.0'
qtVersionWithoutDots=${qtVersion//./}
qtTimestamp='202603180535'
qtBaseUrl="https://download.qt.io/online/qtsdkrepository/windows_x86/desktop/qt6_$qtVersionWithoutDots/qt6_${qtVersionWithoutDots}_msvc2022_64/qt.qt6.$qtVersionWithoutDots.win64_msvc2022_64"

cd ..
for module in base declarative tools ; do
  archive="$module.7z"
  curl -L -o "$archive" "$qtBaseUrl/$qtVersion-0-${qtTimestamp}qt$module-Windows-Windows_11_24H2-MSVC2022-Windows-Windows_11_24H2-X86_64.7z"
  7z x "$archive"
done

qtPrefix=$(find "$PWD" -name Qt6Config.cmake -path '*/lib/cmake/Qt6/*' -print -quit)
qtPrefix=${qtPrefix%/lib/cmake/Qt6/Qt6Config.cmake}
echo "CMAKE_PREFIX_PATH=$(cygpath -w "$qtPrefix")" >> $GITHUB_ENV
