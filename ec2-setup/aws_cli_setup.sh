AWS_REGION="eu-central-1"
BUCKET_NAME="#" # Change to your own bucket name

AWS_ACCESS_KEY="#" # Your access key
AWS_SECRET_KEY="#" # Your secret key

sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
sudo unzip awscliv2.zip
sudo ./aws/install
sudo rm -rf awscliv2.zip aws
echo "✅ AWS CLI installed!"

sudo aws configure set aws_access_key_id "$AWS_ACCESS_KEY"
sudo aws configure set aws_secret_access_key "$AWS_SECRET_KEY"
sudo aws configure set region "$AWS_REGION"

echo "✅ AWS CLI configured!"

if sudo aws s3 ls &> /dev/null; then
    echo "✅ AWS S3 works!"
else
    echo "❌ Error, check your credentials."
    exit 1
fi

response=$(sudo aws s3 ls "s3://$BUCKET_NAME" 2>&1)

if echo "$response" | grep -q "NoSuchBucket"; then
    echo "❌ Bucket '$BUCKET_NAME' does not exist."
    exit 1
else
    echo "✅ Backend bucket: '$BUCKET_NAME' is working!"
fi
