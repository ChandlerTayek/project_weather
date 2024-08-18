# Use the official AWS Lambda Python base image
FROM public.ecr.aws/lambda/python:3.9

# Set the working directory inside the container to be /var/task
WORKDIR ${LAMBDA_TASK_ROOT}

# Install the requests module
RUN pip install requests

# Copy the app.py from the parent directory (..) into the container's working directory
COPY weather_ping.py .

# Set the command to the Lambda handler function (file.function_name)
CMD ["weather_ping.lambda_handler"]
