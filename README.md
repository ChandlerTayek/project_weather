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
8. ...
10. Destroy the infrastructure with `terraform destroy`
