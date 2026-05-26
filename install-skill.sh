#!/usr/bin/env bash
# 이 repo의 unity-folder-init 스킬을 ~/.claude/skills/ 에 설치한다 (macOS/Linux).
# 사용: ./install-skill.sh
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$repo_root/skill/unity-folder-init"
dest_root="$HOME/.claude/skills"
dest="$dest_root/unity-folder-init"

if [[ ! -d "$source_dir" ]]; then
  echo "스킬 소스를 찾을 수 없습니다: $source_dir" >&2
  exit 1
fi

mkdir -p "$dest_root"
if [[ -d "$dest" ]]; then
  echo "[i] 기존 설치를 덮어씁니다: $dest"
  rm -rf "$dest"
fi
cp -R "$source_dir" "$dest_root/"
chmod +x "$dest"/scripts/*.sh 2>/dev/null || true

echo "[OK] 설치 완료: $dest"
echo "[i] Claude Code를 재시작하면 'unity-folder-init' 스킬을 어느 프로젝트에서나 쓸 수 있습니다."
