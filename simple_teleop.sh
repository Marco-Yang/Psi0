#!/usr/bin/env bash
set -euo pipefail

# Keep teleop recording running by default; override when needed, e.g.:
# TELEOP_NUM_EPISODES=1 bash simple_teleop.sh
TELEOP_NUM_EPISODES="${TELEOP_NUM_EPISODES:-1000000}"

cd /home/user/Work/WBM/Psi0 && \
source third_party/GR00T-WholeBodyControl/.venv_teleop/bin/activate && \
export PYTHONPATH="$PYTHONPATH:/home/user/Work/WBM/Psi0/third_party/GR00T-WholeBodyControl/.venv_data_collection/lib/python3.10/site-packages" && \
unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY && \
export DISPLAY=:1 && \
export XAUTHORITY=/run/user/1000/gdm/Xauthority && \
export MUJOCO_GL=glfw && \
export __NV_PRIME_RENDER_OFFLOAD=1 && \
export __GLX_VENDOR_LIBRARY_NAME=nvidia && \
export __VK_LAYER_NV_optimus=NVIDIA_only && \
export DRI_PRIME=1 && \
export SIMPLE_LOW_LATENCY_MODE=1 && \
export SIMPLE_VIEWER_ENABLE=1 && \
export SIMPLE_VIEWER_EVERY_N=2 && \
export SIMPLE_STREAM_ENABLE=1 && \
export SIMPLE_STREAM_EVERY_N=1 && \
export SIMPLE_PICO_SAFE_STREAM=1 && \
export SIMPLE_PICO_SAFE_WIDTH=1280 && \
export SIMPLE_PICO_SAFE_HEIGHT=360 && \
export SIMPLE_PICO_SAFE_FPS=30 && \
export SIMPLE_PICO_SAFE_BITRATE=3000000 && \
export SIMPLE_PICO_FORCE_H264=1 && \
unset SIMPLE_PICO_FORCE_HEVC && \
export SIMPLE_PICO_STREAM_OVERLAY=0 && \
export SIMPLE_PICO_STREAM_RESIZE_TO_ENCODER=1 && \
export SIMPLE_PICO_TRIGGER_THRESHOLD=0.15 && \
export SIMPLE_PICO_ACTIVATION_MODE=left_menu_right_trigger && \
unset SIMPLE_PICO_ACTIVATE_ON_RIGHT_TRIGGER && \
export SIMPLE_PICO_DEBUG_INPUT=0 && \
export SIMPLE_PICO_AUTO_ACTIVATE=0 && \
export SIMPLE_PICO_AUTO_DROP=1 && \
export SIMPLE_PICO_RESET_GRIP_THRESHOLD=0.85 && \
export SIMPLE_PICO_RESET_HOLD_SECS=2.00 && \
export SIMPLE_PICO_RESET_TRIGGER_MAX=0.20 && \
export SIMPLE_PICO_HEIGHT_INCREMENT=0.002 && \
export SIMPLE_PICO_HEIGHT_BLOCK_WHILE_GRASP=0 && \
export SIMPLE_UPDATE_REWARD=0 && \
export SIMPLE_RECORD_EVERY_N=1 && \
export SIMPLE_OVERRUN_LOG_INTERVAL_SECS=5.0 && \
export SIMPLE_PERF_LOG_INTERVAL_SECS=8.0 && \
export SIMPLE_PASSIVE_RESET_ON_DONE=0 && \
export SIMPLE_DONE_RESET_CONSECUTIVE=3 && \
export SIMPLE_MJ_MEMORY_BYTES=64M && \
export SIMPLE_MJ_NSTACK=8000000 && \
export SIMPLE_RESET_SETTLE_STEPS=0 && \
export SIMPLE_DISABLE_ELASTIC_BAND_ON_RESET=1 && \
export SIMPLE_FORCE_RECORD_AFTER_RESET=1 && \
RUN_ID=$(date +%m%d_%H%M%S) && \
python third_party/SIMPLE/src/simple/cli/teleop_decoupled_wbc.py "simple/G1WholebodyXMoveBendPickTeleop-v0" --sim-mode=mujoco --render-hz 36 --record --num-episodes "$TELEOP_NUM_EPISODES" --save-dir "data/teleop_decoupled_wbc_runs/$RUN_ID"