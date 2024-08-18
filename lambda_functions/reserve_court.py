import os
import json
import boto3
from datetime import datetime
from botocore.exceptions import ClientError
from boto3.dynamodb.conditions import Key

# Initialize DynamoDB client
dynamodb = boto3.resource("dynamodb")
table_name = os.environ['DYNAMODB_TABLE_NAME'] # Get table name from environment variable
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    body = json.loads(event['body'])
    court = body.get("court")
    user_id = body.get("user_id")
    
    if not court or not user_id:
        return {
            'statusCode': 400,
            'body': json.dumps({
                "message": "Court and user ID are required."
            })
        }
    
    try:
        # Check if the court is already reserved
        response = table.query(
            KeyConditionExpression=Key('court').eq(court),
            ScanIndexForward=False,  # Get the most recent status first
            Limit=1
        )
        if response['Items'] and response['Items'][0]['status'] == 'reserved':
            return {
                'statusCode': 400,
                'body': json.dumps({
                    "message": f"Court {court} is already reserved."
                })
            }

        if not response['Items']:
            return {
                'statusCode': 400,
                'body': json.dumps({
                    "message": f"Court {court} doesn't exist."
                })
            }
        else:
            current_time = datetime.utcnow().isoformat()  # Use current UTC time for 'last_updated' and 'reservation_time'
            # Reserve the court by inserting a new item with the current time as 'last_updated'
            table.update_item(
                Key={
                    'court': court
                },
                UpdateExpression="SET #status = :s, reservation_info = :r, last_updated = :lu",
                ExpressionAttributeNames={
                    '#status': 'status'
                },
                ExpressionAttributeValues={
                    ':s': "reserved",
                    ':r': {"user_id": user_id, "reservation_time": current_time},
                    ':lu': current_time
                }
            )

        return {
            'statusCode': 200,
            'body': json.dumps({
                "message": f"{court} has been reserved."
            })
        }
    
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                "message": "Error reserving court.",
                "error": str(e)
            })
        }