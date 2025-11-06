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
    
    # フォルダ内のファイル数を確認
    $files = Get-ChildItem -Path $outputDir -File -Recurse
    $fileCount = $files.Count
    
    if ($fileCount -gt 0) {
        Write-Host "  削除するファイル: $fileCount 個" -ForegroundColor White
        
        # ユーザーに確認
        Write-Host "  これらのファイルを削除してからpushしますか？ (Y/N): " -NoNewline -ForegroundColor Cyan
        $confirm = Read-Host
        
        if ($confirm -eq "Y" -or $confirm -eq "y") {
            # ファイルを削除（フォルダは残す）
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

# ステップ1: Gitの初期化
Write-Host "[1/5] Gitリポジトリを初期化中..." -ForegroundColor Yellow
git init
if ($LASTEXITCODE -ne 0) {
    Write-Host "エラー: Git初期化に失敗しました" -ForegroundColor Red
    pause
    exit 1
}
Write-Host "✓ 初期化完了" -ForegroundColor Green

# ステップ2: ファイルをステージング
Write-Host ""
Write-Host "[2/5] ファイルをステージング中..." -ForegroundColor Yellow
git add .
if ($LASTEXITCODE -ne 0) {
    Write-Host "エラー: ファイルのステージングに失敗しました" -ForegroundColor Red
    pause
    exit 1
}

# ステージングされたファイルを表示
$stagedFiles = git diff --cached --name-only
Write-Host "✓ ステージング完了 ($($stagedFiles.Count) ファイル)" -ForegroundColor Green

# ステップ3: コミット
Write-Host ""
Write-Host "[3/5] コミット作成中..." -ForegroundColor Yellow
git commit -m "Initial commit: TotalSegmentator Docker project with MATLAB integration"
if ($LASTEXITCODE -ne 0) {
    Write-Host "エラー: コミットに失敗しました" -ForegroundColor Red
    pause
    exit 1
}
Write-Host "✓ コミット完了" -ForegroundColor Green

# ステップ4: リモートリポジトリを設定
Write-Host ""
Write-Host "[4/5] リモートリポジトリを設定中..." -ForegroundColor Yellow
git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "警告: リモートリポジトリの追加に失敗（既に存在する可能性）" -ForegroundColor Yellow
}

# ブランチ名を main に変更
git branch -M main
Write-Host "✓ リモート設定完了" -ForegroundColor Green

# ステップ5: プッシュ
Write-Host ""
Write-Host "[5/5] GitHub にプッシュ中..." -ForegroundColor Yellow
Write-Host "認証情報の入力を求められます" -ForegroundColor Cyan
Write-Host ""

git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "アップロード成功！" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "リポジトリURL:" -ForegroundColor White
    Write-Host "https://github.com/$GITHUB_USER/$REPO_NAME" -ForegroundColor Cyan
    Write-Host ""
    
    # ブラウザで開く
    Write-Host "ブラウザでリポジトリを開きますか？ (Y/N): " -NoNewline -ForegroundColor Yellow
    $openBrowser = Read-Host
    if ($openBrowser -eq "Y" -or $openBrowser -eq "y") {
        Start-Process "https://github.com/$GITHUB_USER/$REPO_NAME"
    }
} else {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host "エラー: プッシュに失敗しました" -ForegroundColor Red
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "考えられる原因:" -ForegroundColor Yellow
    Write-Host "  1. GitHubでリポジトリがまだ作成されていない" -ForegroundColor White
    Write-Host "  2. 認証情報が正しくない" -ForegroundColor White
    Write-Host "  3. Personal Access Token が必要" -ForegroundColor White
    Write-Host ""
    Write-Host "解決方法:" -ForegroundColor Yellow
    Write-Host "  1. https://github.com/$GITHUB_USER にアクセス" -ForegroundColor White
    Write-Host "  2. 'New repository' をクリック" -ForegroundColor White
    Write-Host "  3. Repository name: $REPO_NAME" -ForegroundColor White
    Write-Host "  4. 'Create repository' をクリック" -ForegroundColor White
    Write-Host "  5. このスクリプトを再実行" -ForegroundColor White
    Write-Host ""
}

Write-Host ""
Write-Host "続行するには何かキーを押してください..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
