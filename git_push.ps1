# GitHub にプロジェクトをアップロードするスクリプト (PowerShell版)

$GITHUB_USER = "tomoaki333"
$REPO_NAME = "docker-totalsegmentor"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "GitHub へのアップロード" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "ユーザー: $GITHUB_USER" -ForegroundColor White
Write-Host "リポジトリ: $REPO_NAME" -ForegroundColor White
Write-Host ""

# output_segmentation フォルダのクリーンアップ
$outputDir = "output_segmentation"
if (Test-Path $outputDir) {
    Write-Host "output_segmentation フォルダのファイルをクリーンアップ中..." -ForegroundColor Yellow
    
    $files = Get-ChildItem -Path $outputDir -File -Recurse
    $fileCount = $files.Count
    
    if ($fileCount -gt 0) {
        Write-Host "  削除するファイル: $fileCount 個" -ForegroundColor White
        Write-Host "  これらのファイルを削除してからpushしますか？ (Y/N): " -NoNewline -ForegroundColor Cyan
        $confirm = Read-Host
        
        if ($confirm -eq "Y" -or $confirm -eq "y") {
            Remove-Item -Path "$outputDir\*" -Recurse -Force
            Write-Host "  ✓ ファイルを削除しました" -ForegroundColor Green
        } else {
            Write-Host "  スキップしました（.gitignoreで除外されます）" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ✓ フォルダは空です" -ForegroundColor Green
    }
} else {
    Write-Host "output_segmentation フォルダが存在しません（作成します）" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    Write-Host "  ✓ フォルダを作成しました" -ForegroundColor Green
}

Write-Host ""

# Gitがインストールされているか確認
try {
    $gitVersion = git --version
    Write-Host "Git: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "エラー: Gitがインストールされていません" -ForegroundColor Red
    Write-Host "https://git-scm.com/ からダウンロードしてください" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host ""

# 変更されたファイルを確認
Write-Host "変更されたファイルを確認中..." -ForegroundColor Yellow
git status

Write-Host ""
Write-Host "これらの変更をコミットしますか？ (Y/N): " -NoNewline -ForegroundColor Yellow
$continue = Read-Host
if ($continue -ne "Y" -and $continue -ne "y") {
    Write-Host "処理を中止しました" -ForegroundColor Red
    exit 0
}

# ステップ1: ファイルをステージング
Write-Host ""
Write-Host "[1/3] ファイルをステージング中..." -ForegroundColor Yellow
git add .
if ($LASTEXITCODE -ne 0) {
    Write-Host "エラー: ファイルのステージングに失敗しました" -ForegroundColor Red
    pause
    exit 1
}
Write-Host "✓ ステージング完了" -ForegroundColor Green

# ステップ2: コミット
Write-Host ""
Write-Host "[2/3] コミット作成中..." -ForegroundColor Yellow
git commit -m "Fix: GUI script syntax errors and improve documentation"
if ($LASTEXITCODE -ne 0) {
    Write-Host "エラー: コミットに失敗しました" -ForegroundColor Red
    pause
    exit 1
}
Write-Host "✓ コミット完了" -ForegroundColor Green

# ステップ3: プッシュ
Write-Host ""
Write-Host "[3/3] GitHub にプッシュ中..." -ForegroundColor Yellow
Write-Host "認証情報の入力を求められる場合があります" -ForegroundColor Cyan
Write-Host ""

git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "アップロード成功！" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "リポジトリURL:" -ForegroundColor White
    Write-Host "https://github.com/$GITHUB_USER/$REPO_NAME" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host "エラー: プッシュに失敗しました" -ForegroundColor Red
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host ""
}

Write-Host ""
Write-Host "続行するには何かキーを押してください..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
