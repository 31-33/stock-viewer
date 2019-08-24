import json
import boto3
from boto3.dynamodb.conditions import Key

def lambda_handler(event, context):
    #create resource connection to the dynamo db table
    dynamo_db = boto3.resource('dynamodb')
    table = dynamo_db.Table('subscriptions')
    #get what user the request was sent from 
    cognito_username = event['requestContext']['authorizer']['claims']['cognito:username']
    #parse the stock and if to subscribe or unsubscribe
    body = event['body']
    params = json.loads(body)
    IDSN = params['IDSN']
    subscribe = params['subscribe']
    
    #search for the user's item in the db
    response = table.get_item(
            Key={
                'userId': cognito_username
            }
        )
    
    state = True
    #if they have stocks they're subscribed to
    if 'Item' in response.keys():
        stocks = response['Item']['stocks']
        valid_update = False
        #check if the request is to unsubscribe or subscribe
        if subscribe and not (IDSN in stocks):
            stocks.append(IDSN)
            valid_update = True
        elif not subscribe and (IDSN in stocks):
            stocks.remove(IDSN)
            valid_update = True
            state = False
        #if it is a valid request make the change in the db
        if valid_update:    
            table.update_item(
                    Key={
                        'userId': cognito_username
                    },
                    UpdateExpression='SET stocks = :val1',
                    ExpressionAttributeValues={
                        ':val1': stocks
                    }
                )
    #otherwise then the only operation is to subscribe to the stock of the request
    else:
        table.put_item(
                Item={
                    'userId': cognito_username,
                    'stocks': list(IDSN)
                }
            )
    #return the state of the stock now in the user db
    return_state = {
        'state': state
    }
    return {
        'statusCode': 200,
        'headers': {
            "Access-Control-Allow-Origin" : "*",
            'Content-Type': 'application/json' 
        },
        'body': json.dumps(return_state)
    }