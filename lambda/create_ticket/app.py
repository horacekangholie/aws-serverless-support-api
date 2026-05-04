import json
import os
import uuid
from datetime import datetime, timezone

import boto3


dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TICKETS_TABLE_NAME"])


def handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))

        customer_name = body.get("customer_name")
        customer_email = body.get("customer_email")
        issue = body.get("issue")

        if not customer_name or not customer_email or not issue:
            return {
                "statusCode": 400,
                "body": json.dumps({
                    "message": "customer_name, customer_email, and issue are required"
                })
            }

        ticket_id = str(uuid.uuid4())

        item = {
            "ticket_id": ticket_id,
            "customer_name": customer_name,
            "customer_email": customer_email,
            "issue": issue,
            "status": "OPEN",
            "created_at": datetime.now(timezone.utc).isoformat()
        }

        table.put_item(Item=item)

        return {
            "statusCode": 201,
            "body": json.dumps({
                "message": "Ticket created successfully",
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