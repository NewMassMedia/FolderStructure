#!/usr/bin/env bash
# Unity Assets 폴더에 멀티 디자이너용 폴더 구조를 생성/검증한다 (비-Windows용).
# asmdef는 만들지 않는다. 사용: ./create_structure.sh [ASSETS_PATH] [--force]
set -euo pipefail

ASSETS="${1:-$(pwd)}"
FORCE="${2:-}"
ASSETS="$(cd "$ASSETS" && pwd)"

# 대상 검증
if [[ "$(basename "$ASSETS")" != "Assets" || ! -d "$(dirname "$ASSETS")/ProjectSettings" ]] && [[ "$FORCE" != "--force" ]]; then
  echo "[경고] 대상이 Unity 'Assets' 폴더로 보이지 않습니다: $ASSETS" >&2
  echo "       맞다면 두 번째 인자로 --force 를 넣어 다시 실행하세요." >&2
  exit 1
fi

dirs=()
theme_content=(Prop/Texture Prop/Material Prop/Mesh Prop/Prefab \
  Environment/Texture Environment/Material Environment/Mesh Environment/Prefab \
  Animation/Controller Animation/Clip VFX Audio)
theme_shared=(Texture Material Mesh Prefab Animation/Controller Animation/Clip VFX Audio)
char=(Mesh Texture Material Animation/Controller Animation/Clip Prefab)

for s in "${theme_shared[@]}"; do dirs+=("_Project/Art/Themes/_Shared/$s"); done
for t in _Template ThemeA; do for c in "${theme_content[@]}"; do dirs+=("_Project/Art/Themes/$t/$c"); done; done
for k in _Shared _Template CharacterA; do for c in "${char[@]}"; do dirs+=("_Project/Art/Characters/$k/$c"); done; done

dirs+=(
  _Project/Art/Audio/Mixer _Project/Art/Audio/Music _Project/Art/Audio/Sound
  _Project/Art/Shader/Script _Project/Art/Shader/ShaderGraph
  _Project/Art/VFX/Particle _Project/Art/VFX/VFXGraph
  _Project/Art/Timeline
  _Project/UI/Font _Project/UI/Sprite _Project/UI/Prefab _Project/UI/Animation/Controller _Project/UI/Animation/Clip
  _Project/UI/UIToolkit/USS _Project/UI/UIToolkit/UXML _Project/UI/UIToolkit/Theme
  _Project/UI/UIToolkit/Setting _Project/UI/UIToolkit/Extension
  _Project/Prefab/System _Project/Prefab/Gameplay
  _Project/Scene/Dev _Project/Scene/Production _Project/Scene/UI _Project/Scene/Test
  _Project/Script/Core _Project/Script/Editor
  _Project/Script/Features/_Template/Runtime _Project/Script/Features/_Template/Editor _Project/Script/Features/_Template/Tests
  _Project/ScriptableObject/Config _Project/ScriptableObject/Data _Project/ScriptableObject/Events
  _Project/Settings/RenderPipeline _Project/Settings/Input
  _Project/Localization/StringTables _Project/Localization/AssetTables _Project/Localization/Locales
  _Project/Test/EditMode _Project/Test/PlayMode
  _Sandbox
  Plugins ThirdParty
)

count=0
for d in "${dirs[@]}"; do
  mkdir -p "$ASSETS/$d"
  [[ -f "$ASSETS/$d/.gitkeep" ]] || touch "$ASSETS/$d/.gitkeep"
  count=$((count+1))
done
echo "[OK] $count 개 폴더 생성/확인 (대상: $ASSETS)"
echo "[i] asmdef는 생성하지 않았습니다 — 코드 작성 시 Features/_Template를 복사해 만드세요."

# _Sandbox 사용법 README (각 디자이너는 _Sandbox/<이름> 폴더를 직접 만들어 자유 실험)
if [[ ! -f "$ASSETS/_Sandbox/README.md" ]]; then
  cat > "$ASSETS/_Sandbox/README.md" <<'EOF'
# _Sandbox

각 디자이너의 개인 실험 공간입니다. `_Sandbox/<내이름>` 폴더를 직접 만들어 자유롭게 작업하세요.
정해진 하위 구조는 없습니다. 검증이 끝난 결과물은 `_Project` 의 정식 폴더로 옮깁니다.

⚠️ `_Sandbox` 는 릴리스 빌드에서 제외하세요(실험물이 빌드에 섞이지 않도록).
EOF
fi

