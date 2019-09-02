import json
import boto3
from boto3.dynamodb.conditions import Key

def lambda_handler(event, context):
    #create dynamo db connection
    dynamo_db = boto3.resource('dynamodb')
    table = dynamo_db.Table('subscriptions')
    #get the user who sent the request
    cognito_username = event['requestContext']['authorizer']['claims']['cognito:username']
    
    #query the table for the users item/stocks
    response = table.query(
            KeyConditionExpression=Key('userId').eq(cognito_username)
        )
    item = response['Items']
    
    stocks = []
    #if the user was subscribed to stocks return the list
    if (len(item) > 0):
        stocks = item[0]['stocks']
        
    return_stocks = {
        'subscriptions': stocks
    }

    return {
        'statusCode': 200,
        'headers': {
            "Access-Control-Allow-Origin" : "*",
            'Content-Type': 'application/json' 
        },
        'body': json.dumps(return_stocks)
    }