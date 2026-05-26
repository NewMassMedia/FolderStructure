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
  Animation VFX Audio)
theme_shared=(Texture Material Mesh Prefab Animation VFX Audio)
char=(Mesh Texture Material Animation Prefab)

for s in "${theme_shared[@]}"; do dirs+=("_Project/Art/Themes/_Shared/$s"); done
for t in _Template ThemeA; do for c in "${theme_content[@]}"; do dirs+=("_Project/Art/Themes/$t/$c"); done; done
for k in _Shared _Template CharacterA; do for c in "${char[@]}"; do dirs+=("_Project/Art/Characters/$k/$c"); done; done

dirs+=(
  _Project/Art/Audio/Mixer _Project/Art/Audio/Music _Project/Art/Audio/Sound
  _Project/Art/Shader/Script _Project/Art/Shader/ShaderGraph
  _Project/Art/VFX/Particle _Project/Art/VFX/VFXGraph
  _Project/Art/Timeline
  _Project/UI/Font _Project/UI/Sprite _Project/UI/Prefab _Project/UI/Animation
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
  _Sandbox/_Template
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

# --- 검증 ---
required=(
  "_Project/Art/Themes/_Template/Prop/Texture" "_Project/Art/Themes/_Template/Animation"
  "_Project/Art/Themes/_Template/VFX" "_Project/Art/Themes/_Template/Audio"
  "_Project/Art/Characters/_Template/Mesh" "_Project/Art/Timeline"
  "_Project/UI/Font" "_Project/UI/Animation" "_Project/Prefab/System" "_Project/Prefab/Gameplay"
  "_Project/Scene/Test" "_Project/Script/Features/_Template/Runtime"
  "_Project/ScriptableObject/Events" "_Project/Settings/RenderPipeline"
  "_Project/Localization/Locales" "_Project/Test/EditMode" "_Sandbox/_Template" "Plugins" "ThirdParty"
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
