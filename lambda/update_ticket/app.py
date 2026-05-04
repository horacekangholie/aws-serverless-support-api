import json
import os
from datetime import datetime, timezone

import boto3


dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TICKETS_TABLE_NAME"])

VALID_STATUSES = {"OPEN", "IN_PROGRESS", "RESOLVED", "CLOSED"}

# Optional but recommended: only allow these fields to be updated
ALLOWED_UPDATE_FIELDS = {
    "customer_name",
    "customer_email",
    "issue",
    "status"
}


def handler(event, context):
    try:
        ticket_id = event.get("pathParameters", {}).get("ticket_id")

        if not ticket_id:
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "ticket_id is required"})
            }

        body = json.loads(event.get("body", "{}"))

        # Never allow updating the primary key
        body.pop("ticket_id", None)

        # Only keep allowed fields
        update_data = {
            key: value
            for key, value in body.items()
            if key in ALLOWED_UPDATE_FIELDS
        }

        if not update_data:
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "No valid fields to update"})
            }

        if "status" in update_data and update_data["status"] not in VALID_STATUSES:
            return {
                "statusCode": 400,
                "body": json.dumps({
                    "message": "Invalid status",
                    "valid_statuses": list(VALID_STATUSES)
                })
            }

        update_data["updated_at"] = datetime.now(timezone.utc).isoformat()

        update_parts = []
        expression_attribute_names = {}
        expression_attribute_values = {}

        for key, value in update_data.items():
            name_placeholder = f"#{key}"
            value_placeholder = f":{key}"

            update_parts.append(f"{name_placeholder} = {value_placeholder}")
            expression_attribute_names[name_placeholder] = key
            expression_attribute_values[value_placeholder] = value

        response = table.update_item(
            Key={"ticket_id": ticket_id},
            UpdateExpression="SET " + ", ".join(update_parts),
            ConditionExpression="attribute_exists(ticket_id)",
            ExpressionAttributeNames=expression_attribute_names,
            ExpressionAttributeValues=expression_attribute_values,
            ReturnValues="ALL_NEW"
        )

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Ticket updated successfully",
                "ticket": response["Attributes"]
            })
        }

    except dynamodb.meta.client.exceptions.ConditionalCheckFailedException:
        return {
            "statusCode": 404,
            "body": json.dumps({"message": "Ticket not found"})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": "Internal server error",
                "error": str(e)
            })
        }