<#
.SYNOPSIS
    생성된 Unity 폴더 구조가 올바른지 검증한다.
.PARAMETER AssetsPath
    대상 Unity Assets 폴더 경로. 기본값은 현재 폴더.
#>
param(
    [string]$AssetsPath = (Get-Location).Path
)

$AssetsPath = (Resolve-Path -LiteralPath $AssetsPath).Path

# 반드시 존재해야 하는 핵심 폴더
$required = @(
    "_Project/Art/Themes/_Template/Prop/Texture",
    "_Project/Art/Themes/_Template/Environment/Material",
    "_Project/Art/Themes/_Template/Animation/Controller",
    "_Project/Art/Themes/_Template/Animation/Clip",
    "_Project/Art/Themes/_Template/VFX",
    "_Project/Art/Themes/_Template/Audio",
    "_Project/Art/Themes/_Shared/Texture",
    "_Project/Art/Characters/_Template/Mesh",
    "_Project/Art/Characters/_Template/Animation/Controller",
    "_Project/Art/Characters/_Template/Animation/Clip",
    "_Project/Art/Timeline",
    "_Project/UI/Font",
    "_Project/UI/Animation/Controller",
    "_Project/UI/Animation/Clip",
    "_Project/UI/UIToolkit/USS",
    "_Project/Prefab/System",
    "_Project/Prefab/Gameplay",
    "_Project/Scene/Dev","_Project/Scene/Production","_Project/Scene/UI","_Project/Scene/Test",
    "_Project/Script/Core","_Project/Script/Editor",
    "_Project/Script/Features/_Template/Runtime",
    "_Project/Script/Features/_Template/Editor",
    "_Project/Script/Features/_Template/Tests",
    "_Project/ScriptableObject/Config","_Project/ScriptableObject/Data","_Project/ScriptableObject/Events",
    "_Project/Settings/RenderPipeline","_Project/Settings/Input",
    "_Project/Localization/StringTables","_Project/Localization/AssetTables","_Project/Localization/Locales",
    "_Project/Test/EditMode","_Project/Test/PlayMode",
    "_Sandbox",
    "Plugins",
    "ThirdParty/Libraries","ThirdParty/Art","ThirdParty/Audio","ThirdParty/Tools"
)

# 반드시 존재해야 하는 asmdef 파일 (create_structure가 생성하므로 검증으로 누락을 가리지 않는다)
$requiredFiles = @(
    "_Project/Script/Features/_Template/Runtime/Game.FeatureTemplate.asmdef",
    "_Project/Script/Features/_Template/Editor/Game.FeatureTemplate.Editor.asmdef",
    "_Project/Script/Features/_Template/Tests/Game.FeatureTemplate.Tests.asmdef",
    "_Project/Test/EditMode/Game.EditModeTests.asmdef",
    "_Project/Test/PlayMode/Game.PlayModeTests.asmdef"
)

$missing = @()
foreach ($r in $required) {
    if (-not (Test-Path (Join-Path $AssetsPath $r))) { $missing += "폴더: $r" }
}
foreach ($r in $requiredFiles) {
    if (-not (Test-Path (Join-Path $AssetsPath $r))) { $missing += "asmdef: $r" }
}

Write-Host ""
Write-Host "=== 검증 결과 ===" -ForegroundColor White
if ($missing.Count -eq 0) {
    Write-Host "[PASS] 핵심 폴더 $($required.Count)개 + asmdef $($requiredFiles.Count)개 모두 존재합니다." -ForegroundColor Green
} else {
    Write-Host "[FAIL] 누락 $($missing.Count)개:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
}

# .meta 무시 여부 경고 (실제 프로젝트에서 치명적)
# *.meta / .meta / **/*.meta / [Aa]ssets/**/*.meta 등을 폭넓게 탐지(부정 규칙 ! 과 주석 # 제외)
$projectRoot = Split-Path $AssetsPath -Parent
$gitignore = Join-Path $projectRoot ".gitignore"
if (Test-Path $gitignore) {
    $hasMetaIgnore = (Get-Content -LiteralPath $gitignore) |
        Where-Object { $_ -notmatch '^\s*[!#]' } |
        Where-Object { $_ -match '(^|\s|/)\*?\.meta\s*$' } |
        Select-Object -First 1
    if ($hasMetaIgnore) {
        Write-Host "[경고] .gitignore가 *.meta를 무시합니다 — Unity 팀 협업이 깨집니다. 해당 패턴을 제거하세요!" -ForegroundColor Yellow
    } else {
        Write-Host "[OK] .gitignore가 *.meta를 무시하지 않습니다." -ForegroundColor Green
    }
} else {
    Write-Host "[i] 프로젝트 루트에 .gitignore가 없습니다. Unity.gitignore 적용을 권장합니다." -ForegroundColor Cyan
}

if ($missing.Count -ne 0) { exit 1 }
