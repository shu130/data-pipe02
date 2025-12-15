import json
import csv
import boto3
import io
import os

def lambda_handler(event, context):
    """
    S3 rawのJSONファイルを読み込み、
    CSVに変換してS3 processedに保存する
    """
    
    # S3クライアントを作成
    s3 = boto3.client('s3')
    
    # 環境変数からバケット名を取得
    raw_bucket = os.environ['RAW_BUCKET']
    processed_bucket = os.environ['PROCESSED_BUCKET']
    
    # 処理対象のファイル名（eventから受け取るか、デフォルト値を使用）
    input_key = event.get('input_key', 'orders/sample.json')
    
    # 出力ファイル名（.json → .csv に変換）
    output_key = input_key.replace('.json', '.csv')
    
    # S3からJSONファイルを取得
    response = s3.get_object(Bucket=raw_bucket, Key=input_key)
    json_content = response['Body'].read().decode('utf-8')
    
    # JSONを1行ずつパースしてリストに格納
    records = []
    for line in json_content.strip().split('\n'):
        if line:
            record = json.loads(line)
            # timestampからorder_dateを抽出
            timestamp = record.get('timestamp', '')
            if timestamp:
                order_date = timestamp.split('T')[0]
            else:
                order_date = ''
            
            records.append({
                'order_id': record.get('order_id', ''),
                'user_id': record.get('user_id', ''),
                'item': record.get('item', ''),
                'price': record.get('price', 0),
                'order_date': order_date
            })
    
    # CSVに変換
    csv_buffer = io.StringIO()
    fieldnames = ['order_id', 'user_id', 'item', 'price', 'order_date']
    writer = csv.DictWriter(csv_buffer, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(records)
    
    # S3 processedに保存
    s3.put_object(
        Bucket=processed_bucket,
        Key=output_key,
        Body=csv_buffer.getvalue(),
        ContentType='text/csv'
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'ETL completed',
            'input': f's3://{raw_bucket}/{input_key}',
            'output': f's3://{processed_bucket}/{output_key}',
            'records_processed': len(records)
        })
    }
