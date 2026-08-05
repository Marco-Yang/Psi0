# PICO 遥操保姆级指南

这份文档面向希望把 PICO 头显/手柄接到 Psi0 + SONIC + SIMPLE 这条链路上的使用者。

目标不是“看懂所有代码”，而是让你尽快跑通一条最小可用流程：

1. 先把 PICO 数据读出来；
2. 再把它接到仿真或真实机器人上；
3. 最后顺利开始遥操。

---

## 1. 这条链路到底是什么

从高层看，PICO 遥操一般分为三步：

1. PICO 采集头显和手部位姿；
2. 代码做坐标系变换、重定向、手部映射；
3. 结果送进仿真/机器人控制 loop。

你当前仓库里相关入口主要有：

- PICO 处理逻辑：[real/teleop/vr_pico.py](../teleop/vr_pico.py)
- SONIC 运行脚本：[real/SONIC/scripts/collect_psi0-sonic-data.sh](scripts/collect_psi0-sonic-data.sh)
- SONIC 说明：[real/SONIC/README.md](README.md)

---

## 2. 先准备好环境

### 2.1 进入项目根目录

```bash
cd /home/user/Work/WBM/Psi0
source .venv-psi/bin/activate
```

### 2.2 让 SIMPLE 可被当前环境识别

如果你遇到 `import simple` 失败，先执行：

```bash
export PYTHONPATH=$PWD/third_party/SIMPLE/src:$PYTHONPATH
python -c "import simple; print(simple.__version__)"
```

如果这一条成功，说明你已经能把 SIMPLE 代码路径暴露给当前环境了。

### 2.3 进入 SONIC 子模块

```bash
cd /home/user/Work/WBM/Psi0/third_party/GR00T-WholeBodyControl
```

然后依次安装相关环境：

```bash
bash install_scripts/install_pico.sh
bash install_scripts/install_data_collection.sh
bash install_scripts/install_mujoco_sim.sh
```

如果你只是先验证遥操，优先跑仿真环境即可。

---

## 3. 最推荐的第一步：先跑仿真遥操测试

这是最快的上手路径，先别急着上真实机器人。

### 3.1 从仓库根目录直接运行

```bash
cd /home/user/Work/WBM/Psi0
bash ./real/SONIC/scripts/collect_psi0-sonic-data.sh sim
```

这个模式是“MuJoCo 仿真测试”，不会直接接真实机器人，适合先确认 PICO 数据流是否通。

### 3.2 如果想拆分看每个进程

也可以使用手动脚本：

```bash
cd /home/user/Work/WBM/Psi0
bash ./real/SONIC/scripts/collect_psi0-sonic-data-manual.sh sim
```

这样更容易定位问题。

---

## 4. 使用 PICO 前要注意的硬件与网络事项

### 4.1 网络要通

PICO 设备需要和本机在同一网络环境下，网络稳定才行。

### 4.2 先确认 XR 相关组件已经装好

如果 PICO 读不到数据，通常是下面几个原因之一：

- 设备没有成功连接；
- XR/teleop 依赖没有装好；
- 运行时环境和设备连接环境不一致。

### 4.3 先做校准

在开始遥操之前，先把 PICO 的头显和手柄摆到一个自然站姿，确保位姿基准比较稳定。

---

## 5. 操作顺序：先校准，再进入遥操

仓库里的说明里已经给出了关键操作顺序，建议你第一次操作时按这个顺序来，不要自己猜。

### 推荐流程

1. 先站到一个自然姿态，保持稳定；
2. 进行 calibration pose；
3. 按下 A+B+X+Y，进入遥操状态；
4. 按下 A+X，进入执行状态；
5. 左手 grip + A：开始/停止一个 episode；
6. 左手 grip + B：丢弃当前 episode。

> 如果你第一次跑，建议不要急着做复杂动作，先把“能连上、能有反应、能开始/停止”这三件事确认好。

---

## 6. 常见问题排查

### 6.1 PICO 没有任何反应

优先检查：

- 设备是否已经成功连接；
- 当前终端是否进入了正确的 Python 环境；
- XR teleop 依赖是否已安装；
- 是否已经进入了遥操启动脚本。

### 6.2 能看到数据，但仿真/机器人没有动作

这通常是坐标系或手部映射的问题，而不是“没有读取到数据”。

这类问题一般出在：

- 头部与手部坐标系不一致；
- 手部姿态映射参数不合适；
- 高度/偏移修正没调好。

这正是 [real/teleop/vr_pico.py](../teleop/vr_pico.py) 里需要重点调的部分。

### 6.3 `import simple` 失败

最直接的验证命令是：

```bash
cd /home/user/Work/WBM/Psi0
source .venv-psi/bin/activate
export PYTHONPATH=$PWD/third_party/SIMPLE/src:$PYTHONPATH
python -c "import simple; print(simple.__version__)"
```

如果这里不通，后续所有基于 SIMPLE 的遥操链路都会受影响。

---

## 7. 真实机器人前，先把仿真链路跑通

建议顺序如下：

1. 先跑仿真遥操；
2. 先确认 PICO 数据有响应；
3. 再尝试真实机器人；
4. 最后再考虑录制数据或者做更复杂动作。

不要一上来就直接把真实机器人和高强度任务接上。先把“可控、可重现”做稳，后面才容易排查问题。

---

## 8. 你最应该记住的 4 条

- 先把环境和 SIMPLE 导入跑通；
- 先用仿真验证 PICO 数据流；
- 先做校准再开始遥操；
- 看到“有数据但没动作”，优先查坐标系和映射，而不是怀疑硬件。

---

## 9. 相关文件索引

- [real/teleop/vr_pico.py](../teleop/vr_pico.py)
- [real/SONIC/README.md](README.md)
- [real/SONIC/scripts/collect_psi0-sonic-data.sh](scripts/collect_psi0-sonic-data.sh)
- [real/SONIC/scripts/collect_psi0-sonic-data-manual.sh](scripts/collect_psi0-sonic-data-manual.sh)
- [third_party/GR00T-WholeBodyControl/README.md](../../third_party/GR00T-WholeBodyControl/README.md)

---

如果你愿意，我下一步可以继续把这份文档再扩展成“从零安装到可运行”的完整版，或者直接帮你把 PICO → SIMPLE 的最小桥接脚本也一起补上。
