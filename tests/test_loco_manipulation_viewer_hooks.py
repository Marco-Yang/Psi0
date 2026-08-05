import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "third_party", "SIMPLE", "src"))

from simple.envs.loco_manipulation import LocoManipulationEnv


def test_viewer_and_reward_hooks_are_noops():
    env = LocoManipulationEnv.__new__(LocoManipulationEnv)

    assert env.update_viewer() is None
    assert env.update_reward() is None
