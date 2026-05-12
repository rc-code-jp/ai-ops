#!/usr/bin/env python3
"""Render an agreed plan into an HTML file by substituting placeholders in a template.

The script is invoked by the `html-plan` Codex skill. It is deterministic: given
the same template, values JSON and output path, it always produces the same
HTML output. The generated HTML body never appears on stdout — only the saved
path is printed, so the Codex conversation history is not polluted.
"""

from __future__ import annotations

import argparse
import html
import json
import os
import re
import sys
from pathlib import Path

# Placeholder keys whose values are pre-built HTML fragments and must NOT be
# HTML-escaped before substitution. Everything else is escaped.
RAW_KEYS = {
    "TOC",
    "FILES_TABLE",
    "MUST_READ",
    "STEPS",
    "VERIFICATION",
    "CONTEXT",
}

PLACEHOLDER_RE = re.compile(r"\{\{([A-Z0-9_]+)\}\}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Render an HTML plan from a template and JSON values.",
    )
    parser.add_argument(
        "--template",
        required=True,
        help="Absolute path to the template HTML file.",
    )
    parser.add_argument(
        "--output",
        required=True,
        help="Output HTML path (repository-relative or absolute).",
    )
    parser.add_argument(
        "--values",
        help="Path to a JSON file with placeholder values. Use '-' or omit to read JSON from stdin.",
    )
    return parser.parse_args()


def load_values(path: str | None) -> dict[str, str]:
    if path is None or path == "-":
        raw = sys.stdin.read()
    else:
        raw = Path(path).read_text(encoding="utf-8")
    data = json.loads(raw)
    if not isinstance(data, dict):
        raise ValueError("values JSON must be an object at the top level")
    normalised: dict[str, str] = {}
    for key, value in data.items():
        if value is None:
            normalised[str(key)] = ""
        else:
            normalised[str(key)] = str(value)
    return normalised


def substitute(template: str, values: dict[str, str]) -> str:
    missing: list[str] = []

    def replace(match: re.Match[str]) -> str:
        key = match.group(1)
        if key not in values:
            missing.append(key)
            return ""
        raw_value = values[key]
        if key in RAW_KEYS:
            return raw_value
        return html.escape(raw_value, quote=True)

    rendered = PLACEHOLDER_RE.sub(replace, template)
    if missing:
        unique_missing = sorted(set(missing))
        print(
            f"warning: missing placeholder values: {', '.join(unique_missing)}",
            file=sys.stderr,
        )
    return rendered


def main() -> int:
    args = parse_args()

    template_path = Path(args.template)
    if not template_path.is_file():
        print(f"error: template not found: {template_path}", file=sys.stderr)
        return 2

    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    try:
        values = load_values(args.values)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"error: failed to read values JSON: {exc}", file=sys.stderr)
        return 2

    template = template_path.read_text(encoding="utf-8")
    rendered = substitute(template, values)
    output_path.write_text(rendered, encoding="utf-8")

    try:
        display_path = output_path.relative_to(Path.cwd())
        print(f"./{display_path}")
    except ValueError:
        print(str(output_path))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
