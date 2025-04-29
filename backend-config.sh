#!/bin/bash

BUCKET_NAME="#" # Change to your own bucket name
REGION="eu-central-1"

if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install AWS CLI."
    exit 1
fi

echo "🔹 Creating S3 bucket: $BUCKET_NAME in region: $REGION..."
sudo aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION" --output json

# Enabling versioning for the bucket
echo "🔹 Enabling versioning for bucket: $BUCKET_NAME..."
sudo aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled --output json

if [ $? -eq 0 ]; then
    echo "✅ Versioning has been enabled for bucket: $BUCKET_NAME"
else
    echo "❌ There was a problem enabling versioning."
    exit 1
fi

# Enabling encryption for the bucket
echo "🔹 Enabling encryption for bucket: $BUCKET_NAME..."
sudo aws s3api put-bucket-encryption --bucket "$BUCKET_NAME" --server-side-encryption-configuration '{
    "Rules": [
        {
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }
    ]
}'

# Configuring Terraform backend (Creating backend.tf file)
echo "🔹 Configuring Terraform backend..."
sudo cat > backend.tf <<EOF
terraform {
  backend "s3" {
    bucket = "$BUCKET_NAME"
    key    = "terraform.tfstate"
    region = "$REGION"
    encrypt = true
    # versioning = true
  }
}
EOF
echo "✅ Terraform backend has been configured."

# Initializing Terraform
echo "🔹 Initializing Terraform..."
sudo terraform init -reconfigure
if [ $? -eq 0 ]; then
    echo "✅ Terraform has been initialized and is ready to work."
else
    echo "❌ There was an issue initializing Terraform."
    exit 1
fi

sudo terraform plan

# If you have an error, use this line:
# sudo TF_LOG=DEBUG terraform apply -auto-approve
sudo terraform apply -auto-approve
if [ $? -eq 0 ]; then
    echo "✅ Terraform apply was successful and the infrastructure changes have been applied."
else
    echo "❌ There was an issue applying the Terraform configuration."
    exit 1
fi
