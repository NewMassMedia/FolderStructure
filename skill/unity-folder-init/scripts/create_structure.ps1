<#
.SYNOPSIS
    Unity 프로젝트의 Assets 폴더에 멀티 디자이너용 폴더 구조를 생성한다.
.DESCRIPTION
    콘텐츠/타입 하이브리드 구조(_Project, _Sandbox, Plugins, ThirdParty)를 .gitkeep과 함께 만든다.
    asmdef 파일은 만들지 않는다 (코드 작성 시 프로젝트에서 생성). 생성 후 검증을 자동 수행한다.
.PARAMETER AssetsPath
    대상 Unity Assets 폴더 경로. 기본값은 현재 폴더.
.PARAMETER Force
    Assets 폴더가 아닌 곳(ProjectSettings 형제 없음)에도 강제로 생성.
.EXAMPLE
    ./create_structure.ps1 -AssetsPath "C:\MyUnityProject\Assets"
#>
param(
    [string]$AssetsPath = (Get-Location).Path,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# --- 대상 검증 ---------------------------------------------------------------
$resolved = Resolve-Path -LiteralPath $AssetsPath -ErrorAction SilentlyContinue
if (-not $resolved) { Write-Error "경로를 찾을 수 없습니다: $AssetsPath"; exit 1 }
$AssetsPath = $resolved.Path

$projectRoot = Split-Path $AssetsPath -Parent
$leaf = Split-Path $AssetsPath -Leaf
$looksLikeAssets = ($leaf -eq "Assets") -and (Test-Path (Join-Path $projectRoot "ProjectSettings"))
if (-not $looksLikeAssets -and -not $Force) {
    Write-Warning "대상이 Unity 'Assets' 폴더로 보이지 않습니다 (ProjectSettings 형제 폴더 없음)."
    Write-Warning "경로: $AssetsPath"
    Write-Warning "맞다면 -Force 를 붙여 다시 실행하세요."
    exit 1
}

# --- 폴더 정의 ---------------------------------------------------------------
$themeContent = @("Prop/Texture","Prop/Material","Prop/Mesh","Prop/Prefab",
                  "Environment/Texture","Environment/Material","Environment/Mesh","Environment/Prefab",
                  "Animation","VFX","Audio")
$themeShared  = @("Texture","Material","Mesh","Prefab","Animation","VFX","Audio")
$charDirs     = @("Mesh","Texture","Material","Animation","Prefab")

$dirs = New-Object System.Collections.Generic.List[string]

# Art / Themes
foreach ($s in $themeShared) { $dirs.Add("_Project/Art/Themes/_Shared/$s") }
foreach ($t in @("_Template","ThemeA")) { foreach ($c in $themeContent) { $dirs.Add("_Project/Art/Themes/$t/$c") } }
# Art / Characters
foreach ($k in @("_Shared","_Template","CharacterA")) { foreach ($c in $charDirs) { $dirs.Add("_Project/Art/Characters/$k/$c") } }
# Art / 기타
$dirs.AddRange([string[]]@(
    "_Project/Art/Audio/Mixer","_Project/Art/Audio/Music","_Project/Art/Audio/Sound",
    "_Project/Art/Shader/Script","_Project/Art/Shader/ShaderGraph",
    "_Project/Art/VFX/Particle","_Project/Art/VFX/VFXGraph",
    "_Project/Art/Timeline",
    "_Project/UI/Font","_Project/UI/Sprite","_Project/UI/Prefab","_Project/UI/Animation",
    "_Project/UI/UIToolkit/USS","_Project/UI/UIToolkit/UXML","_Project/UI/UIToolkit/Theme",
    "_Project/UI/UIToolkit/Setting","_Project/UI/UIToolkit/Extension",
    "_Project/Prefab/System","_Project/Prefab/Gameplay",
    "_Project/Scene/Dev","_Project/Scene/Production","_Project/Scene/UI","_Project/Scene/Test",
    "_Project/Script/Core","_Project/Script/Editor",
    "_Project/Script/Features/_Template/Runtime","_Project/Script/Features/_Template/Editor","_Project/Script/Features/_Template/Tests",
    "_Project/ScriptableObject/Config","_Project/ScriptableObject/Data","_Project/ScriptableObject/Events",
    "_Project/Settings/RenderPipeline","_Project/Settings/Input",
    "_Project/Localization/StringTables","_Project/Localization/AssetTables","_Project/Localization/Locales",
    "_Project/Test/EditMode","_Project/Test/PlayMode",
    "_Sandbox/_Template",
    "Plugins","ThirdParty"
))

# --- 생성 --------------------------------------------------------------------
$created = 0
foreach ($d in $dirs) {
    $full = Join-Path $AssetsPath $d
    if (-not (Test-Path $full)) { New-Item -ItemType Directory -Path $full -Force | Out-Null }
    $keep = Join-Path $full ".gitkeep"
    if (-not (Test-Path $keep)) { New-Item -ItemType File -Path $keep | Out-Null }
    $created++
}
Write-Host "[OK] $created 개 폴더 생성/확인 (대상: $AssetsPath)" -ForegroundColor Green
Write-Host "[i] asmdef는 생성하지 않았습니다 — 코드 작성 시 Features/_Template를 복사해 만드세요." -ForegroundColor Cyan

# --- 검증 --------------------------------------------------------------------
& (Join-Path $PSScriptRoot "verify_structure.ps1") -AssetsPath $AssetsPath
