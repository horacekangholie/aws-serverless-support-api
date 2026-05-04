from shared import get_ticket_id, get_tickets_table, parse_json_body, response, utc_now_iso


table = get_tickets_table()

VALID_STATUSES = {"OPEN", "IN_PROGRESS", "RESOLVED", "CLOSED"}
ALLOWED_UPDATE_FIELDS = {"customer_name", "customer_email", "issue", "status"}


def handler(event, context):
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
            return response(400, {
                "message": "Invalid status",
                "valid_statuses": list(VALID_STATUSES)
            })

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
            ReturnValues="ALL_NEW"
        )

        return response(200, {
            "message": "Ticket updated successfully",
            "ticket": response_data["Attributes"]
        })

    except table.meta.client.exceptions.ConditionalCheckFailedException:
        return response(404, {"message": "Ticket not found"})
    except Exception as error:
        return response(500, {
            "message": "Internal server error",
            "error": str(error)
        })
