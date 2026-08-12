import json
import tempfile
import unittest
from pathlib import Path

from doc_session_index import render_session_map


class DocSessionIndexTest(unittest.TestCase):
    def test_task_session_association_and_latest_activity(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / "workspace"
            project = root / "project"
            project.mkdir(parents=True)
            (project / "task_plan.md").write_text("# Active task\n")
            (root / "empty.md").write_text("  \n")
            sessions = Path(tmp) / "sessions"
            sessions.mkdir()
            session = sessions / "rollout.jsonl"
            rows = [
                {"type": "session_meta", "payload": {"session_id": "s1", "timestamp": "2026-08-12T01:00:00Z", "cwd": str(project)}},
                {"type": "turn_context", "payload": {"workspace_roots": [str(root)]}},
                {"type": "event_msg", "timestamp": "2026-08-12T02:00:00Z", "payload": {"type": "user_message", "message": "new status"}},
                {"type": "response_item", "timestamp": "2026-08-12T02:05:00Z", "payload": {"type": "message", "content": [{"type": "output_text", "text": "SECRET_BODY"}]}},
            ]
            session.write_text("\n".join(json.dumps(row) for row in rows) + "\n")

            rendered = render_session_map(sessions, str(root))

            self.assertIn("SESSION_MAP_BEGIN\tproject/task_plan.md", rendered)
            self.assertIn("session_id: `s1`", rendered)
            self.assertIn("last_activity: `2026-08-12T02:05:00Z`", rendered)
            self.assertNotIn("SECRET_BODY", rendered)
            self.assertNotIn("empty.md", rendered)


if __name__ == "__main__":
    unittest.main()
