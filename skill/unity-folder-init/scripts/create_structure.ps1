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
.PARAMETER MigrateDefaults
    Unity 기본 폴더/에셋을 새 구조로 이동한다(기본 켜짐). .meta를 항상 동반 이동한다.
      Scenes/*              -> _Project/Scene/Dev
      Settings/*            -> _Project/Settings/RenderPipeline
      *.inputactions        -> _Project/Settings/Input
    끄려면 -MigrateDefaults:$false. Unity는 닫고 실행할 것을 권장한다.
.EXAMPLE
    ./create_structure.ps1 -AssetsPath "C:\MyUnityProject\Assets"
#>
param(
    [string]$AssetsPath = (Get-Location).Path,
    [switch]$Force,
    [bool]$MigrateDefaults = $true
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

# --- Unity 기본 폴더 마이그레이션 -------------------------------------------
# 에셋과 .meta를 항상 함께 옮긴다(GUID 보존 → 참조 유지). 같은 이름이 대상에 있으면 건너뛴다.
function Move-AssetWithMeta {
    param([string]$Src, [string]$DestDir)
    if (-not (Test-Path $Src)) { return $false }
    $name = Split-Path $Src -Leaf
    $destPath = Join-Path $DestDir $name
    if (Test-Path $destPath) { Write-Warning "  이미 존재해 건너뜀: $name"; return $false }
    New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    Move-Item -LiteralPath $Src -Destination $destPath
    $meta = "$Src.meta"
    if (Test-Path $meta) { Move-Item -LiteralPath $meta -Destination "$destPath.meta" }
    Write-Host "  이동: $name" -ForegroundColor DarkGray
    return $true
}

# 비워진 기본 폴더와 그 .meta 제거
function Remove-IfEmptyFolder {
    param([string]$Dir)
    if ((Test-Path $Dir) -and -not (Get-ChildItem -LiteralPath $Dir -Force | Where-Object { $_.Name -ne ".gitkeep" })) {
        Remove-Item -LiteralPath $Dir -Recurse -Force
        $m = "$Dir.meta"; if (Test-Path $m) { Remove-Item -LiteralPath $m -Force }
        Write-Host "  빈 기본 폴더 제거: $(Split-Path $Dir -Leaf)" -ForegroundColor DarkGray
    }
}

if ($MigrateDefaults) {
    Write-Host "[i] Unity 기본 폴더 마이그레이션..." -ForegroundColor Cyan
    # Scenes/* -> Scene/Dev
    $scenesDir = Join-Path $AssetsPath "Scenes"
    if (Test-Path $scenesDir) {
        Get-ChildItem -LiteralPath $scenesDir -File | Where-Object { $_.Extension -ne ".meta" } |
            ForEach-Object { Move-AssetWithMeta $_.FullName (Join-Path $AssetsPath "_Project/Scene/Dev") | Out-Null }
        Remove-IfEmptyFolder $scenesDir
    }
    # Settings/* -> Settings/RenderPipeline
    $settingsDir = Join-Path $AssetsPath "Settings"
    if (Test-Path $settingsDir) {
        Get-ChildItem -LiteralPath $settingsDir -File | Where-Object { $_.Extension -ne ".meta" } |
            ForEach-Object { Move-AssetWithMeta $_.FullName (Join-Path $AssetsPath "_Project/Settings/RenderPipeline") | Out-Null }
        Remove-IfEmptyFolder $settingsDir
    }
    # *.inputactions (Assets 루트) -> Settings/Input
    Get-ChildItem -LiteralPath $AssetsPath -File -Filter "*.inputactions" |
        ForEach-Object { Move-AssetWithMeta $_.FullName (Join-Path $AssetsPath "_Project/Settings/Input") | Out-Null }
}

# --- gitkeep 보장 패스 -------------------------------------------------------
# _Project/_Sandbox/Plugins/ThirdParty 아래에서 "내용물이 전혀 없는 빈 폴더"에 .gitkeep을 채운다.
# (이동으로 내용이 생긴 폴더의 .gitkeep은 정리한다.)
$roots = @("_Project","_Sandbox","Plugins","ThirdParty") | ForEach-Object { Join-Path $AssetsPath $_ } | Where-Object { Test-Path $_ }
$keepAdded = 0; $keepRemoved = 0
foreach ($root in $roots) {
    Get-ChildItem -LiteralPath $root -Recurse -Directory | ForEach-Object {
        $children = Get-ChildItem -LiteralPath $_.FullName -Force
        $hasSub  = $children | Where-Object { $_.PSIsContainer }
        $real    = $children | Where-Object { -not $_.PSIsContainer -and $_.Name -ne ".gitkeep" }
        $keep    = Join-Path $_.FullName ".gitkeep"
        if (-not $hasSub -and -not $real) {
            if (-not (Test-Path $keep)) { New-Item -ItemType File -Path $keep | Out-Null; $keepAdded++ }
        } elseif (Test-Path $keep) {
            # 실제 내용이 생겼으니 불필요한 .gitkeep 제거
            Remove-Item -LiteralPath $keep -Force; $keepRemoved++
            $km = "$keep.meta"; if (Test-Path $km) { Remove-Item -LiteralPath $km -Force }
        }
    }
}
Write-Host "[OK] gitkeep 보장: 추가 $keepAdded, 불필요 제거 $keepRemoved" -ForegroundColor Green

# --- 검증 --------------------------------------------------------------------
& (Join-Path $PSScriptRoot "verify_structure.ps1") -AssetsPath $AssetsPath
