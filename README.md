# Project 4: Serverless Customer Support API Platform

### Business problem:
A company needs a lightweight customer support ticket API that can handle unpredictable traffic without managing servers.

### Solution:
Built a fully serverless customer support API on AWS using API Gateway, Lambda, and DynamoDB, provisioned with Terraform, designed for low operational overhead and unpredictable traffic.

### DynamoDB
Billing Mode = PAY_PER_REQUEST
For unpredictable API traffic, use DynamoDB On-Demand billing.

Consideration:
+ no capacity planning
+ scales automatically
+ good for MVP / bursty traffic
+ cost-efficient when traffic is unknown

### Lambda Function and IAM Role
**Lambda Function**

Name: serverless-support-api-dev-create-ticket

**IAM Role and Policy**

Allows Lambda to assume the role, and policy allow the role to write ticket data into DynamoDB

**DynamoDB Permission**

``dynamodb:PutItem only``

**API Gateway**

API Gateway does not automatically invoke Lambda. Lambda must be explicitly given permission to be invoked by API Gateway.

```POST /tickets```
This route creates a support ticket in DynamoDB

```GET /tickets/{ticket_id}```
This route retrieve the support ticket in DynamoDB based on the ticket_id

```PATCH /tickets/{ticket_id}```
This route update ticket in DynamoDB based on the ticket_id

```DELETE /tickets/{ticket_id}```
This route delete a ticket in DynamoDB based on the ticket_id


### Test API
#### POST
Reference to terraform output.
```
create_ticket_url = "https://qrebseqcmk.execute-api.ap-southeast-1.amazonaws.com/dev/tickets"
```
*Test with Curl (Bash)*
```Bash
curl -X POST "PASTE_THE_create_ticket_url_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "Horace",
    "customer_email": "horace@example.com",
    "issue": "Horace cannot access his account"
  }'
```
```
{
  "message": "Ticket created successfully",
  "ticket": {
    "ticket_id": "generated-uuid",
    "customer_name": "Horace",
    "customer_email": "horace@example.com",
    "issue": "Horace cannot access his account",
    "status": "OPEN",
    "created_at": "2026-05-04T..."
  }
}

*Test with Powershell command*
```powershell
$body = @{
    customer_name  = "Horace"
    customer_email = "horace@example.com"
    issue          = "Horace cannot access his account"
} | ConvertTo-Json

Invoke-RestMethod -Uri "PASTE_THE_create_ticket_url_HERE" `
                  -Method Post `
                  -ContentType "application/json" `
                  -Body $body

```
![Alt Text](/images/Test_output_using_powershell_Invoke_method.png)

*Test with postman*

![Alt Text](/images/Test_output_with_postman1.png)

![Alt Text](/images/Test_output_with_postman2.png)

*Record created in dynamoDB

![Alt Text](/images/dynamodb_output_result.png)

#### GET
*Test with bash*
```bash
curl -X GET "https://xqxe4o6klc.execute-api.ap-southeast-1.amazonaws.com/dev/tickets/PASTE_TICKET_ID"
```
```text
{
  "ticket": {
    "ticket_id": "24df0430-418d-4bcb-911a-3fc679e912a6",
    "customer_name": "Horace",
    "customer_email": "horace@example.com",
    "issue": "Cannot access my account",
    "status": "OPEN",
    "created_at": "..."
  }
}
```
*Test with Powershell*
```powershell
Invoke-RestMethod -Uri "https://xqxe4o6klc.execute-api.ap-southeast-1.amazonaws.com/dev/tickets/PASTE_TICKET_ID" -Method Get
```
![Alt Text](/images/Test_get_with_powershell.png)

*Test with Postman*

![Alt Text](/images/Test_get_with_postman.png)

#### PATCH
*Test with bash*
```bash
curl -X PATCH "https://xqxe4o6klc.execute-api.ap-southeast-1.amazonaws.com/dev/tickets/PASTE_TICKET_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "IN_PROGRESS",
    "issue": "Horace cannot login to bank account"
  }'
```
```
{
  "message": "Ticket status updated successfully",
  "ticket": {
    "ticket_id": "...",
    "customer_name": "Horace",
    "customer_email": "horace@example.com",
    "issue": "Cannot access my account",
    "status": "IN_PROGRESS",
    "created_at": "...",
    "updated_at": "..."
  }
}
```

*Test with Powershell*
```powershell
$body = @{
    customer_name = "Horace Kang"
    issue = "Horace cannot login to bank account"
    status = "IN_PROGRESS"
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://xqxe4o6klc.execute-api.ap-southeast-1.amazonaws.com/dev/tickets/PASTE_TICKET_ID" `
                  -Method Patch `
                  -ContentType "application/json" `
                  -Body $body
```

*Test with Postman*

![Alt Text](/images/Test_patch_with_postman.png)

#### DELETE
*Test with bash*
```bash
curl -X DELETE "PASTE_API_ENDPOINT/dev/tickets/PASTE_TICKET_ID"
```
```text
{
  "message": "Ticket deleted successfully",
  "ticket_id": "24df0430-418d-4bcb-911a-3fc679e912a6"
}
```

*Test with Powershell*
```powershell
Invoke-RestMethod -Uri "PASTE_API_ENDPOINT/dev/tickets/PASTE_TICKET_ID" -Method Delete
```

*Test with Postman*

![Alt Text](/images/Test_delete_with_postman.png)

### Variable outputs:
```text
project_name              = "serverless-support-api"
environment               = "dev"
aws_region                = "ap-southeast-1"
tickets_table_name        = "serverless-support-api-dev-tickets"
create_ticket_lambda_name = "serverless-support-api-dev-create-ticket"
create_ticket_lambda_policy_name = "serverless-support-api-dev-create-ticket-lambda-policy"
create_ticket_lambda_role_name   = "serverless-support-api-dev-create-ticket-lambda-role"
api_endpoint = "https://qrebseqcmk.execute-api.ap-southeast-1.amazonaws.com/dev"
create_ticket_url = "https://qrebseqcmk.execute-api.ap-southeast-1.amazonaws.com/dev/tickets"
get_ticket_lambda_name = "serverless-support-api-dev-get-ticket"
get_ticket_url_pattern = "https://xqxe4o6klc.execute-api.ap-southeast-1.amazonaws.com/dev/tickets/{ticket_id}"
update_ticket_lambda_name = "serverless-support-api-dev-update-ticket"
update_ticket_url_pattern = "https://xqxe4o6klc.execute-api.ap-southeast-1.amazonaws.com/dev/tickets/{ticket_id}"
delete_ticket_lambda_name = "serverless-support-api-dev-delete-ticket"
delete_ticket_url_pattern = "https://xqxe4o6klc.execute-api.ap-southeast-1.amazonaws.com/dev/tickets/{ticket_id}"
```









