# Project 4: Serverless Customer Support API Platform

## Portfolio Snapshot
- **Goal:** Build a production-style serverless ticketing API with low ops overhead and clear observability.
- **Stack:** API Gateway (HTTP API), AWS Lambda (Python), DynamoDB (On-Demand), CloudWatch Logs, Terraform.
- **Outcome:** Implemented full ticket lifecycle APIs (`create`, `list`, `get`, `update`, `delete`) with infrastructure as code and stage access logging.

## Architecture Overview
```text
Client
  -> API Gateway (HTTP API, /dev stage)
    -> Lambda handlers (create/list/get/update/delete)
      -> DynamoDB (tickets table)
  -> CloudWatch Logs
      - Lambda execution logs
      - API Gateway access logs
```

## Why this design
- **Serverless first:** avoids server management while scaling automatically.
- **DynamoDB On-Demand:** good fit for unpredictable or portfolio-scale traffic.
- **Function-per-operation:** simple IAM boundaries and easier endpoint-level reasoning.
- **Access logging enabled:** request-level observability for troubleshooting and demo readiness.

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

```GET /tickets```
This route retrieves a paginated list of support tickets from DynamoDB

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

### API Gateway Access Logs
- Enabled access logs on the HTTP API stage (`dev`) and configured JSON log format with request metadata (request id, route, status, source IP, and integration error message).
- Logs are written to CloudWatch log group:
  `/aws/apigateway/serverless-support-api-dev-http-api-access`

## Tradeoffs and Improvements
### Current tradeoffs
- `GET /tickets` currently uses DynamoDB `Scan`, which is simple for demonstration but less efficient at large scale.
- Single `lambda/app.py` improves maintainability for this project, but larger systems may split by bounded context/package.

### Next improvements
- Add filtering/query patterns and pagination tokens with opaque encoding for list endpoint.
- Add structured application logs and CloudWatch dashboards/alarms.
- Add authentication/authorization (JWT authorizer or Cognito) for production security posture.
- Add CI checks (`terraform fmt/validate/plan`, linting, unit tests) before deployment.

## AWS Standard Architecture Diagram (Phase 7)
```mermaid
flowchart LR
    U[Client: Postman / curl / App] --> APIGW[Amazon API Gateway HTTP API]

    subgraph Lambda["AWS Lambda (Python)"]
      C[create_ticket_handler]
      L[list_tickets_handler]
      G[get_ticket_handler]
      P[update_ticket_handler]
      D[delete_ticket_handler]
    end

    APIGW -->|POST /tickets| C
    APIGW -->|GET /tickets| L
    APIGW -->|GET /tickets/{ticket_id}| G
    APIGW -->|PATCH /tickets/{ticket_id}| P
    APIGW -->|DELETE /tickets/{ticket_id}| D

    C --> DB[(Amazon DynamoDB: tickets)]
    L --> DB
    G --> DB
    P --> DB
    D --> DB

    APIGW --> APILogs[CloudWatch Log Group: API Access Logs]
    C --> FnLogs[CloudWatch Log Groups: Lambda Logs]
    L --> FnLogs
    G --> FnLogs
    P --> FnLogs
    D --> FnLogs
```

### Diagram Notes
- API Gateway is the single ingress and routes requests by method + path.
- Each endpoint maps to a dedicated Lambda handler in `lambda/app.py`.
- All handlers use a shared DynamoDB table for ticket persistence.
- Observability is split into API access logs and per-function execution logs.





