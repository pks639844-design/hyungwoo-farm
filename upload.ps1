#Requires -Version 7.0
$ErrorActionPreference = 'Stop'

# 항상 스크립트가 있는 폴더에서 동작
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

Write-Host ""
Write-Host "===== 형우농원 자료 GitHub 업로드 =====" -ForegroundColor Cyan
Write-Host ""

# ─── 1. 스킬 폴더 동기화 ───────────────────────────────
$srcSkill = Join-Path $env:USERPROFILE ".claude\skills\hyungwoo-threads"
$dstSkill = Join-Path $scriptDir "skills\hyungwoo-threads"

if (Test-Path $srcSkill) {
    Write-Host "[1/4] 스킬 폴더 동기화" -ForegroundColor Yellow
    if (Test-Path $dstSkill) { Remove-Item $dstSkill -Recurse -Force }
    $parentDir = Split-Path $dstSkill
    if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
    Copy-Item $srcSkill $dstSkill -Recurse -Force
    Write-Host "      → skills/hyungwoo-threads/ 갱신 완료"
} else {
    Write-Host "[1/4] ~/.claude/skills/hyungwoo-threads/ 가 없어 동기화 생략" -ForegroundColor Gray
}

# ─── 2. git 저장소 초기화 ──────────────────────────────
if (-not (Test-Path ".git")) {
    Write-Host "[2/4] git 저장소 초기화" -ForegroundColor Yellow
    git init -b main *>$null
    Write-Host "      → 새 저장소 생성"
} else {
    Write-Host "[2/4] 기존 git 저장소 사용" -ForegroundColor Yellow
}

# git 사용자 정보 확인
$userName  = (git config user.name)  2>$null
$userEmail = (git config user.email) 2>$null
if (-not $userName -or -not $userEmail) {
    Write-Host ""
    Write-Host "  ! git 사용자 정보가 설정되지 않았습니다." -ForegroundColor Red
    Write-Host "    PowerShell에서 아래 두 줄을 한 번만 실행한 뒤 다시 시도하세요:" -ForegroundColor Red
    Write-Host "      git config --global user.name  ""이름""" -ForegroundColor Red
    Write-Host "      git config --global user.email ""you@example.com""" -ForegroundColor Red
    Write-Host ""
    Read-Host "엔터를 눌러 종료"
    exit 1
}

# ─── 3. 원격 저장소 확인 ───────────────────────────────
$remote = $null
try { $remote = (git remote get-url origin 2>$null) } catch {}

if (-not $remote) {
    Write-Host ""
    Write-Host "[3/4] GitHub 원격 저장소가 아직 없습니다." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "      먼저 https://github.com/new 에서 빈 저장소를 만드세요."
    Write-Host "        - Repository name: 원하는 이름 (예: hyungwoo-farm)"
    Write-Host "        - Private 권장"
    Write-Host "        - README / .gitignore / license 체크는 모두 해제 (반드시 비어 있어야 함)"
    Write-Host ""
    Write-Host "      만든 뒤 표시되는 HTTPS URL을 복사해서 붙여넣으세요."
    Write-Host "      예) https://github.com/your-id/hyungwoo-farm.git"
    Write-Host ""
    $url = Read-Host "      저장소 URL"
    if (-not $url) {
        Write-Host "URL 미입력. 종료." -ForegroundColor Red
        exit 1
    }
    git remote add origin $url.Trim()
    Write-Host "      → 원격 설정: $url"
} else {
    Write-Host "[3/4] 원격: $remote" -ForegroundColor Yellow
}

# ─── 4. add / commit / push ────────────────────────────
Write-Host "[4/4] 변경사항 커밋·푸시" -ForegroundColor Yellow

git add -A

$status = git status --porcelain
if (-not $status) {
    Write-Host "      → 변경된 파일이 없어 푸시 생략" -ForegroundColor Gray
    Write-Host ""
    Write-Host "완료." -ForegroundColor Green
    Write-Host ""
    Read-Host "엔터를 눌러 닫기"
    exit 0
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
git commit -m "Update: $timestamp" *>$null
Write-Host "      → 커밋: Update: $timestamp"

# upstream 설정 여부 확인
git rev-parse --abbrev-ref --symbolic-full-name "@{u}" *>$null 2>$null
$hasUpstream = ($LASTEXITCODE -eq 0)

try {
    if ($hasUpstream) {
        git push
    } else {
        Write-Host "      → 첫 푸시: upstream 설정"
        $branch = (git rev-parse --abbrev-ref HEAD).Trim()
        git push -u origin $branch
    }
    Write-Host ""
    Write-Host "완료. GitHub 저장소를 확인해보세요." -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "푸시 실패: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "  · 인증 창이 안 떴다면: GitHub Personal Access Token이 필요할 수 있습니다." -ForegroundColor Yellow
    Write-Host "    Settings → Developer settings → Personal access tokens (classic) → repo 권한 토큰 생성" -ForegroundColor Yellow
    Write-Host "    password 자리에 토큰 입력 → Credential Manager가 자동 저장합니다." -ForegroundColor Yellow
}

Write-Host ""
Read-Host "엔터를 눌러 닫기"
