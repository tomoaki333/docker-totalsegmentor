@echo off
REM Docker イメージをビルドするスクリプト

echo TotalSegmentator Docker イメージをビルド中...
echo.

docker build -t totalsegmentor-app .

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ビルドが成功しました！
    echo 実行するには run_segmentation.bat を使用してください
) else (
    echo.
    echo エラー: ビルドに失敗しました
    exit /b 1
)

pause
