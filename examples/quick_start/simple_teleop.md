# SIMPLE Teleop Quick Start

## 目标

在 SIMPLE 仿真里完成稳定遥操与录制，并且每次手动重置前保存当前 episode。

## 启动

在仓库根目录运行：

```bash
bash simple_teleop.sh
```

录制结果默认写入：

```bash
data/teleop_decoupled_wbc_runs/<RUN_ID>/simple/G1WholebodyXMoveBendPickTeleop-v0/level-0
```

## 关键按键

- 激活遥操与开始录制：`左菜单 + 右扳机`
- 手动重置：`左菜单 + 左握把 + 右握把`（同时按住约 2 秒）
- 下蹲：`X`
- 起身：`Y`
- 前后左右平移：`左摇杆`
- 偏航（转向）：`右摇杆左右`

## 录制行为

- 激活后进入录制状态。
- 手动重置时，如果当前 episode 已有帧，会先保存当前 episode，再执行 reset。
- 视频和 episode 会按 `episode_id` 归档到对应目录。

## 常用可调参数（环境变量）

- `TELEOP_NUM_EPISODES`：最大 episode 数（默认很大，近似持续录制）
- `SIMPLE_PICO_RESET_GRIP_THRESHOLD`：重置握把阈值
- `SIMPLE_PICO_RESET_HOLD_SECS`：重置按住时长
- `SIMPLE_PICO_RESET_TRIGGER_MAX`：重置时扳机必须低于该阈值
- `SIMPLE_PICO_HEIGHT_INCREMENT`：`X/Y` 每步抬升/下降幅度
- `SIMPLE_PASSIVE_RESET_ON_DONE`：是否允许 `terminated/truncated` 被动触发 reset

## 排查建议

- 若看到 `PassiveReset ... accepted`，说明是被动 reset，不是按键 reset。
- 若看到 `[Reset] reason=button_combo`，说明是手动组合键触发。
- 若仿真卡顿明显，可降低渲染/编码开销并检查 `env.step_avg`。
