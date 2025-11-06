FROM python:3.10-slim

# 必要なシステムパッケージのインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリの設定
WORKDIR /app

# Python パッケージのインストール
RUN pip install --no-cache-dir \
    TotalSegmentator \
    pydicom \
    SimpleITK \
    numpy \
    pynrrd

# 入力・出力ディレクトリの作成
RUN mkdir -p /input /output

# スクリプトをコピー
COPY segmentation.py /app/

# エントリーポイント
ENTRYPOINT ["python", "/app/segmentation.py"]
