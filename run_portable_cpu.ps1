$scriptDir = $PSScriptRoot
$outputDir = Join-Path $scriptDir "output_segmentation"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "TotalSegmentator CPU版 (ポータブル)" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "作業ディレクトリ: $scriptDir" -ForegroundColor Gray
Write-Host ""

$env:HTTP_PROXY = "http://gw.east.ncc.go.jp:8080"
$env:HTTPS_PROXY = "http://gw.east.ncc.go.jp:8080"

Add-Type -AssemblyName System.Windows.Forms
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.Description = "DICOMファイルが含まれるフォルダを選択してください"
$folderBrowser.RootFolder = [System.Environment+SpecialFolder]::MyComputer
$folderBrowser.ShowNewFolderButton = $false

Write-Host "フォルダ選択ダイアログを開いています..." -ForegroundColor Yellow

$result = $folderBrowser.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $inputDir = $folderBrowser.SelectedPath
    Write-Host ""
    Write-Host "選択されたフォルダ: $inputDir" -ForegroundColor Green
}
else {
    Write-Host "フォルダ選択がキャンセルされました" -ForegroundColor Red
    exit 0
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "処理設定" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "入力: $inputDir" -ForegroundColor White
Write-Host "出力: $outputDir" -ForegroundColor White
Write-Host "形式: NIfTI (.nii.gz)" -ForegroundColor White
Write-Host "CPU: 使用" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    Write-Host "出力ディレクトリを作成しました" -ForegroundColor Green
}

Write-Host "処理を開始しますか？ (Y/N): " -NoNewline -ForegroundColor Yellow
$start = Read-Host

if ($start -ne "Y" -and $start -ne "y") {
    Write-Host "処理を中止しました" -ForegroundColor Red
    exit 0
}

Write-Host ""
Write-Host "Dockerコンテナを起動中..." -ForegroundColor Yellow
Write-Host "（処理には数分～数時間かかります）" -ForegroundColor Yellow
Write-Host ""

docker run --rm -e HTTP_PROXY=http://gw.east.ncc.go.jp:8080 -e HTTPS_PROXY=http://gw.east.ncc.go.jp:8080 -v "${inputDir}:/input:ro" -v "${outputDir}:/output" totalsegmentor-app /input /output nifti true

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "処理が完了しました！" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "結果: $outputDir" -ForegroundColor Cyan
    Write-Host ""
    
    $niftiFiles = Get-ChildItem -Path $outputDir -Filter "*.nii.gz" -File -ErrorAction SilentlyContinue
    if ($niftiFiles -and $niftiFiles.Count -gt 0) {
        Write-Host "生成されたファイル: $($niftiFiles.Count) 個" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "出力フォルダを開きますか？ (Y/N): " -NoNewline -ForegroundColor Yellow
    $openFolder = Read-Host
    if ($openFolder -eq "Y" -or $openFolder -eq "y") {
        explorer.exe $outputDir
    }
}
else {
    Write-Host ""
    Write-Host "エラー: 処理に失敗しました" -ForegroundColor Red
}

Write-Host ""
Write-Host "何かキーを押して終了..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
