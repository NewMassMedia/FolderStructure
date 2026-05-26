# 스킬 설치 가이드 (Claude가 따라 실행)

이 repo의 `unity-folder-init` 스킬을 사용자의 전역 Claude 스킬 폴더에 설치한다.

## 할 일
`skill/unity-folder-init` 폴더 **전체**를 사용자 홈의 `~/.claude/skills/` 아래로 복사한다.
즉 최종 결과는 `~/.claude/skills/unity-folder-init/`(그 안에 `SKILL.md`, `scripts/`, `reference/`)가 된다.

## 절차
1. 대상 경로를 확인한다: `~/.claude/skills/` (Windows는 `%USERPROFILE%\.claude\skills\`).
   없으면 만든다.
2. 기존에 `unity-folder-init`가 있으면 덮어쓸지 사용자에게 확인 후 교체한다.
3. `skill/unity-folder-init` 폴더를 하위 파일까지 통째로 복사한다.
   - macOS/Linux: `cp -R skill/unity-folder-init ~/.claude/skills/`
   - Windows PowerShell: `Copy-Item skill\unity-folder-init "$HOME\.claude\skills\" -Recurse -Force`
4. 복사 후 `~/.claude/skills/unity-folder-init/SKILL.md` 가 존재하는지 확인한다.
5. 사용자에게 "Claude Code 재시작 후 활성화된다"고 안내한다.

## 설치 후 사용
대상 Unity 프로젝트에서 "유니티 폴더 구조 초기화해줘"라고 하면 스킬이 동작한다.
스킬 자체의 동작 방식은 `unity-folder-init/SKILL.md` 참조.
