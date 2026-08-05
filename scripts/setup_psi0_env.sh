#!/usr/bin/env bash
# Psi0 + SONIC 环境一键配置（工控机侧）
# 用法:
#   bash scripts/setup_psi0_env.sh              # 仅 Psi0 训练/推理 (.venv-psi)
#   bash scripts/setup_psi0_env.sh --sonic        # 额外配置 SONIC 遥操数采三件套 venv
#   bash scripts/setup_psi0_env.sh --simple       # 额外拉取 SIMPLE 子模块并全量 uv sync
#   bash scripts/setup_psi0_env.sh --all          # --sonic + --simple
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PSI_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SONIC_ROOT="${PSI_ROOT}/third_party/GR00T-WholeBodyControl"

SETUP_SONIC=0
SETUP_SIMPLE=0
for arg in "$@"; do
  case "$arg" in
    --sonic) SETUP_SONIC=1 ;;
    --simple) SETUP_SIMPLE=1 ;;
    --all) SETUP_SONIC=1; SETUP_SIMPLE=1 ;;
    -h|--help)
      sed -n '2,8p' "$0"
      exit 0
      ;;
    *) echo "Unknown arg: $arg"; exit 1 ;;
  esac
done

if ! command -v uv >/dev/null 2>&1; then
  echo "[setup] installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="${HOME}/.local/bin:${PATH}"
fi

cd "${PSI_ROOT}"

# 持久化环境变量（写入 env 片段，供 source）
ENV_FILE="${PSI_ROOT}/.env.psi"
cat > "${ENV_FILE}" <<EOF
# source this file:  source ${PSI_ROOT}/.env.psi
export PSI_HOME="${PSI_ROOT}"
export PATH="${PSI_ROOT}/.venv-psi/bin:\${PATH}"
EOF

echo "[setup] PSI_HOME=${PSI_ROOT}"
if [[ -d "${PSI_ROOT}/.venv-psi" ]]; then
  echo "[setup] reusing existing .venv-psi"
else
  echo "[setup] creating .venv-psi (Python 3.10)..."
  uv venv .venv-psi --python 3.10
fi
# shellcheck disable=SC1091
source .venv-psi/bin/activate

if [[ "${SETUP_SIMPLE}" -eq 1 ]]; then
  echo "[setup] initializing git submodules (SIMPLE + GR00T)..."
  git submodule update --init --recursive
else
  echo "[setup] initializing GR00T-WholeBodyControl submodule..."
  git submodule update --init --recursive third_party/GR00T-WholeBodyControl
fi

echo "[setup] uv sync (psi + serve + viz)..."
GIT_LFS_SKIP_SMUDGE=1 uv sync \
  --group serve \
  --group viz \
  --group psi \
  --index-strategy unsafe-best-match \
  --active

if [[ "${SETUP_SIMPLE}" -eq 1 ]]; then
  echo "[setup] uv sync --all-groups (includes SIMPLE)..."
  GIT_LFS_SKIP_SMUDGE=1 uv sync --all-groups --index-strategy unsafe-best-match --active
  if [[ -x "${PSI_ROOT}/scripts/install_curobo.sh" ]]; then
  echo "[setup] installing curobo for SIMPLE..."
  UV_PROJECT_ENVIRONMENT="${PSI_ROOT}/.venv-psi" bash "${PSI_ROOT}/scripts/install_curobo.sh"
  fi
fi

if ! python -c "import flash_attn" >/dev/null 2>&1; then
  echo "[setup] installing flash_attn (may take several minutes)..."
  uv pip install flash_attn==2.7.4.post1 --no-build-isolation || {
    echo "[warn] flash_attn build failed. Training may still work on CPU smoke tests;"
    echo "       on GPU machine retry: uv pip install flash_attn==2.7.4.post1 --no-build-isolation"
  }
fi

echo "[setup] verifying Psi0 import..."
python -c "import psi; print('psi version:', psi.__version__)"
python -c "import torch; print('torch:', torch.__version__, 'cuda:', torch.cuda.is_available())"
python -c "from psi.data.lerobot.compat import LEROBOT_LAYOUT; print('lerobot layout:', LEROBOT_LAYOUT)"

if [[ "${SETUP_SONIC}" -eq 1 ]]; then
  echo "[setup] configuring SONIC environments under ${SONIC_ROOT}..."
  if [[ ! -d "${SONIC_ROOT}" ]]; then
    echo "[error] missing ${SONIC_ROOT}"; exit 1
  fi
  cd "${SONIC_ROOT}"
  if command -v git-lfs >/dev/null 2>&1; then
    git lfs pull || echo "[warn] git lfs pull failed; large assets may be missing"
  fi
  bash install_scripts/install_pico.sh
  if ! bash install_scripts/install_data_collection.sh; then
    echo "[warn] install_data_collection.sh failed (often GitHub timeout)."
    echo "[setup] retrying data_collection with local lerobot clone..."
  LEROBOT_LOCAL="${PSI_ROOT}/.uv_home/lerobot_clone"
  if [[ -d "${LEROBOT_LOCAL}" ]]; then
    source .venv_data_collection/bin/activate
    uv pip install -e "${LEROBOT_LOCAL}"
    uv pip install pyzmq msgpack msgpack-numpy pin tyro pyttsx3==2.90 "av>=14.2" opencv-python "datasets==3.6.0"
    uv pip install -e gear_sonic
    deactivate || true
  else
    echo "[error] missing ${LEROBOT_LOCAL}; fix network and rerun install_data_collection.sh"
    exit 1
  fi
  fi
  bash install_scripts/install_mujoco_sim.sh
  if [[ -f download_from_hf.py ]]; then
    python download_from_hf.py || echo "[warn] download_from_hf.py failed; deploy ONNX may be missing"
  fi
  cd "${PSI_ROOT}"
fi

cat <<MSG

============================================================
 Psi0 environment ready.
============================================================
  source ${ENV_FILE}
  # or:
  source ${PSI_ROOT}/.venv-psi/bin/activate
  export PSI_HOME=${PSI_ROOT}

 Quick test:
  python -c "import psi; print(psi.__version__)"

 SONIC data collection (after --sonic):
  cd third_party/GR00T-WholeBodyControl
  bash ${PSI_ROOT}/real/SONIC/scripts/collect_psi0-sonic-data.sh

 SONIC C++ deploy build (separate, see real/SONIC/README.md):
  cd third_party/GR00T-WholeBodyControl/gear_sonic_deploy && just build
============================================================
MSG
