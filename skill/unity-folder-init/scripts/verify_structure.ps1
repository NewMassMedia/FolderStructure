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
    "_Project/Art/Themes/_Template/Animation",
    "_Project/Art/Themes/_Template/VFX",
    "_Project/Art/Themes/_Template/Audio",
    "_Project/Art/Themes/_Shared/Texture",
    "_Project/Art/Characters/_Template/Mesh",
    "_Project/Art/Characters/_Template/Animation",
    "_Project/Art/Timeline",
    "_Project/UI/Font",
    "_Project/UI/Animation",
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
    "Plugins","ThirdParty"
)

$missing = @()
foreach ($r in $required) {
    if (-not (Test-Path (Join-Path $AssetsPath $r))) { $missing += $r }
}

Write-Host ""
Write-Host "=== 검증 결과 ===" -ForegroundColor White
if ($missing.Count -eq 0) {
    Write-Host "[PASS] 핵심 폴더 $($required.Count)개 모두 존재합니다." -ForegroundColor Green
} else {
    Write-Host "[FAIL] 누락된 폴더 $($missing.Count)개:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
}

# .meta 무시 여부 경고 (실제 프로젝트에서 치명적)
$projectRoot = Split-Path $AssetsPath -Parent
$gitignore = Join-Path $projectRoot ".gitignore"
if (Test-Path $gitignore) {
    $hasMetaIgnore = Select-String -Path $gitignore -Pattern '^\s*\*?\.meta\s*$' -Quiet
    if ($hasMetaIgnore) {
        Write-Host "[경고] .gitignore가 *.meta를 무시합니다 — Unity 팀 협업이 깨집니다. 해당 패턴을 제거하세요!" -ForegroundColor Yellow
    } else {
        Write-Host "[OK] .gitignore가 *.meta를 무시하지 않습니다." -ForegroundColor Green
    }
} else {
    Write-Host "[i] 프로젝트 루트에 .gitignore가 없습니다. Unity.gitignore 적용을 권장합니다." -ForegroundColor Cyan
}

if ($missing.Count -ne 0) { exit 1 }
