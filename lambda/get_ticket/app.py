import json
import os

import boto3


dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TICKETS_TABLE_NAME"])


def handler(event, context):
    try:
        ticket_id = event.get("pathParameters", {}).get("ticket_id")

        if not ticket_id:
            return {
                "statusCode": 400,
                "body": json.dumps({
                    "message": "ticket_id is required"
                })
            }

        response = table.get_item(
            Key={
                "ticket_id": ticket_id
            }
        )

        item = response.get("Item")

        if not item:
            return {
                "statusCode": 404,
                "body": json.dumps({
                    "message": "Ticket not found"
                })
            }

        return {
            "statusCode": 200,
            "body": json.dumps({
                "ticket": item
            })
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": "Internal server error",
                "error": str(e)
            })
        }