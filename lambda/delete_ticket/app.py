from shared import get_ticket_id, get_tickets_table, response


table = get_tickets_table()


def handler(event, context):
    try:
        ticket_id = get_ticket_id(event)

        if not ticket_id:
            return response(400, {"message": "ticket_id is required"})

        table.delete_item(
            Key={"ticket_id": ticket_id},
            ConditionExpression="attribute_exists(ticket_id)"
        )

        return response(200, {
            "message": "Ticket deleted successfully",
            "ticket_id": ticket_id
        })

    except table.meta.client.exceptions.ConditionalCheckFailedException:
        return response(404, {"message": "Ticket not found"})
    except Exception as error:
        return response(500, {
            "message": "Internal server error",
            "error": str(error)
        })
