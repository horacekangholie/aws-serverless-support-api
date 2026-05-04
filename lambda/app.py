import json
import os
import uuid
from datetime import datetime, timezone

import boto3


dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TICKETS_TABLE_NAME"])
VALID_STATUSES = {"OPEN", "IN_PROGRESS", "RESOLVED", "CLOSED"}
ALLOWED_UPDATE_FIELDS = {"customer_name", "customer_email", "issue", "status"}


def response(status_code, body):
    return {"statusCode": status_code, "body": json.dumps(body)}


def parse_json_body(event):
    return json.loads(event.get("body", "{}"))


def get_ticket_id(event):
    return event.get("pathParameters", {}).get("ticket_id")


def utc_now_iso():
    return datetime.now(timezone.utc).isoformat()


def create_ticket_handler(event, context):
    try:
        body = parse_json_body(event)
        customer_name = body.get("customer_name")
        customer_email = body.get("customer_email")
        issue = body.get("issue")

        if not customer_name or not customer_email or not issue:
            return response(400, {"message": "customer_name, customer_email, and issue are required"})

        ticket_id = str(uuid.uuid4())
        item = {
            "ticket_id": ticket_id,
            "customer_name": customer_name,
            "customer_email": customer_email,
            "issue": issue,
            "status": "OPEN",
            "created_at": utc_now_iso(),
        }
        table.put_item(Item=item)
        return response(201, {"message": "Ticket created successfully", "ticket": item})
    except Exception as error:
        return response(500, {"message": "Internal server error", "error": str(error)})


def get_ticket_handler(event, context):
    try:
        ticket_id = get_ticket_id(event)
        if not ticket_id:
            return response(400, {"message": "ticket_id is required"})

        response_data = table.get_item(Key={"ticket_id": ticket_id})
        item = response_data.get("Item")
        if not item:
            return response(404, {"message": "Ticket not found"})

        return response(200, {"ticket": item})
    except Exception as error:
        return response(500, {"message": "Internal server error", "error": str(error)})


def update_ticket_handler(event, context):
    try:
        ticket_id = get_ticket_id(event)
        if not ticket_id:
            return response(400, {"message": "ticket_id is required"})

        body = parse_json_body(event)
        body.pop("ticket_id", None)
        update_data = {key: value for key, value in body.items() if key in ALLOWED_UPDATE_FIELDS}

        if not update_data:
            return response(400, {"message": "No valid fields to update"})

        if "status" in update_data and update_data["status"] not in VALID_STATUSES:
            return response(400, {"message": "Invalid status", "valid_statuses": list(VALID_STATUSES)})

        update_data["updated_at"] = utc_now_iso()

        update_parts = []
        expression_attribute_names = {}
        expression_attribute_values = {}

        for key, value in update_data.items():
            name_placeholder = f"#{key}"
            value_placeholder = f":{key}"
            update_parts.append(f"{name_placeholder} = {value_placeholder}")
            expression_attribute_names[name_placeholder] = key
            expression_attribute_values[value_placeholder] = value

        response_data = table.update_item(
            Key={"ticket_id": ticket_id},
            UpdateExpression="SET " + ", ".join(update_parts),
            ConditionExpression="attribute_exists(ticket_id)",
            ExpressionAttributeNames=expression_attribute_names,
            ExpressionAttributeValues=expression_attribute_values,
            ReturnValues="ALL_NEW",
        )

        return response(200, {"message": "Ticket updated successfully", "ticket": response_data["Attributes"]})
    except dynamodb.meta.client.exceptions.ConditionalCheckFailedException:
        return response(404, {"message": "Ticket not found"})
    except Exception as error:
        return response(500, {"message": "Internal server error", "error": str(error)})


def delete_ticket_handler(event, context):
    try:
        ticket_id = get_ticket_id(event)
        if not ticket_id:
            return response(400, {"message": "ticket_id is required"})

        table.delete_item(Key={"ticket_id": ticket_id}, ConditionExpression="attribute_exists(ticket_id)")
        return response(200, {"message": "Ticket deleted successfully", "ticket_id": ticket_id})
    except dynamodb.meta.client.exceptions.ConditionalCheckFailedException:
        return response(404, {"message": "Ticket not found"})
    except Exception as error:
        return response(500, {"message": "Internal server error", "error": str(error)})
