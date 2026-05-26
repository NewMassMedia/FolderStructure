<#
.SYNOPSIS
    이 repo의 unity-folder-init 스킬을 현재 사용자의 전역 Claude 스킬 폴더에 설치한다.
.DESCRIPTION
    .claude/skills/unity-folder-init 를 ~/.claude/skills/ 로 복사한다.
    다른 PC에서 이 repo를 clone한 뒤 실행하면 어느 프로젝트에서나 스킬을 쓸 수 있다.
.EXAMPLE
    pwsh ./install-skill.ps1
#>
$ErrorActionPreference = "Stop"

$repoRoot = $PSScriptRoot
$source   = Join-Path $repoRoot "skill\unity-folder-init"
$destRoot = Join-Path $HOME ".claude\skills"
$dest     = Join-Path $destRoot "unity-folder-init"

if (-not (Test-Path $source)) { Write-Error "스킬 소스를 찾을 수 없습니다: $source"; exit 1 }

New-Item -ItemType Directory -Path $destRoot -Force | Out-Null
if (Test-Path $dest) {
    Write-Host "[i] 기존 설치를 덮어씁니다: $dest" -ForegroundColor Yellow
    Remove-Item -Recurse -Force $dest
}
Copy-Item -Path $source -Destination $destRoot -Recurse -Force

Write-Host "[OK] 설치 완료: $dest" -ForegroundColor Green
Write-Host "[i] Claude Code를 재시작하면 'unity-folder-init' 스킬을 어느 프로젝트에서나 쓸 수 있습니다." -ForegroundColor Cyan
