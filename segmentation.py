#!/usr/bin/env python3
"""
DICOM から TotalSegmentator を使用してセグメンテーションを実行し、
結果を NRRD ファイルとして保存するスクリプト
"""

import os
import sys
import subprocess
import tempfile
import shutil
from pathlib import Path
import pydicom
import SimpleITK as sitk


def convert_dicom_to_nifti(dicom_dir, output_nifti):
    """
    DICOM シリーズを NIfTI 形式に変換
    
    Args:
        dicom_dir: DICOM ファイルがあるディレクトリ
        output_nifti: 出力する NIfTI ファイルのパス
    """
    print(f"DICOM ディレクトリを読み込み中: {dicom_dir}")
    
    # DICOM シリーズを読み込む
    reader = sitk.ImageSeriesReader()
    dicom_names = reader.GetGDCMSeriesFileNames(str(dicom_dir))
    
    if not dicom_names:
        raise ValueError(f"DICOM ファイルが見つかりません: {dicom_dir}")
    
    print(f"{len(dicom_names)} 枚の DICOM ファイルを検出")
    
    reader.SetFileNames(dicom_names)
    image = reader.Execute()
    
    # NIfTI として保存
    sitk.WriteImage(image, str(output_nifti))
    print(f"NIfTI ファイルを作成: {output_nifti}")
    
    return image


def run_totalsegmentator(input_nifti, output_dir, use_fast=True):
    """
    TotalSegmentator を実行
    
    Args:
        input_nifti: 入力 NIfTI ファイル
        output_dir: セグメンテーション結果の出力ディレクトリ
        use_fast: 高速モードを使用するか（デフォルト: True）
    """
    print("TotalSegmentator を実行中...")
    
    cmd = [
        "TotalSegmentator",
        "-i", str(input_nifti),
        "-o", str(output_dir)
    ]
    
    # 高速モード（精度は若干低下するが速い）
    if use_fast:
        cmd.append("--fast")
    
    # 個別の臓器ファイルを出力（--mlは使用しない）
    
    print(f"コマンド: {' '.join(cmd)}")
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode != 0:
        print(f"エラー: {result.stderr}")
        raise RuntimeError("TotalSegmentator の実行に失敗しました")
    
    print("TotalSegmentator の実行が完了しました")
    print(result.stdout)


def convert_nifti_to_nrrd(nifti_path, nrrd_path):
    """
    NIfTI ファイルを NRRD 形式に変換
    
    Args:
        nifti_path: 入力 NIfTI ファイル
        nrrd_path: 出力 NRRD ファイル
    """
    image = sitk.ReadImage(str(nifti_path))
    sitk.WriteImage(image, str(nrrd_path))
    print(f"NRRD ファイルを作成: {nrrd_path}")


def process_segmentation(input_dicom_dir, output_segmentation_dir, output_format="nrrd", use_fast=True):
    """
    メイン処理: DICOM からセグメンテーション、指定形式で出力
    
    Args:
        input_dicom_dir: 入力 DICOM ディレクトリ
        output_segmentation_dir: 出力ディレクトリ
        output_format: 出力形式 ("nrrd" または "nifti")
        use_fast: 高速モードを使用するか
    """
    input_path = Path(input_dicom_dir)
    output_path = Path(output_segmentation_dir)
    
    if not input_path.exists():
        raise ValueError(f"入力ディレクトリが存在しません: {input_dicom_dir}")
    
    # 出力ディレクトリを作成
    output_path.mkdir(parents=True, exist_ok=True)
    
    # 一時ディレクトリを作成
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        
        # ステップ 1: DICOM を NIfTI に変換
        temp_nifti = temp_path / "input.nii.gz"
        convert_dicom_to_nifti(input_path, temp_nifti)
        
        # ステップ 2: TotalSegmentator を実行
        temp_seg_dir = temp_path / "segmentations"
        run_totalsegmentator(temp_nifti, temp_seg_dir, use_fast=use_fast)
        
        # ステップ 3: 結果を指定形式で保存
        print(f"\nセグメンテーション結果を {output_format.upper()} 形式で保存中...")
        
        # 各臓器のセグメンテーションファイルを処理
        seg_files = list(temp_seg_dir.glob("*.nii.gz"))
        
        if not seg_files:
            # ファイルが見つからない場合、別のパターンを確認
            seg_files = list(temp_seg_dir.glob("*.nii"))
        
        if not seg_files:
            print("警告: セグメンテーションファイルが見つかりません")
            print(f"一時ディレクトリの内容:")
            for item in temp_seg_dir.iterdir():
                print(f"  - {item}")
            return
        
        for seg_file in seg_files:
            organ_name = seg_file.stem.replace(".nii", "")
            
            if output_format.lower() == "nrrd":
                output_file = output_path / f"{organ_name}.nrrd"
                convert_nifti_to_nrrd(seg_file, output_file)
            else:  # nifti
                output_file = output_path / f"{organ_name}.nii.gz"
                shutil.copy(seg_file, output_file)
                print(f"NIfTI ファイルをコピー: {output_file}")
        
        print(f"\n完了: {len(seg_files)} 個のセグメンテーションファイルを {output_format.upper()} として保存しました")
        print(f"出力ディレクトリ: {output_path}")


def main():
    """メイン関数"""
    if len(sys.argv) < 3:
        print("使用方法: python segmentation.py <入力DICOMディレクトリ> <出力ディレクトリ> [出力形式: nrrd/nifti] [fast: true/false]")
        sys.exit(1)
    
    input_dicom_dir = sys.argv[1]
    output_segmentation_dir = sys.argv[2]
    output_format = sys.argv[3] if len(sys.argv) > 3 else "nifti"  # デフォルトはNIfTI
    use_fast = sys.argv[4].lower() != "false" if len(sys.argv) > 4 else True  # デフォルトは高速モード
    
    print("=" * 60)
    print("TotalSegmentator DICOM セグメンテーション")
    print("=" * 60)
    print(f"入力: {input_dicom_dir}")
    print(f"出力: {output_segmentation_dir}")
    print(f"出力形式: {output_format.upper()}")
    print(f"高速モード: {'有効' if use_fast else '無効'}")
    print("=" * 60)
    print()
    
    try:
        process_segmentation(input_dicom_dir, output_segmentation_dir, output_format, use_fast)
        print("\n処理が正常に完了しました!")
    except Exception as e:
        print(f"\nエラーが発生しました: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
