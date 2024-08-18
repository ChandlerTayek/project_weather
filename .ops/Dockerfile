# Use the official AWS Lambda Python base image
FROM public.ecr.aws/lambda/python:3.9

# Set the working directory inside the container to be /var/task
WORKDIR ${LAMBDA_TASK_ROOT}

# Copy the app.py from the parent directory (..) into the container's working directory
COPY app.py .

# Set the command to the Lambda handler function (file.function_name)
CMD ["app.lambda_handler"]