# --- Unity 기본 폴더 마이그레이션 (.meta 동반 이동, GUID 보존) ---
move_with_meta() { # $1=src file, $2=dest dir
  local src="$1" destdir="$2" name
  name="$(basename "$src")"
  [[ -e "$destdir/$name" ]] && { echo "  이미 존재해 건너뜀: $name"; return; }
  mkdir -p "$destdir"
  mv "$src" "$destdir/$name"
  [[ -f "$src.meta" ]] && mv "$src.meta" "$destdir/$name.meta"
  echo "  이동: $name"
}
remove_if_empty() { # $1=dir  (.gitkeep만 있으면 빈 것으로 간주)
  local dir="$1"
  [[ -d "$dir" ]] || return
  if [[ -z "$(find "$dir" -mindepth 1 ! -name .gitkeep -print -quit)" ]]; then
    rm -rf "$dir"; [[ -f "$dir.meta" ]] && rm -f "$dir.meta"
    echo "  빈 기본 폴더 제거: $(basename "$dir")"
  fi
}
if [[ "${MIGRATE_DEFAULTS:-1}" == "1" ]]; then
  echo "[i] Unity 기본 폴더 마이그레이션..."
  if [[ -d "$ASSETS/Scenes" ]]; then
    find "$ASSETS/Scenes" -maxdepth 1 -type f ! -name '*.meta' -print0 |
      while IFS= read -r -d '' f; do move_with_meta "$f" "$ASSETS/_Project/Scene/Dev"; done
    remove_if_empty "$ASSETS/Scenes"
  fi
  if [[ -d "$ASSETS/Settings" ]]; then
    find "$ASSETS/Settings" -maxdepth 1 -type f ! -name '*.meta' -print0 |
      while IFS= read -r -d '' f; do move_with_meta "$f" "$ASSETS/_Project/Settings/RenderPipeline"; done
    remove_if_empty "$ASSETS/Settings"
  fi
  find "$ASSETS" -maxdepth 1 -type f -name '*.inputactions' -print0 |
    while IFS= read -r -d '' f; do move_with_meta "$f" "$ASSETS/_Project/Settings/Input"; done
fi

# --- gitkeep 보장 패스: 빈 폴더엔 .gitkeep 채우고, 내용 생긴 폴더의 .gitkeep은 제거 ---
ka=0; kr=0
for root in _Project _Sandbox Plugins ThirdParty; do
  [[ -d "$ASSETS/$root" ]] || continue
  while IFS= read -r -d '' d; do
    if [[ -z "$(find "$d" -mindepth 1 ! -name .gitkeep -print -quit)" ]]; then
      [[ -f "$d/.gitkeep" ]] || { touch "$d/.gitkeep"; ka=$((ka+1)); }
    elif [[ -f "$d/.gitkeep" ]]; then
      rm -f "$d/.gitkeep" "$d/.gitkeep.meta"; kr=$((kr+1))
    fi
  done < <(find "$ASSETS/$root" -type d -print0)
done
echo "[OK] gitkeep 보장: 추가 $ka, 불필요 제거 $kr"

# --- 검증 ---
required=(
  "_Project/Art/Themes/_Template/Prop/Texture" "_Project/Art/Themes/_Template/Animation/Controller"
  "_Project/Art/Themes/_Template/Animation/Clip" "_Project/Art/Themes/_Template/VFX" "_Project/Art/Themes/_Template/Audio"
  "_Project/Art/Characters/_Template/Mesh" "_Project/Art/Timeline"
  "_Project/UI/Font" "_Project/UI/Animation/Controller" "_Project/UI/Animation/Clip" "_Project/Prefab/System" "_Project/Prefab/Gameplay"
  "_Project/Scene/Test" "_Project/Script/Features/_Template/Runtime"
  "_Project/ScriptableObject/Events" "_Project/Settings/RenderPipeline"
  "_Project/Localization/Locales" "_Project/Test/EditMode" "_Sandbox" "Plugins" "ThirdParty"
)
missing=0
for r in "${required[@]}"; do
  [[ -d "$ASSETS/$r" ]] || { echo "[FAIL] 누락: $r"; missing=$((missing+1)); }
done
echo ""
if [[ $missing -eq 0 ]]; then echo "[PASS] 핵심 폴더 ${#required[@]}개 모두 존재합니다."; else echo "[FAIL] 누락 $missing 개"; fi

gi="$(dirname "$ASSETS")/.gitignore"
if [[ -f "$gi" ]] && grep -Eq '^\s*\*?\.meta\s*$' "$gi"; then
  echo "[경고] .gitignore가 *.meta를 무시합니다 — Unity 협업이 깨집니다. 제거하세요!"
fi
[[ $missing -eq 0 ]] || exit 1
