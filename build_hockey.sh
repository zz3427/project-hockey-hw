# build_hockey.sh
# Gerald Zhao zz3427
# Purpose:
#   Run the original Quartus/Qsys build flow inside a temporary sandbox
#   directory so the real project folder stays clean.
#
#   1. Deletes any old temporary build sandbox.
#   2. Creates fresh .hockey_build/ and artifacts/ directories.
#   3. Copies the current project source files into .hockey_build/.
#   4. Runs the normal hardware build flow:
#        make qsys
#        make quartus
#        make rbf
#        make dtb   (after loading the embedded tools environment)
#   5. Copies only the final useful outputs back to artifacts/:
#        soc_system.rbf
#        soc_system.dtb
#        soc_system.dts (if generated)
#
# Run directly with ./build_hockey.sh or through "make hockey"
#
# Result:
#   - project source folder stays clean
#   - temporary junk lives in .hockey_build/
#   - final outputs are collected in artifacts/


#!/usr/bin/env bash
set -euo pipefail

SYSTEM="soc_system"
SRC_DIR="$(pwd)"
BUILD_ROOT="${SRC_DIR}/.hockey_build"
ARTIFACT_DIR="${SRC_DIR}/artifacts"

echo "[1/7] Cleaning old build sandbox"
rm -rf "${BUILD_ROOT}"
mkdir -p "${BUILD_ROOT}"
mkdir -p "${ARTIFACT_DIR}"

echo "[2/7] Copying source into sandbox"
rsync -a \
  --exclude '.git' \
  --exclude '.hockey_build' \
  --exclude 'artifacts' \
  --exclude 'db' \
  --exclude 'incremental_db' \
  --exclude 'output_files' \
  --exclude 'soc_system' \
  --exclude '*.qpf' \
  --exclude '*.qsf' \
  --exclude '*.sdc' \
  --exclude '*.sopcinfo' \
  --exclude '*.dts' \
  --exclude '*.dtb' \
  --exclude '*.rbf' \
  --exclude '.qsys_edit' \
  "${SRC_DIR}/" "${BUILD_ROOT}/"

cd "${BUILD_ROOT}"

echo "[3/7] Running Qsys generation"
make qsys

echo "[4/7] Running Quartus compile"
make quartus

echo "[5/7] Generating RBF"
make rbf

echo "[6/7] Generating DTB from existing sandbox"

if [ ! -d "${BUILD_ROOT}" ]; then
  echo "Error: sandbox ${BUILD_ROOT} does not exist"
  echo "Run the earlier build steps first."
  exit 1
fi

EMBEDDED_SHELL="$(find /tools/intel -name embedded_command_shell.sh -print -quit 2>/dev/null)"

if [ -z "${EMBEDDED_SHELL}" ]; then
  echo "Error: could not find embedded_command_shell.sh under /tools/intel"
  exit 1
fi

echo "[6.1/7] Using embedded shell: ${EMBEDDED_SHELL}"
echo "[6.2/7] Working in: ${BUILD_ROOT}"
echo "[6.3/7] Open the embedded shell manually if this fails"

echo "[6.4/7] Running DTB build in one command"
bash -lc 'cd "'"${BUILD_ROOT}"'" && "'"${EMBEDDED_SHELL}"'" <<'\''EOS'\''
make dtb
exit
EOS'

echo "[7/7] Copying artifacts back"
mkdir -p "${ARTIFACT_DIR}"

if [ -f "${BUILD_ROOT}/output_files/${SYSTEM}.rbf" ]; then
  cp -f "${BUILD_ROOT}/output_files/${SYSTEM}.rbf" "${ARTIFACT_DIR}/${SYSTEM}.rbf"
  echo "Copied ${ARTIFACT_DIR}/${SYSTEM}.rbf"
else
  echo "Warning: ${BUILD_ROOT}/output_files/${SYSTEM}.rbf not found"
fi

if [ -f "${BUILD_ROOT}/${SYSTEM}.dtb" ]; then
  cp -f "${BUILD_ROOT}/${SYSTEM}.dtb" "${ARTIFACT_DIR}/${SYSTEM}.dtb"
  echo "Copied ${ARTIFACT_DIR}/${SYSTEM}.dtb"
else
  echo "Warning: ${BUILD_ROOT}/${SYSTEM}.dtb not found"
fi

if [ -f "${BUILD_ROOT}/${SYSTEM}.dts" ]; then
  cp -f "${BUILD_ROOT}/${SYSTEM}.dts" "${ARTIFACT_DIR}/${SYSTEM}.dts"
  echo "Copied ${ARTIFACT_DIR}/${SYSTEM}.dts"
fi

echo "Done."
