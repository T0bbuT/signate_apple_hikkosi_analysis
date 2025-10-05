# ============================================
# Githubポートフォリオ用 フォルダを portfolio リモート(main)へ subtree push するスクリプト
# 実行場所：作業repoのルート
# ============================================

# --- エラー発生時に中断 ---
$ErrorActionPreference = "Stop"

# リポジトリルート(2つ上を想定)へ移動
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $RepoRoot

# --- カレントパスを表示 ---
Write-Host "現在のディレクトリ: $((Get-Location).Path)" -ForegroundColor Cyan

# --- リモート確認 ---
$remoteName = "portfolio"
$branchName = "main"
$prefixPath = "Githubポートフォリオ用"

Write-Host "`n=== git subtree push 実行 ===" -ForegroundColor Yellow
Write-Host "  prefix : $prefixPath"
Write-Host "  remote : $remoteName"
Write-Host "  branch : $branchName`n"

# --- 実行前の確認 ---
$confirm = Read-Host "実行してよろしいですか？ (y/n)"
if ($confirm -ne "y") {
    Write-Host "キャンセルしました。" -ForegroundColor Red
    exit
}

# --- 未コミット確認 ---
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "`n⚠ 未コミットの変更があります。先にコミットしてください。" -ForegroundColor Red
    Pause
    exit 1
}

# --- push 実行 ---
try {
    git subtree push --prefix="$prefixPath" $remoteName $branchName
    Write-Host "`n✅ subtree push 完了！" -ForegroundColor Green
    Pause
} catch {
    Write-Host "`n❌ エラー発生:" $_.Exception.Message -ForegroundColor Red
    Pause
}