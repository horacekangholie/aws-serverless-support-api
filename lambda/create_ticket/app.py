import uuid

from shared import get_tickets_table, parse_json_body, response, utc_now_iso


table = get_tickets_table()


def handler(event, context):
    try:
        body = parse_json_body(event)

        customer_name = body.get("customer_name")
        customer_email = body.get("customer_email")
        issue = body.get("issue")

        if not customer_name or not customer_email or not issue:
            return response(400, {
                "message": "customer_name, customer_email, and issue are required"
            })

        ticket_id = str(uuid.uuid4())

        item = {
            "ticket_id": ticket_id,
            "customer_name": customer_name,
            "customer_email": customer_email,
            "issue": issue,
            "status": "OPEN",
            "created_at": utc_now_iso()
        }

        table.put_item(Item=item)

        return response(201, {
            "message": "Ticket created successfully",
            "ticket": item
        })

    except Exception as error:
        return response(500, {
            "message": "Internal server error",
            "error": str(error)
        })
