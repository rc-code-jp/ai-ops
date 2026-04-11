#!/usr/bin/env bash
set -euo pipefail

PLUGIN_NAME="multi-agent-coordination"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_SOURCE="${REPO_ROOT}/codex-plugins/${PLUGIN_NAME}"
PLUGIN_TARGET="${HOME}/plugins/${PLUGIN_NAME}"
MARKETPLACE_PATH="${HOME}/.agents/plugins/marketplace.json"

if [[ ! -f "${PLUGIN_SOURCE}/.codex-plugin/plugin.json" ]]; then
  echo "plugin.json が見つかりません: ${PLUGIN_SOURCE}/.codex-plugin/plugin.json" >&2
  exit 1
fi

mkdir -p "${HOME}/plugins" "$(dirname "${MARKETPLACE_PATH}")"
ln -sfn "${PLUGIN_SOURCE}" "${PLUGIN_TARGET}"

python3 - "${MARKETPLACE_PATH}" "${PLUGIN_NAME}" <<'PY'
import json
import sys
from pathlib import Path

marketplace_path = Path(sys.argv[1])
plugin_name = sys.argv[2]

if marketplace_path.exists():
    data = json.loads(marketplace_path.read_text())
else:
    data = {
        "name": "local-codex-plugins",
        "interface": {"displayName": "Local Codex Plugins"},
        "plugins": [],
    }

data.setdefault("name", "local-codex-plugins")
data.setdefault("interface", {}).setdefault("displayName", "Local Codex Plugins")
plugins = data.setdefault("plugins", [])

entry = {
    "name": plugin_name,
    "source": {
        "source": "local",
        "path": f"./plugins/{plugin_name}",
    },
    "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL",
    },
    "category": "Developer Tools",
}

for index, existing in enumerate(plugins):
    if existing.get("name") == plugin_name:
        plugins[index] = entry
        break
else:
    plugins.append(entry)

marketplace_path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")
PY

echo "${PLUGIN_NAME} を ${PLUGIN_TARGET} にインストールしました。"
