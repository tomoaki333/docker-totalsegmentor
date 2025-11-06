# TotalSegmentator GPU版 実行スクリプト (PowerShell版・プロキシ対応)
# 使用方法: .\run_segmentation_gpu.ps1 "入力DICOMディレクトリのパス"

param(
    [Parameter(Mandatory=$true)]
    [string]$InputDir,
    [string]$OutputFormat = "nifti"
)

# プロキシ設定
$env:HTTP_PROXY = "http://gw.east.ncc.go.jp:8080"
$env:HTTPS_PROXY = "http://gw.east.ncc.go.jp:8080"

# パラメータチェック
if (-not (Test-Path $InputDir)) {
    Write-Host "エラー: 指定されたディレクトリが存在しません: $InputDir" -ForegroundColor Red
    exit 1
}

$OutputDir = "E:\docker-totalsegmentor\output_segmentation"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "TotalSegmentator GPU版 セグメンテーション" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "入力: $InputDir" -ForegroundColor White
Write-Host "出力: $OutputDir" -ForegroundColor White
Write-Host "形式: $OutputFormat" -ForegroundColor White
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 出力ディレクトリを作成
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    Write-Host "出力ディレクトリを作成しました: $OutputDir" -ForegroundColor Green
}

# Dockerコンテナを実行（GPU対応）
Write-Host "Dockerコンテナを起動中（GPU使用）..." -ForegroundColor Yellow
Write-Host ""

docker run --rm --gpus all `
    -e HTTP_PROXY=http://gw.east.ncc.go.jp:8080 `
    -e HTTPS_PROXY=http://gw.east.ncc.go.jp:8080 `
    -v "${InputDir}:/input:ro" `
    -v "${OutputDir}:/output" `
    totalsegmentor-app-gpu /input /output $OutputFormat false

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "処理が完了しました！" -ForegroundColor Green
    Write-Host "結果は以下に保存されています: $OutputDir" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "エラー: 処理に失敗しました" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "続行するには何かキーを押してください..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
