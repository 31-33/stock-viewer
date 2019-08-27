import json

def lambda_handler(event, context):
    x = {
        'stocklist': [
            {'stockId': '0', 'name': "Stock0"},
            {'stockId': '1', 'name': "Stock1"},
            {'stockId': '2', 'name': "Stock2"},
            {'stockId': '3', 'name': "Stock3"}
            ]
        }
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin' : '*',
            'Content-Type': 'application/json' 
        },
        'body': json.dumps(x)
    }