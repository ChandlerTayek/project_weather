# Define DynamoDB Table
resource "aws_dynamodb_table" "court_availability_reservations" {
  name           = "Courts"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "court" # Partition key

  attribute {
    name = "court"
    type = "S"
  }

  tags = {
    Name = "Court Availability and Reservations"
  }
}

# Seed the DynamoDB table with initial availability and reservation data
resource "null_resource" "seed_dynamodb_table" {
  provisioner "local-exec" {
    command = <<EOT
      aws dynamodb put-item --profile matchpoint --table-name ${aws_dynamodb_table.court_availability_reservations.name} --item '{"court": {"S": "Court 1"}, "last_updated": {"S": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}, "status": {"S": "available"}, "reservation_info": {"NULL": true}}'
      aws dynamodb put-item --profile matchpoint --table-name ${aws_dynamodb_table.court_availability_reservations.name} --item '{"court": {"S": "Court 2"}, "last_updated": {"S": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}, "status": {"S": "reserved"}, "reservation_info": {"M": {"user_id": {"S": "123"}, "reservation_time": {"S": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}}}}'
      aws dynamodb put-item --profile matchpoint --table-name ${aws_dynamodb_table.court_availability_reservations.name} --item '{"court": {"S": "Court 3"}, "last_updated": {"S": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}, "status": {"S": "available"}, "reservation_info": {"NULL": true}}'
    EOT
  }

  depends_on = [aws_dynamodb_table.court_availability_reservations]
}