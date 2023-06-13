import json
import boto3
from boto3.dynamodb.conditions import Key
from decimal import Decimal
import uuid

ddb_client = boto3.client('dynamodb', region_name='us-east-1')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Team-Sequioa')

def put_item(event, context):
    try:
        body = json.loads(event['body'])
        PlayerName = body['PlayerName']
        Score = str(body['Score'])

        params = {
            'TableName': 'Team-Sequioa',
            'Item': {
                'Rank': '1',
                'PlayerName': PlayerName,
                'HighScore': Decimal(Score)
            }
        }

        response = table.put_item(**params)
        print('Success', response)

        return {
            'statusCode': 200,
            'body': 'Item successfully added to DynamoDB'
        }
    except Exception as e:
        print('Error', e)

        return {
            'statusCode': 500,
            'body': 'Error adding item to DynamoDB: ' + str(e)
        }

def get_top_8_items(event, context):
    try:
        params = {
            'TableName': 'Team-Sequioa',
            'ProjectionExpression': 'PlayerName, HighScore'
        }

        response = table.scan(**params)
        sorted_items = sorted(response['Items'], key=lambda x: int(x['HighScore']), reverse=True)
        top_8_items = sorted_items[:8]
        print('Success, top 8 items retrieved', top_8_items)
        return top_8_items
    except Exception as e:
        print('Error', e)
        raise e

def lambda_handler(event, context):
    if event['httpMethod'] == 'POST':
        return put_item(event, context)
    elif event['httpMethod'] == 'GET':
        return get_top_8_items(event, context)
