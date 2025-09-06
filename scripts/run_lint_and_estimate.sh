#!/usr/bin/env bashhhh
set -euo pipefail

# Run from repo root or from Scripts/ (relative paths handled below)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# If you're in Scripts/, REPO_ROOT is its parent; if already at root, it's itself's parent anyway
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ==============================
# Basic config
# ==============================
RTL_DIR="${REPO_ROOT}/RTL/Src"
BUILD_DIR="${REPO_ROOT}/build"
FILELIST="${BUILD_DIR}/filelist.f"

# Fixed top (override via env: TOP_MODULE=my_top)
TOP_MODULE="${TOP_MODULE:-top}"

# Optional Liberty from PDK for area/cell estimation
PDK_LIB="${PDK_LIB:-}"

INCLUDE_FLAGS="-I${RTL_DIR}"

# ==============================
# Preparation
# ==============================
mkdir -p "${BUILD_DIR}"

# Build filelist (exclude non-RTL dirs)
: > "${FILELIST}"
find "${RTL_DIR}" \
  -type d \( -name constraints -o -name asm -o -name gui \) -prune -false -o \
  -type f -name "*.v" -print \
  | sort >> "${FILELIST}"

echo "[INFO] Filelist: ${FILELIST}"
sed 's/^/  /' "${FILELIST}"
echo "[INFO] TOP_MODULE = ${TOP_MODULE}"

# ==============================
# Verilator — Linting
# (remove --timing for compatibility with older versions)
# ==============================
echo "[RUN] Verilator lint"
verilator --lint-only -sv -Wall \
  -Wno-UNOPTFLAT -Wno-WIDTH \
  -f "${FILELIST}" \
  ${INCLUDE_FLAGS} \
  --top-module "${TOP_MODULE}" \
  --error-limit 0 \
  2>&1 | tee "${BUILD_DIR}/verilator_lint.log" || true
echo "[OK ] Log: ${BUILD_DIR}/verilator_lint.log"

# ==============================
# Yosys — Structural linting
# (expand filelist into the .ys script)
# ==============================
# Expand file list into a single line for Yosys
FILELIST_EXPANDED="$(tr '\n' ' ' < "${FILELIST}")"

YOSYS_LINT="${BUILD_DIR}/lint.ys"
cat > "${YOSYS_LINT}" <<EOF
# === Yosys structural lint ===
read_verilog -sv -I${RTL_DIR} ${FILELIST_EXPANDED}
hierarchy -check -top ${TOP_MODULE}
# Normalize to expose issues
proc; opt; fsm; opt; memory; opt
check -assert
stat -width
# “Dry” synthesis to flush more warnings
synth -top ${TOP_MODULE} -flatten
write_json ${BUILD_DIR}/lint_netlist.json
EOF

echo "[RUN] Yosys structural lint"
yosys -ql "${BUILD_DIR}/yosys_lint.log" "${YOSYS_LINT}"
echo "[OK ] Log: ${BUILD_DIR}/yosys_lint.log"

# ==============================
# Yosys — Real estimation with .lib (optional)
# ==============================
if [[ -n "${PDK_LIB}" && -f "${PDK_LIB}" ]]; then
  echo "[RUN] Yosys estimation with PDK_LIB=${PDK_LIB}"
  YOSYS_MAP="${BUILD_DIR}/map_with_lib.ys"
  cat > "${YOSYS_MAP}" <<EOF
read_verilog -sv -I${RTL_DIR} ${FILELIST_EXPANDED}
hierarchy -check -top ${TOP_MODULE}
read_liberty -lib ${PDK_LIB}
synth -top ${TOP_MODULE}
dfflibmap -liberty ${PDK_LIB}
abc -liberty ${PDK_LIB}
stat -liberty ${PDK_LIB}
write_verilog ${BUILD_DIR}/netlist_mapped.v
EOF
  yosys -s "${YOSYS_MAP}" | tee "${BUILD_DIR}/yosys_estimate.log"
  echo "[OK ] Netlist mapped: ${BUILD_DIR}/netlist_mapped.v"
  echo "[OK ] Estimation report: ${BUILD_DIR}/yosys_estimate.log"
else
  echo "[INFO] PDK_LIB not set. Skipping cell/area estimation."
  echo "       Export PDK_LIB to enable it, e.g.:"
  echo "       export PDK_LIB=\$PDK_ROOT/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_tt_1p2v_25C.lib"
fi

echo "[DONE] Linting (Verilator/Yosys) and optional estimation completed."
