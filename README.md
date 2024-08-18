## Setup Steps

1. From the project root run `docker build -t my-docker-lambda -f .ops/Dockerfile .`
2. Test the Docker Image Locally `docker run -p 9000:8080 my-docker-lambda`
3. Invoke the function locally: `curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'`
4. navigate to `./.ops/terraform/environment/test`
5. run `terraform plan`
6. run `terraform apply`
7. Test the route `/hello`:
    ```bash
    curl <api_url_given_by_output>/hello
    ```
8. Test the route `/reserve`:
    ```bash
    curl -X POST <api_url_given_by_output>/reserve \
    -H "Content-Type: application/json" \
    -d '{"court": "Court 1", "user_id": "Chandler.Tayek"}'
    ```
9. Test the route `/availability`:
    ```bash
    curl <api_url_given_by_output>/availability
    ```
10. Destroy the infrastructure with `terraform destroy`



| Microservice                  | Integration | API Gateway (Single API) | App Mesh                 |
| ----------------------------- | ----------- | ------------------------ | ------------------------ |
| Court Reservation Service      | Lambda      | ✔                        |                          |
| Notification Service           | Lambda      | ✔ (if user-triggered)    |                          |
| Payment Processing Service     | Lambda      | ✔                        |                          |
| User Authentication Service    | Lambda      | ✔                        |                          |
| Court Availability Service     | ECS Fargate | ✔ (external access)      | ✔ (internal communication)|
| Analytics and Reporting Service| ECS Fargate | ✔ (external access)      | ✔ (internal communication)|
| Court Maintenance Scheduling   | ECS Fargate | ✔ (external access)      | ✔ (internal communication)|
| Admin Management Service       | ECS Fargate | ✔ (external access)      | ✔ (internal communication)|
