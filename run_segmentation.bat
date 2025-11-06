@echo off
REM TotalSegmentator 実行スクリプト
REM 使用方法: run_segmentation.bat "入力DICOMディレクトリのパス"

if "%~1"=="" (
    echo 使用方法: run_segmentation.bat "入力DICOMディレクトリのパス"
    echo 例: run_segmentation.bat "E:\medical_data\patient001"
    exit /b 1
)

set INPUT_DIR=%~1
set OUTPUT_DIR=E:\docker-totalsegmentor\output_segmentation

echo =====================================
echo TotalSegmentator セグメンテーション
echo =====================================
echo 入力: %INPUT_DIR%
echo 出力: %OUTPUT_DIR%
echo =====================================
echo.

REM 出力ディレクトリを作成
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM Dockerコンテナを実行
docker run --rm ^
    -v "%INPUT_DIR%:/input:ro" ^
    -v "%OUTPUT_DIR%:/output" ^
    totalsegmentor-app /input /output

echo.
echo 処理が完了しました！
echo 結果は以下に保存されています: %OUTPUT_DIR%
pause
