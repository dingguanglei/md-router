#!/usr/bin/env python3
"""Build metadata-only Codex session associations for Markdown task files."""

from __future__ import annotations

import hashlib
import json
import os
from collections import defaultdict
from pathlib import Path


def _normal(path: str) -> str:
    return os.path.normpath(path)


def _under(path: str, root: str) -> bool:
    path, root = _normal(path), _normal(root)
    return path == root or path.startswith(root + os.sep)


def _metadata(session_file: Path) -> dict:
    meta = {}
    cwd_values, workspace_roots = set(), set()
    last_activity = ""
    lines = []
    try:
        with session_file.open(encoding="utf-8", errors="replace") as stream:
            for line_number, line in enumerate(stream):
                if line_number >= 128:
                    break
                lines.append(line)
                try:
                    item = json.loads(line)
                except json.JSONDecodeError:
                    continue
                payload = item.get("payload") or {}
                timestamp = item.get("timestamp") or payload.get("timestamp")
                if timestamp and str(timestamp) > last_activity:
                    last_activity = str(timestamp)
                if item.get("type") == "session_meta":
                    meta["session_id"] = payload.get("session_id") or payload.get("id")
                    meta["timestamp"] = payload.get("timestamp")
                    if payload.get("cwd"):
                        cwd_values.add(str(payload["cwd"]))
                elif item.get("type") == "turn_context":
                    if payload.get("cwd"):
                        cwd_values.add(str(payload["cwd"]))
                    workspace_roots.update(str(root) for root in payload.get("workspace_roots") or [] if root)
    except OSError:
        return {}
    if not meta.get("session_id"):
        return {}
    meta["_prefix_lines"] = lines
    meta["cwd_values"] = sorted({_normal(path) for path in cwd_values})
    meta["workspace_roots"] = sorted({_normal(path) for path in workspace_roots})
    meta["session_file"] = str(session_file)
    meta["last_activity"] = last_activity or meta.get("timestamp") or "unknown-time"
    return meta


def _latest_timestamp(session_file: Path, prefix_lines: list[str], fallback: str) -> str:
    latest = fallback
    try:
        with session_file.open(encoding="utf-8", errors="replace") as stream:
            for line in stream:
                try:
                    item = json.loads(line)
                except json.JSONDecodeError:
                    continue
                payload = item.get("payload") or {}
                timestamp = item.get("timestamp") or payload.get("timestamp")
                if timestamp and str(timestamp) > latest:
                    latest = str(timestamp)
    except OSError:
        pass
    return latest


def _task_file_for(record: dict, task_files: list[Path], prefix: str) -> str:
    locations = [record["workspace"], *record.get("cwd_values", [])]
    candidates = [path for path in task_files if any(_under(location, str(path.parent)) for location in locations)]
    if not candidates:
        return "none"
    return os.path.relpath(max(candidates, key=lambda path: len(path.parts)), prefix)


def collect_sessions(sessions_dir: Path, workspace_prefix: str, limit: int = 8) -> dict[str, list[dict]]:
    prefix = _normal(workspace_prefix)
    task_files = sorted(
        path for path in Path(prefix).rglob("*")
        if path.is_file()
        and path.name.lower() in {"task.md", "task_plan.md"}
        and path.read_text(encoding="utf-8", errors="ignore").strip()
    )
    grouped = defaultdict(list)
    for session_file in sorted(sessions_dir.rglob("*.jsonl")):
        meta = _metadata(session_file)
        if not meta:
            continue
        roots = [root for root in meta["workspace_roots"] if _under(root, prefix)]
        if not roots:
            roots = [cwd for cwd in meta["cwd_values"] if _under(cwd, prefix)]
        if roots:
            meta["last_activity"] = _latest_timestamp(session_file, meta.pop("_prefix_lines", []), meta["last_activity"])
        for workspace in roots:
            record = {**meta, "workspace": workspace}
            record["task_file"] = _task_file_for(record, task_files, prefix)
            grouped[workspace].append(record)

    result = {}
    for workspace, records in sorted(grouped.items()):
        latest = {}
        for record in records:
            sid = record["session_id"]
            if sid not in latest or record["last_activity"] > latest[sid]["last_activity"]:
                latest[sid] = record
        result[workspace] = sorted(latest.values(), key=lambda item: item["last_activity"], reverse=True)[:limit]
    return result


def render_session_map(sessions_dir: Path, workspace_prefix: str) -> str:
    by_task = defaultdict(list)
    for records in collect_sessions(sessions_dir, workspace_prefix).values():
        for record in records:
            if record["task_file"] != "none":
                by_task[record["task_file"]].append(record)
    lines = []
    for task_file in sorted(by_task):
        lines.append(f"SESSION_MAP_BEGIN\t{task_file}")
        for record in sorted(by_task[task_file], key=lambda item: item["last_activity"], reverse=True):
            lines.append(
                f"    - session_id: `{record['session_id']}` | last_activity: `{record['last_activity']}` | "
                f"session_file: `{record['session_file']}`"
            )
        lines.append("SESSION_MAP_END")
    return "\n".join(lines)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("sessions_dir", type=Path)
    parser.add_argument("workspace_prefix")
    parser.add_argument("--hash", action="store_true")
    parser.add_argument("--map", action="store_true")
    args = parser.parse_args()
    rendered = render_session_map(args.sessions_dir, args.workspace_prefix)
    if args.hash:
        print(hashlib.sha256(rendered.encode()).hexdigest())
    else:
        print(rendered, end="")
