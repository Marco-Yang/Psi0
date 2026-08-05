import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "third_party", "SIMPLE", "src"))

from simple.dr.spatial import SpatialDR, SpatialDRCfg


class DummyRegion:
    def sample(self):
        return [0.1, 0.2]

    def middle(self):
        return [0.1, 0.2]


class DummyAsset:
    def __init__(self, mesh_path):
        self.collision_mesh_curobo = mesh_path
        self.stable_poses = [(0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0)]


class DummyObject:
    def __init__(self, mesh_path):
        self.uid = "dummy_obj"
        self.asset = DummyAsset(mesh_path)
        self.pose = type("Pose", (), {"position": None, "quaternion": None})()


class SpatialDRCollisionManagerTest(unittest.TestCase):
    def test_random_place_skips_collision_checks_when_manager_is_missing(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            mesh_path = os.path.join(tmpdir, "dummy.obj")
            with open(mesh_path, "w", encoding="utf-8") as fh:
                fh.write(
                    "v 0 0 0\n"
                    "v 1 0 0\n"
                    "v 0 1 0\n"
                    "v 0 0 1\n"
                    "f 1 2 3\n"
                    "f 1 2 4\n"
                )

            obj = DummyObject(mesh_path)
            cfg = SpatialDRCfg(target_region=DummyRegion(), container_region=DummyRegion(), distractors_region=DummyRegion())
            dr = SpatialDR(cfg)
            dr.collision_manager = None

            result = dr._random_place_one_object(obj, DummyRegion(), "target", surface_height=0.0)

            self.assertTrue(result)
            self.assertIsNotNone(obj.pose.position)
            self.assertIsNotNone(obj.pose.quaternion)


if __name__ == "__main__":
    unittest.main()
