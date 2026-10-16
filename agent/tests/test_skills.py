"""Verify the discovery names of the remaining local skills."""

import re
import unittest
from pathlib import Path

SKILLS = Path(__file__).resolve().parents[1] / "skills"


class SkillResourcesTests(unittest.TestCase):
    def test_skill_names_match_discovery_directories(self):
        names = []
        for entry in SKILLS.glob("*/SKILL.md"):
            header = entry.read_text().split("---", 2)[1]
            name = re.search(r"^name: (.+)$", header, re.M).group(1).strip()
            self.assertEqual(name, entry.parent.name)
            names.append(name)
        self.assertEqual(len(names), len(set(names)))


if __name__ == "__main__":
    unittest.main()
