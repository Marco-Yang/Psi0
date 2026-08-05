import os
import subprocess
import sys
import textwrap
from pathlib import Path


def test_simple_robot_mixin_imports_without_curobo() -> None:
    repo_root = Path(__file__).resolve().parents[1]
    simple_src = repo_root / "third_party" / "SIMPLE" / "src"

    script = textwrap.dedent(
        """
        import simple.robots.mixin as mixin

        assert hasattr(mixin, "CuRoboMixin")
        assert hasattr(mixin, "_CUROBO_AVAILABLE")
        assert mixin._CUROBO_AVAILABLE is False
        """
    )

    env = os.environ.copy()
    pythonpath = str(simple_src)
    if env.get("PYTHONPATH"):
        pythonpath = f"{pythonpath}{os.pathsep}{env['PYTHONPATH']}"
    env["PYTHONPATH"] = pythonpath

    result = subprocess.run(
        [sys.executable, "-c", script],
        cwd=repo_root,
        env=env,
        text=True,
        capture_output=True,
        timeout=60,
    )

    output = result.stdout + result.stderr
    assert result.returncode == 0, output
