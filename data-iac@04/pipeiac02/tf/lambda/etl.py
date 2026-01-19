# lambda/etl.py
# JSON→Parquet変換を行うLambda関数

import json
import boto3
import pandas as pd
from datetime import datetime
import os
import logging

# ロガー設定
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# S3クライアント
s3 = boto3.client('s3')


def handler(event, context):
    """
    JSON → Parquet 変換処理

    Args:
        event: Step Functionsから渡されるイベント
            - input_key: S3上のJSONファイルパス
        context: Lambda実行コンテキスト

    Returns:
        dict: 処理結果
            - statusCode: HTTPステータスコード
            - output_key: 出力したParquetファイルのパス
            - record_count: 処理したレコード数
    """
    logger.info(f"Event: {json.dumps(event)}")

    # 環境変数からバケット名を取得
    raw_bucket = os.environ['RAW_BUCKET']
    processed_bucket = os.environ['PROCESSED_BUCKET']

    try:
        # 1. 入力キーを取得
        input_key = event['input_key']
        logger.info(f"Processing: s3://{raw_bucket}/{input_key}")

        # 2. S3からJSONを読み込み
        response = s3.get_object(Bucket=raw_bucket, Key=input_key)
        data = json.loads(response['Body'].read().decode('utf-8'))

        # 3. DataFrameに変換
        df = pd.DataFrame(data)
        logger.info(f"Loaded {len(df)} records")

        # 4-1. パーティションキーを生成（年/月でパーティション）
        now = datetime.now()
        year, month = now.strftime('%Y'), now.strftime('%m')
        timestamp = now.strftime('%Y%m%d_%H%M%S')

        # 4-2. 出力キーを生成
        output_key = f"processed/year={year}/month={month}/data_{timestamp}.parquet"

        # 5. Parquetに変換してS3に保存
        parquet_buffer = df.to_parquet(index=False)
        s3.put_object(Bucket=processed_bucket, Key=output_key, Body=parquet_buffer)
        logger.info(f"Saved to: s3://{processed_bucket}/{output_key}")

        # 6. 結果を返す
        return {
            'statusCode': 200,
            'output_key': output_key,
            'record_count': len(df)
        }

    except Exception as e:
        logger.error(f"Error: {str(e)}")
        raise
