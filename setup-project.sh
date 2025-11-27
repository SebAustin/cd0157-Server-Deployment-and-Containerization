#!/bin/bash

# Setup Project Script
# Automates initial project setup including account ID updates

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "======================================"
echo "Flask App to EKS - Project Setup"
echo "======================================"
echo ""

# Get AWS Account ID
echo "Getting AWS Account ID..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "Error: Unable to get AWS Account ID. Make sure AWS CLI is configured."
    exit 1
fi
echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo ""

# Get GitHub Username
echo "Getting GitHub Username..."
GIT_USERNAME=$(git config user.name)
if [ -z "$GIT_USERNAME" ]; then
    echo "Warning: No git username configured. Please update ci-cd-codepipeline.cfn.yml manually."
else
    echo "GitHub Username: $GIT_USERNAME"
fi
echo ""

# Verify files exist
echo "Verifying required files exist..."
required_files=(
    "trust.json"
    "ci-cd-codepipeline.cfn.yml"
    "buildspec.yml"
    "test_main.py"
    "main.py"
    "requirements.txt"
    "Dockerfile"
    "simple_jwt_api.yml"
    ".env_file"
)

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Error: Required file '$file' not found!"
        exit 1
    fi
done
echo "All required files present ✓"
echo ""

# Set default AWS region
echo "Setting default AWS region to us-east-2..."
aws configure set region us-east-2
echo "Region set ✓"
echo ""

# Verify prerequisites
echo "Verifying prerequisites..."
command -v aws >/dev/null 2>&1 || { echo "Error: AWS CLI is not installed."; exit 1; }
command -v eksctl >/dev/null 2>&1 || { echo "Error: eksctl is not installed."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "Error: kubectl is not installed."; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "Error: Docker is not installed."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "Error: jq is not installed. Install with: brew install jq"; exit 1; }

echo "All prerequisites installed ✓"
echo ""

echo "======================================"
echo "Setup completed successfully!"
echo "======================================"
echo ""
echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo "GitHub Username: $GIT_USERNAME"
echo ""
echo "Configuration files have been updated."
echo ""
echo "Next steps:"
echo "1. Run ./test-endpoints.sh to test the app locally"
echo "2. Run ./create-eks-cluster.sh to create the EKS cluster"
echo "3. Run ./setup-iam-role.sh to create the IAM role"
echo "4. Run ./update-eks-auth.sh to authorize CodeBuild"
echo "5. Generate a GitHub personal access token"
echo "6. Run ./deploy-stack.sh to create the CI/CD pipeline"
echo ""

