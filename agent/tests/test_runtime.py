"""Isolated runtime checks; network and desktop notification commands are mocked."""

import json
import os
import re
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

AGENT = Path(__file__).resolve().parents[1]


class RuntimeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.project = Path(self.temp.name) / "project with spaces"
        self.project.mkdir()
        (self.project / ".claude").mkdir()
        self.bin = self.project / "bin"
        self.bin.mkdir()
        self.env = {**os.environ, "CLAUDE_PROJECT_DIR": str(self.project)}
        self.env["PATH"] = f"{self.bin}:{os.environ['PATH']}"
        self.env["TEST_CAPTURE"] = str(self.project / "capture")
        for command in ("curl", "osascript", "say"):
            self.mock(command, 'printf "%s\\n" "$@" >> "$TEST_CAPTURE"\ncat >/dev/null')
        self.git("init", "-q")
        self.git("config", "user.email", "test@example.invalid")
        self.git("config", "user.name", "Test")
        (self.project / ".gitignore").write_text(".claude/\nbin/\ncapture\n")
        (self.project / "binary.dat").write_bytes(b"\0original")
        self.git("add", ".")
        self.git("commit", "-qm", "baseline")

    def mock(self, command, body):
        path = self.bin / command
        path.write_text("#!/bin/bash\n" + body + "\n")
        path.chmod(0o755)

    def git(self, *args):
        return subprocess.run(
            ["git", *args], cwd=self.project, capture_output=True, text=True, check=True
        )

    def run_script(self, relative, payload=None, env=None):
        return subprocess.run(
            ["bash", str(AGENT / relative)],
            input=json.dumps(payload or {}),
            text=True,
            capture_output=True,
            cwd=self.project,
            env=env or self.env,
            timeout=10,
            check=True,
        )

    def test_notification_missing_key_keeps_desktop_notification(self):
        (self.project / ".claude/.env").write_text("OTHER=value\n")
        message = 'Text with "quotes" and \\slashes'
        self.run_script("hooks/notifications/notify.sh", {"message": message})
        self.assertIn(message, (self.project / "capture").read_text())

    def test_summary_binary_diff_and_encoded_request(self):
        (self.project / ".claude/.env").write_text("SCT_SENDKEY=test-key\n")
        (self.project / "binary.dat").write_bytes(b"\0changed")
        (self.project / ".claude/.session-start").write_text("1\n")
        self.run_script("hooks/session/summarize.sh")
        request = (self.project / "capture").read_text()
        self.assertIn("--data-urlencode", request)
        self.assertIn("--max-time\n4", request)
        self.assertIn("1未提交", request)
        self.assertIn("binary.dat", request)
        self.assertNotIn("00未提交", request)

    def test_summary_clean_repository(self):
        (self.project / ".claude/.env").write_text("SCT_SENDKEY=test-key\n")
        self.run_script("hooks/session/summarize.sh")
        request = (self.project / "capture").read_text()
        self.assertIn("0未提交", request)
        self.assertNotIn("00未提交", request)

    def test_summary_network_failure_does_not_fail_hook(self):
        (self.project / ".claude/.env").write_text("SCT_SENDKEY=test-key\n")
        self.mock("curl", "exit 28")
        self.run_script("hooks/session/summarize.sh")

    def test_summary_missing_key_sends_nothing(self):
        (self.project / ".claude/.env").write_text("OTHER=value\n")
        self.run_script("hooks/session/summarize.sh")
        self.assertFalse((self.project / "capture").exists())

    def test_statusline_clamps_and_normalizes_numbers(self):
        for percentage, used, expected in [
            (150, "bad", "100%"),
            (-20, None, "0%"),
            (42.7, 123456, "42%"),
        ]:
            with self.subTest(percentage=percentage):
                result = self.run_script(
                    "scripts/status-line.sh",
                    {
                        "model": {"display_name": "Test Model"},
                        "context_window": {
                            "used_percentage": percentage,
                            "used_tokens": used,
                        },
                    },
                )
                text = re.sub(r"\x1b\[[0-9;]*m", "", result.stdout)
                self.assertIn(expected, text)
                self.assertIn("Test Model", text)
                self.assertNotIn(" |", text)

    def test_log_event_routing(self):
        for payload in [
            {
                "hook_event_name": "PostToolUse",
                "tool_name": "Bash",
                "tool_input": {"command": "echo test"},
            },
            {"hook_event_name": "SubagentStart", "agent_type": "reviewer"},
            {"hook_event_name": "PostToolUse", "tool_name": "Read"},
            {"hook_event_name": "SessionStart"},
        ]:
            self.run_script("hooks/logging/record-event.sh", payload)
        lines = (self.project / ".claude/command-log.txt").read_text().splitlines()
        self.assertEqual(len(lines), 2)
        self.assertTrue(lines[0].endswith("echo test"))
        self.assertTrue(lines[1].endswith("agent:spawn reviewer"))

    def test_formatter_uses_project_root_for_relative_paths(self):
        (self.project / "example.py").write_text("value = 1\n")
        self.mock("pre-commit", 'printf "%s\\n" "$PWD" "$@" > "$TEST_CAPTURE"')
        result = subprocess.run(
            ["bash", str(AGENT / "hooks/formatting/format-file.sh")],
            input=json.dumps(
                {"tool_name": "Edit", "tool_input": {"file_path": "example.py"}}
            ),
            text=True,
            capture_output=True,
            cwd=self.bin,
            env=self.env,
            check=True,
        )
        capture = (self.project / "capture").read_text()
        self.assertIn(str(self.project), capture)
        self.assertIn(str(self.project / "example.py"), capture)
        self.assertIn(
            "example.py|Edit", (self.project / ".claude/.session-edits").read_text()
        )
        self.assertEqual(result.stderr, "")

    def test_deployed_logging_with_and_without_project_variable(self):
        shutil.copytree(AGENT / "hooks", self.project / ".claude/hooks")
        settings = json.loads((AGENT / "settings.json").read_text())
        command = settings["hooks"]["SubagentStart"][0]["hooks"][0]["command"]
        payload = json.dumps(
            {"hook_event_name": "SubagentStart", "agent_type": "reviewer"}
        )
        subprocess.run(
            ["bash", "-c", command],
            input=payload,
            text=True,
            env=self.env,
            cwd=self.bin,
            capture_output=True,
            check=True,
        )
        env = {k: v for k, v in self.env.items() if k != "CLAUDE_PROJECT_DIR"}
        subprocess.run(
            ["bash", str(self.project / ".claude/hooks/logging/record-event.sh")],
            input=payload,
            text=True,
            env=env,
            cwd=self.bin,
            capture_output=True,
            check=True,
        )
        lines = (self.project / ".claude/command-log.txt").read_text().splitlines()
        self.assertEqual(len(lines), 2)
        self.assertTrue(all(line.endswith("agent:spawn reviewer") for line in lines))

    def test_startup_initializes_state_and_compact_preserves_it(self):
        state = self.project / ".claude"
        (state / "command-log.txt").write_text("first\nsecond\n")
        self.run_script("hooks/session/context.sh", {"source": "startup"})
        self.assertEqual((state / ".session-cmd-start").read_text().strip(), "2")
        self.assertEqual((state / ".session-edits").read_text(), "")
        (state / ".session-edits").write_text("example.py|Edit\n")
        expected = {name: (state / name).read_bytes() for name in [".session-start", ".session-cmd-start", ".session-edits"]}
        restored = self.run_script("hooks/session/context.sh", {"source": "compact"})
        self.assertIn("Recent commits", restored.stdout)
        for name, content in expected.items():
            self.assertEqual((state / name).read_bytes(), content)
        self.run_script("hooks/session/context.sh", {"source": "resume"})
        for name, content in expected.items():
            self.assertEqual((state / name).read_bytes(), content)

    def test_config_and_failure_logs_remain_separate(self):
        self.run_script("hooks/logging/record-event.sh", {
            "hook_event_name": "ConfigChange", "source": "project_settings",
            "file_path": "settings.json", "change_type": "modified",
        })
        self.run_script("hooks/logging/record-event.sh", {
            "hook_event_name": "StopFailure", "error_type": "timeout",
        })
        state = self.project / ".claude"
        audit = json.loads((state / "config-audit.log").read_text())
        self.assertEqual(audit["source"], "project_settings")
        self.assertEqual(audit["file"], "settings.json")
        self.assertEqual(audit["change_type"], "modified")
        self.assertIn("timestamp", audit)
        self.assertTrue((state / "stop-failure.log").read_text().endswith("StopFailure: timeout\n"))
        self.assertFalse((state / "command-log.txt").exists())

    def test_reload_without_environment_file_is_noop(self):
        env = {k: v for k, v in self.env.items() if k != "CLAUDE_ENV_FILE"}
        self.run_script("hooks/environment/reload.sh", env=env)


if __name__ == "__main__":
    unittest.main()
