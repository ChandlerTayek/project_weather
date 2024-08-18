import os
import json
import boto3
from boto3.dynamodb.conditions import Attr

# Initialize DynamoDB client
dynamodb = boto3.resource("dynamodb")
table_name = os.environ['DYNAMODB_TABLE_NAME'] # Get table name from environment variable
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    try:
        # Scan the table and filter for courts that are "available"
        response = table.scan(
            FilterExpression=Attr('status').eq('available')
        )

        available_courts = [ item['court'] for item in response['Items'] ]

        return {
            'statusCode': 200,
            'body': json.dumps({
                "available_courts": available_courts
            })
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                "message": "Error fetching available courts.",
                "error": str(e)
            })
        }