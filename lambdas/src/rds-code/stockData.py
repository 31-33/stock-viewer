import json
import boto3
import os
from datetime import date, timedelta

def lambda_handler(event, context):

    rdsData = boto3.client('rds-data')
    cluster_arn = os.environ["rds_cluster_arn"]
    secret_arn = os.environ["rds_secret_arn"]
    database = os.environ["database"]

    #parse the stock and if to subscribe or unsubscribe
    ISIN = event['queryStringParameters']['stockId']
    dateRange = event['queryStringParameters']['dateRange']
    
    span = None
    if (dateRange == "1d"):
        span = timedelta(days=1)
    elif (dateRange == "3d"):
        span = timedelta(days=3)
    elif (dateRange == "7d"):
        span = timedelta(days=7)
    else:
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin' : '*',
                'Content-Type': 'application/json' 
            },
            'body': json.dumps({"ERROR": "Invalid date range"})
        }

    today = date.today()
    minDate = (today - span).strftime("%Y-%m-%d")

    reply = {"datapoints": []}

    query = (
        f'SELECT DISTINCT securityDesc FROM stocks WHERE ISIN=\'{ISIN}\'')

    response = rdsData.execute_statement(
        database=database,
        resourceArn=cluster_arn,
        secretArn=secret_arn,
        sql=query
    )

    if 'records' in response:
        reply['name'] = response['records'][0][0]['stringValue']
    else:
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin' : '*',
                'Content-Type': 'application/json' 
            },
            'body': json.dumps({"ERROR": "No name with that ISIN"})
        }

    query = (
        f'SELECT s.startPrice, s.date FROM stocks s WHERE s.ISIN=\'{ISIN}\' AND s.date > \'{minDate}\' ORDER BY s.date')

    response = rdsData.execute_statement(
        database=database,
        resourceArn=cluster_arn,
        secretArn=secret_arn,
        sql=query
    )

    if ('records' in response and len(response['records']) > 0):
        for record in response['records']:
            data = {}
            data['price'] = record[0]['doubleValue']
            data['dateTime'] = record[1]['stringValue']
            reply['datapoints'].append(data)
    else:
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin' : '*',
                'Content-Type': 'application/json' 
            },
            'body': json.dumps({"ERROR": "No data points"})
        }

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin' : '*',
            'Content-Type': 'application/json' 
        },
        'body': json.dumps(reply)
    }
