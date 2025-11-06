# TotalSegmentator GPU版 実行スクリプト - フォルダ選択GUI付き

param(
    [string]$OutputFormat = "nifti"
)

$env:HTTP_PROXY = "http://gw.east.ncc.go.jp:8080"
$env:HTTPS_PROXY = "http://gw.east.ncc.go.jp:8080"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "TotalSegmentator GPU版" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

Add-Type -AssemblyName System.Windows.Forms

$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.Description = "DICOMファイルが含まれるフォルダを選択してください"
$folderBrowser.RootFolder = [System.Environment+SpecialFolder]::MyComputer
$folderBrowser.ShowNewFolderButton = $false

Write-Host "フォルダ選択ダイアログを開いています..." -ForegroundColor Yellow

$result = $folderBrowser.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $InputDir = $folderBrowser.SelectedPath
    Write-Host ""
    Write-Host "選択されたフォルダ: $InputDir" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "フォルダ選択がキャンセルされました" -ForegroundColor Red
    exit 0
}

$OutputDir = "E:\docker-totalsegmentor\output_segmentation"

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "処理設定" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "入力: $InputDir" -ForegroundColor White
Write-Host "出力: $OutputDir" -ForegroundColor White
Write-Host "形式: $OutputFormat" -ForegroundColor White
Write-Host "GPU: 使用" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Write-Host "Dockerコンテナを起動中（GPU使用）..." -ForegroundColor Yellow
Write-Host ""

docker run --rm --gpus all -e HTTP_PROXY=http://gw.east.ncc.go.jp:8080 -e HTTPS_PROXY=http://gw.east.ncc.go.jp:8080 -v "${InputDir}:/input:ro" -v "${OutputDir}:/output" totalsegmentor-app-gpu /input /output $OutputFormat false

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "処理が完了しました！" -ForegroundColor Green
    Write-Host "結果: $OutputDir" -ForegroundColor Cyan
    explorer.exe $OutputDir
} else {
    Write-Host ""
    Write-Host "エラー: 処理に失敗しました" -ForegroundColor Red
}

Write-Host ""
Write-Host "キーを押して終了..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
