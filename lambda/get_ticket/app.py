from shared import get_ticket_id, get_tickets_table, response


table = get_tickets_table()


def handler(event, context):
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
        return response(500, {
            "message": "Internal server error",
            "error": str(error)
        })
