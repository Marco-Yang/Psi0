import types

from simple.cli.teleop_decoupled_wbc import _reset_teleop_state


class DummyElasticBand:
    def __init__(self):
        self.enable = True


class DummyRobot:
    def __init__(self):
        self.elastic_band = DummyElasticBand()


class DummyLowerBodyPolicy:
    def __init__(self):
        self.use_policy_action = False


class DummyWbcPolicy:
    def __init__(self):
        self.lower_body_policy = DummyLowerBodyPolicy()


class DummyAgent:
    def __init__(self):
        self._wbc_policy = DummyWbcPolicy()
        self._dropping = False

    def reset_policy(self):
        self.reset_policy_called = True


def test_reset_teleop_state_handles_missing_elastic_band_and_policy():
    robot = types.SimpleNamespace()
    agent = types.SimpleNamespace(_dropping=False)

    _reset_teleop_state(robot, agent)

    assert agent._dropping is False


def test_reset_teleop_state_disables_elastic_band_and_resets_policy():
    robot = DummyRobot()
    agent = DummyAgent()

    _reset_teleop_state(robot, agent)

    assert robot.elastic_band.enable is False
    assert agent.reset_policy_called is True
    assert agent._wbc_policy.lower_body_policy.use_policy_action is True
