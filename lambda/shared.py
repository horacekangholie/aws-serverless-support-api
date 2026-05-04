import json
import os
from datetime import datetime, timezone

import boto3


def get_tickets_table():
    dynamodb = boto3.resource("dynamodb")
    return dynamodb.Table(os.environ["TICKETS_TABLE_NAME"])


def parse_json_body(event):
    return json.loads(event.get("body", "{}"))


def utc_now_iso():
    return datetime.now(timezone.utc).isoformat()


def get_ticket_id(event):
    return event.get("pathParameters", {}).get("ticket_id")


def response(status_code, body):
    return {
        "statusCode": status_code,
        "body": json.dumps(body)
    }
