# TotalSegmentator GPU版 Docker イメージをビルドするスクリプト（プロキシ対応）

Write-Host "プロキシを設定中..." -ForegroundColor Cyan
$env:HTTP_PROXY = "http://gw.east.ncc.go.jp:8080"
$env:HTTPS_PROXY = "http://gw.east.ncc.go.jp:8080"

Write-Host "TotalSegmentator GPU版 Docker イメージをビルド中..." -ForegroundColor Cyan
Write-Host "（初回は30-40分かかる場合があります）" -ForegroundColor Yellow
Write-Host ""

docker build `
    --build-arg HTTP_PROXY=http://gw.east.ncc.go.jp:8080 `
    --build-arg HTTPS_PROXY=http://gw.east.ncc.go.jp:8080 `
    -f Dockerfile.gpu `
    -t totalsegmentor-app-gpu .

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "GPU版のビルドが成功しました！" -ForegroundColor Green
    Write-Host "実行するには以下のコマンドを使用してください:" -ForegroundColor Yellow
    Write-Host "  .\run_segmentation_gpu.ps1 'DICOMフォルダのパス'" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "エラー: ビルドに失敗しました" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "続行するには何かキーを押してください..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
