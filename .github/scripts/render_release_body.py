import json
import os
import sys
from pathlib import Path


PLACEHOLDERS = {
    "{{KSU_VERSION}}": lambda: os.environ.get("KSU_VERSION", "unknown"),
    "{{KSU_GIT_TAG}}": lambda: os.environ.get("KSU_GIT_TAG", "no-tag"),
    "{{KSUN_BRANCH}}": lambda: os.environ.get("KSUN_BRANCH", "builtin"),
    "{{KSUN_COMMIT}}": lambda: os.environ.get("KSUN_COMMIT", "unknown"),
    "{{KSU_MANAGER}}": lambda: os.environ.get("KSU_MANAGER", "Placeholder"),
    "{{SUSFS_BRANCHES}}": lambda: os.environ.get("SUSFS_COMMIT", "latest on auto-derived gki-{version} branch"),
    "{{SUSFS_BRANCHS}}": lambda: os.environ.get("SUSFS_COMMIT", "latest on auto-derived gki-{version} branch"),
}


def render_markdown(template_path: Path):
    text = template_path.read_text()

    for placeholder, getter in PLACEHOLDERS.items():
        text = text.replace(placeholder, getter())

    print(text, end="")


config_path = Path(sys.argv[1])
if config_path.suffix.lower() == ".md":
    render_markdown(config_path)
    sys.exit(0)

# Backward-compatible JSON renderer for older release configs.

def emit(text=""):
    print(text)


def emit_list(items):
    if isinstance(items, list):
        for item in items:
            emit(f"- {item}")


def emit_description(value):
    if isinstance(value, list):
        for line in value:
            emit(line)
    elif value:
        emit(str(value))


data = json.loads(config_path.read_text())

emit("**IMPORTANT DISCLAIMER**")
for line in data["release"]["disclaimer"]:
    emit(line)

sukisu = data.get("sukisu", data.get("kernelsu", {}))
emit()
emit(f"## {sukisu.get('name', 'SukiSU Ultra')}")
emit(f"- Version: {os.environ.get('KSU_VERSION', sukisu.get('version', 'v4.1.3'))}")
emit(f"- Tag: {os.environ.get('KSU_GIT_TAG', sukisu.get('tag', 'v4.1.3'))}")
emit(f"- Branch: {os.environ.get('KSUN_BRANCH', sukisu.get('branch', 'builtin'))}")
emit(f"- Commit: {os.environ.get('KSUN_COMMIT', sukisu.get('commit', '6c13a06'))}")
if sukisu.get("url"):
    emit(f"- URL: {sukisu['url']}")
if sukisu.get("manager"):
    emit(f"- Manager: {sukisu['manager']}")

skip_keys = {"release", "sukisu", "kernelsu"}
for key in data.keys():
    if key in skip_keys:
        continue

    section = data[key]
    emit()
    emit(f"## {section.get('name', key)}")

    if section.get("description"):
        emit_description(section["description"])

    if section.get("version"):
        emit(f"- Version: {section['version']}")
    if section.get("tag"):
        emit(f"- Tag: {section['tag']}")
    if section.get("branch"):
        emit(f"- Branch: {section['branch']}")

    if key == "susfs":
        susfs_commit = os.environ.get("SUSFS_COMMIT", "")
        if susfs_commit:
            emit(f"- Commit: `{susfs_commit}`")
        else:
            emit("- Commit: latest on auto-derived gki-{version} branch")

    if section.get("items"):
        emit_list(section["items"])

    if section.get("url"):
        emit(f"- URL: {section['url']}")
