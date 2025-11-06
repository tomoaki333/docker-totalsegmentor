# TotalSegmentator DICOM セグメンテーション

Docker を使用して DICOM ファイルから臓器セグメンテーションを自動実行し、結果を NRRD 形式で保存するプロジェクトです。

## 機能

- DICOM ファイルを自動的に読み込み
- TotalSegmentator による臓器セグメンテーション
- 結果を NRRD ファイルとして保存
- Docker による環境の一貫性

## 必要な環境

- Docker Desktop for Windows
- Git（任意）

## セットアップ

### 1. プロジェクトのクローン（Gitを使用する場合）

```bash
git clone <リポジトリURL>
cd docker-totalsegmentor
```

または、このディレクトリを `E:\docker-totalsegmentor` に配置してください。

### 2. Docker イメージのビルド

```bash
build.bat
```

または

```bash
docker build -t totalsegmentor-app .
```

初回のビルドには時間がかかります（15-30分程度）。

## 使用方法

### 🖱️ GUI版（フォルダ選択ダイアログ付き - 推奨）

#### GPU版（高速・推奨）
```powershell
.\run_segmentation_gpu_gui.ps1
```
フォルダ選択ダイアログが表示されるので、DICOMフォルダを選択するだけです。

#### CPU版（GPUがない場合）
```powershell
.\run_segmentation_gui.ps1
```
フォルダ選択ダイアログが表示されるので、DICOMフォルダを選択するだけです。

### PowerShell を使用する場合（パス指定）

```powershell
# GPU版
.\run_segmentation_gpu.ps1 "E:\medical_data\patient001"

# CPU版
.\run_segmentation.ps1 "E:\medical_data\patient001"
```

### コマンドプロンプト（cmd）を使用する場合

```bash
# ビルド
build.bat

# セグメンテーション実行
run_segmentation.bat "E:\medical_data\patient001"
```

### PowerShell でバッチファイルを実行する場合

```powershell
# 現在のディレクトリのファイルには .\ を付ける
.\build.bat
.\run_segmentation.bat "E:\medical_data\patient001"
```

### 直接 Docker コマンドを使用する場合

```bash
docker run --rm ^
    -v "DICOMディレクトリ:/input:ro" ^
    -v "E:\docker-totalsegmentor\output_segmentation:/output" ^
    totalsegmentor-app /input /output
```

### 出力

セグメンテーション結果は以下のディレクトリに保存されます:

```
E:\docker-totalsegmentor\output_segmentation\
```

各臓器ごとに個別の NRRD ファイルが生成されます:
- liver.nrrd（肝臓）
- spleen.nrrd（脾臓）
- kidney_right.nrrd（右腎臓）
- kidney_left.nrrd（左腎臓）
- heart.nrrd（心臓）
など

## プロジェクト構成

```
E:\docker-totalsegmentor\
├── Dockerfile              # Docker イメージ定義
├── docker-compose.yml      # Docker Compose 設定
├── segmentation.py         # メインスクリプト
├── build.bat              # ビルド用バッチファイル
├── run_segmentation.bat   # 実行用バッチファイル
├── .gitignore             # Git 除外設定
├── README.md              # このファイル
└── output_segmentation/   # セグメンテーション結果の保存先
```

## TotalSegmentator について

TotalSegmentator は 104 個の解剖学的構造をセグメンテーションできる AI モデルです。

主なセグメンテーション対象:
- 臓器（肝臓、腎臓、脾臓、膵臓など）
- 骨格（脊椎、肋骨、骨盤など）
- 筋肉
- 血管

詳細: https://github.com/wasserth/TotalSegmentator

## トラブルシューティング

### Docker が起動しない
- Docker Desktop が起動していることを確認してください

### メモリ不足エラー
- Docker Desktop の設定でメモリを増やしてください（推奨: 8GB以上）

### DICOM ファイルが読み込めない
- DICOM ファイルが正しいシリーズであることを確認してください
- ファイルが破損していないか確認してください

## ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。

TotalSegmentator は Apache License 2.0 です。

## 参考資料

- [TotalSegmentator GitHub](https://github.com/wasserth/TotalSegmentator)
- [3D Slicer](https://www.slicer.org/)
- [Docker Documentation](https://docs.docker.com/)
