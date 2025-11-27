#!/bin/bash

# Cleanup Script
# Tears down all AWS resources after project review

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

CLUSTER_NAME="simple-jwt-api"
REGION="us-east-2"
STACK_NAME="udacity-flask-eks-stack"
ROLE_NAME="UdacityFlaskDeployCBKubectlRole"

echo "======================================"
echo "AWS Resources Cleanup"
echo "======================================"
echo ""
echo "WARNING: This will delete all AWS resources created for this project!"
echo ""
echo "Resources to be deleted:"
echo "  - CloudFormation Stack: $STACK_NAME"
echo "  - EKS Cluster: $CLUSTER_NAME"
echo "  - IAM Role: $ROLE_NAME"
echo "  - Parameter Store: JWT_SECRET"
echo "  - ECR Repository (created by stack)"
echo "  - S3 Bucket (created by stack)"
echo ""
read -p "Are you sure you want to continue? (yes/NO): " -r
echo

if [ "$REPLY" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "Starting cleanup process..."
echo ""

# Delete Parameter Store secret
echo "1. Deleting JWT_SECRET from Parameter Store..."
aws ssm delete-parameter --name JWT_SECRET --region "$REGION" 2>/dev/null || echo "   Parameter not found (already deleted or not created)"
echo ""

# Delete CloudFormation stack
echo "2. Checking for CloudFormation stack..."
if aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" 2>/dev/null; then
    echo "   Deleting CloudFormation stack '$STACK_NAME'..."
    aws cloudformation delete-stack --stack-name "$STACK_NAME" --region "$REGION"
    echo "   Waiting for stack deletion (this may take 5-10 minutes)..."
    aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME" --region "$REGION" || true
    echo "   ✓ Stack deleted"
else
    echo "   Stack not found (already deleted or not created)"
fi
echo ""

# Delete EKS cluster
echo "3. Checking for EKS cluster..."
if eksctl get cluster --name "$CLUSTER_NAME" --region "$REGION" 2>/dev/null | grep -q "$CLUSTER_NAME"; then
    echo "   Deleting EKS cluster '$CLUSTER_NAME'..."
    echo "   This will take 10-15 minutes..."
    eksctl delete cluster --name "$CLUSTER_NAME" --region "$REGION"
    echo "   ✓ Cluster deleted"
else
    echo "   Cluster not found (already deleted or not created)"
fi
echo ""

# Delete IAM role
echo "4. Checking for IAM role..."
if aws iam get-role --role-name "$ROLE_NAME" 2>/dev/null; then
    echo "   Deleting IAM role '$ROLE_NAME'..."
    # Delete attached policies first
    aws iam delete-role-policy --role-name "$ROLE_NAME" --policy-name eks-describe 2>/dev/null || true
    # Delete the role
    aws iam delete-role --role-name "$ROLE_NAME"
    echo "   ✓ Role deleted"
else
    echo "   Role not found (already deleted or not created)"
fi
echo ""

# Clean up local Docker resources
echo "5. Cleaning up local Docker resources..."
if docker ps -a | grep -q myContainer; then
    echo "   Stopping and removing Docker container..."
    docker stop myContainer 2>/dev/null || true
    docker rm myContainer 2>/dev/null || true
fi
if docker images | grep -q myimage; then
    echo "   Removing Docker image..."
    docker rmi myimage 2>/dev/null || true
fi
echo "   ✓ Local Docker resources cleaned"
echo ""

echo "======================================"
echo "Cleanup completed successfully!"
echo "======================================"
echo ""
echo "All AWS resources have been deleted."
echo ""
echo "Note: The following files are preserved locally:"
echo "  - trust.json (with your account ID)"
echo "  - ci-cd-codepipeline.cfn.yml (with your GitHub username)"
echo "  - test_main.py (with test_contents test)"
echo "  - buildspec.yml (with pytest)"
echo "  - .env_file"
echo ""
echo "To reset the repository to original state, run:"
echo "  git checkout trust.json ci-cd-codepipeline.cfn.yml test_main.py buildspec.yml"
echo "  rm .env_file"
echo ""

