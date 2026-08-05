import numpy as np

from gear_sonic.utils.mujoco_sim.base_sim import DefaultEnv
from gear_sonic.utils.mujoco_sim.configs import SimLoopConfig


class DictLike(dict):
    pass


def _make_env():
    cfg = SimLoopConfig(enable_onscreen=False, enable_offscreen=False, verbose=False)
    config_dict = cfg.load_wbc_yaml()
    config = DictLike(config_dict)
    config.update(
        {
            k: getattr(cfg, k)
            for k in dir(cfg)
            if not k.startswith("_") and not callable(getattr(cfg, k))
        }
    )
    return DefaultEnv(config, env_name="default")


def test_default_posture_fallback_generates_pd_torques():
    env = _make_env()

    target_q = np.asarray(env.robot.DEFAULT_MOTOR_ANGLES[: env.num_body_dof], dtype=float)
    current_q = target_q.copy()
    current_q[0] += 0.15
    env.mj_data.qpos[env.body_qpos_index] = current_q
    env.mj_data.qvel[env.body_dof_index] = 0.0

    torques = env.compute_body_torques()

    assert torques.shape == (env.num_body_dof,)
    assert np.linalg.norm(torques) > 1e-6
