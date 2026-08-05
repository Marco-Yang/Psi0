from simple.robots.g1_wholebody import normalize_mj_name
from simple.engines.mujoco import _can_use_glfw


def test_normalize_mj_name_strips_leading_slashes():
    assert normalize_mj_name("/left_hip_pitch_joint") == "left_hip_pitch_joint"
    assert normalize_mj_name("left_hip_pitch_joint") == "left_hip_pitch_joint"
    assert normalize_mj_name("/fx") == "fx"


def test_normalize_mj_name_handles_prefixed_names():
    assert normalize_mj_name("/robot/left_hip_pitch_joint") == "left_hip_pitch_joint"
    assert normalize_mj_name("/robot/left_hand_thumb_0_joint") == "left_hand_thumb_0_joint"


def test_can_use_glfw_requires_display():
    assert _can_use_glfw(display_env={}, glfw_module=None) is False
    assert _can_use_glfw(display_env={"DISPLAY": ":0"}, glfw_module=None) is False
