import json
import boto3
import os

def lambda_handler(event, context):

    rdsData = boto3.client('rds-data')
    cluster_arn = os.environ["rds_cluster_arn"]
    secret_arn = os.environ["rds_secret_arn"]
    database = os.environ["database"]

    query = ('SELECT ISIN, securityDesc FROM stocks GROUP BY ISIN ORDER BY count(ISIN) DESC LIMIT 20')

    response = rdsData.execute_statement(
        database=database,
        resourceArn=cluster_arn,
        secretArn=secret_arn,
        sql=query
    )

    reply = {'stocklist': []}

    if ('records' in response):
        for stock in response['records']:
            stock_dict = {}
            stock_dict['stockId'] = stock[0]['stringValue']
            stock_dict['name']  = stock[1]['stringValue']
            reply['stocklist'].append(stock_dict)      

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin' : '*',
            'Content-Type': 'application/json' 
        },
        'body': json.dumps(reply)
    }