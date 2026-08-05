import unittest
from unittest.mock import patch

import numpy as np

from gear_sonic.utils.mujoco_sim.base_sim import PicoTeleopBridge


class DummyTeleop:
    def __init__(self):
        self.calls = 0

    def step(self, full_head=False):
        self.calls += 1
        head_mat = np.eye(4)
        head_mat[:3, 3] = np.array([0.1, 0.2, 0.3])
        return head_mat, None, None, None, None


class PicoBridgeFallbackTest(unittest.TestCase):
    def test_pico_bridge_applies_root_pose_from_teleop(self):
        bridge = PicoTeleopBridge({"ENABLE_PICO_TELEOP": True})
        bridge.enabled = True
        bridge.teleop = DummyTeleop()

        class DummyEnv:
            use_floating_root_link = True

            def __init__(self):
                self.mj_data = type("MjData", (), {"qpos": np.zeros(7), "qvel": np.zeros(6)})()

        env = DummyEnv()

        with patch("gear_sonic.utils.mujoco_sim.base_sim.mujoco.mj_forward", return_value=None):
            applied = bridge.apply_to_sim(env)

        self.assertTrue(applied)
        self.assertTrue(np.allclose(env.mj_data.qpos[:3], [0.1, 0.2, 0.3]))
        self.assertTrue(np.allclose(env.mj_data.qvel[:6], 0.0))


if __name__ == "__main__":
    unittest.main()
