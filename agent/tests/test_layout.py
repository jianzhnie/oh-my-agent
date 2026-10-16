"""Check deployment paths and index coverage without starting external services."""

import json
import re
import unittest
from pathlib import Path

AGENT = Path(__file__).resolve().parents[1]


class LayoutTests(unittest.TestCase):
    def test_registered_runtime_paths_exist(self):
        settings = json.loads((AGENT / "settings.json").read_text())
        commands = [
            hook["command"]
            for groups in settings["hooks"].values()
            for group in groups
            for hook in group["hooks"]
        ] + [settings["statusLine"]["command"]]
        registered = set()
        for command in commands:
            self.assertTrue(command.startswith('"${CLAUDE_PROJECT_DIR}/.claude/'))
            self.assertTrue(command.endswith('"'))
            path = command.removeprefix('"${CLAUDE_PROJECT_DIR}/.claude/').removesuffix(
                '"'
            )
            self.assertTrue((AGENT / path).is_file(), path)
            registered.add(path)
        expected = {
            str(path.relative_to(AGENT))
            for path in (AGENT / "hooks").rglob("*.sh")
            if path.name != "common.sh"
        } | {"scripts/status-line.sh"}
        self.assertEqual(registered, expected)

    def test_index_covers_all_configuration_entries(self):
        text = (AGENT / "README.md").read_text()
        # Index tables contain one local file link per configuration entry.
        links = [
            target
            for line in text.splitlines()
            if line.startswith("| ")
            for target in re.findall(r"\]\(([^)]+)\)", line)
            if not target.startswith("https://")
        ]
        self.assertEqual(len(links), len(set(links)))
        expected = {"settings.json", ".mcp.json", "scripts/status-line.sh"}
        for folder in ("agents", "commands", "rules", "output-styles"):
            expected.update(
                str(p.relative_to(AGENT)) for p in (AGENT / folder).glob("*.md")
            )
        expected.update(
            str(p.relative_to(AGENT)) for p in (AGENT / "skills").glob("*/SKILL.md")
        )
        expected.update(
            str(p.relative_to(AGENT))
            for p in (AGENT / "hooks").rglob("*.sh")
            if p.name != "common.sh"
        )
        self.assertEqual(set(links), expected)

    def test_local_document_links_resolve(self):
        for doc in [AGENT / "README.md"]:
            for target in re.findall(r"\]\(([^)]+)\)", doc.read_text()):
                if target.startswith(("https://", "http://", "#")):
                    continue
                self.assertTrue(
                    (doc.parent / target.split("#")[0]).is_file(), (doc, target)
                )


if __name__ == "__main__":
    unittest.main()
