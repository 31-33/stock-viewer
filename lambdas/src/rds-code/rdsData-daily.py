import json
import os
import boto3
from datetime import date, timedelta
import csv
from io import StringIO

def lambda_handler(event, context):
    
    rdsData = boto3.client('rds-data')
    cluster_arn = os.environ["rds_cluster_arn"]
    secret_arn = os.environ["rds_secret_arn"]
    database = os.environ["database"]
    
    bucket_name = 'deutsche-boerse-xetra-pds'
    s3 = boto3.resource('s3')
    s3_client = boto3.client('s3')
    data_bucket = s3.Bucket(bucket_name)

    target_day = (date.today() - timedelta(days=2)).strftime("%Y-%m-%d")
    directory = data_bucket.objects.filter(Prefix=target_day)

    num_writes = 0
    rows = []

    for csv in directory:
        obj = data_bucket.Object(csv.key)
        if (obj.content_length > 136):
            data = s3_client.select_object_content(
                Bucket=bucket_name,
                Key=csv.key,
                ExpressionType='SQL',
                Expression='SELECT s.ISIN, s.SecurityDesc, s.StartPrice, s.EndPrice, s.TradedVolume, s."Date", s."Time" FROM s3object s',
                InputSerialization={'CSV': {'FileHeaderInfo': 'Use'}},
                OutputSerialization={'CSV': {}}
            )

            for event in data['Payload']:
                if('Records' in event):
                    records = event['Records']['Payload'].decode('utf-8')
                    csvString = StringIO(records)
                    reader = csv.reader(csvString, delimiter=',')
                    for row in reader:
                        if (len(row) == 7):
                            param = [
                                {
                                    'name': 'ISIN',
                                    'value': {
                                        'stringValue': row[0]
                                        }
                                },
                                {
                                    'name': 'securityDesc',
                                    'value': {
                                        'stringValue': row[1]
                                        }
                                },
                                {
                                    'name':'startPrice',
                                    'value': {
                                        'doubleValue': float(row[2])
                                    }
                                },
                                {
                                    'name':'endPrice',
                                    'value': {
                                        'doubleValue': float(row[3])
                                    }
                                },
                                {
                                    'name':'volume',
                                    'value': {
                                        'longValue': int(row[4])
                                    }
                                },
                                {
                                    'name':'date',
                                    'value': {
                                        'stringValue': row[5]
                                    }
                                },
                                {
                                    'name':'time',
                                    'value': {
                                        'stringValue': row[6]+":00"
                                    }
                                }
                            ]
                            rows.append(param)

                            if (len(rows) >= 1000):
                                num_writes += 1
                                insert_query = (
                                    'INSERT INTO stocks (ISIN, securityDesc, startPrice, endPrice, volume, date, time) VALUES(:ISIN, :securityDesc, :startPrice, :endPrice, :volume, :date, :time)')
                                    
                                insert_response = rdsData.batch_execute_statement(
                                    database=database,
                                    resourceArn=cluster_arn,
                                    secretArn=secret_arn,
                                    parameterSets=rows,
                                    sql=insert_query
                                    )
                                    
                                rows = []
    if (len(rows) > 0):
        num_writes += 1
        insert_query = (
            'INSERT INTO stocks (ISIN, securityDesc, startPrice, endPrice, volume, date, time) VALUES(:ISIN, :securityDesc, :startPrice, :endPrice, :volume, :date, :time)')
            
        insert_response = rdsData.batch_execute_statement(
            database=database,
            resourceArn=cluster_arn,
            secretArn=secret_arn,
            parameterSets=rows,
            sql=insert_query
            )


    return {
        'statusCode': 200,
        'body': json.dumps('numer of writes: ' + str(num_writes))
    }   