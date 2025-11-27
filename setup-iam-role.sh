#!/bin/bash

# Setup IAM Role Script
# Creates an IAM role for CodeBuild to access EKS cluster

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

ROLE_NAME="UdacityFlaskDeployCBKubectlRole"
TRUST_FILE="trust.json"
POLICY_FILE="iam-role-policy.json"

echo "======================================"
echo "Creating IAM Role for CodeBuild"
echo "======================================"
echo ""
echo "Role Name: $ROLE_NAME"
echo ""

# Check if role already exists
echo "Checking if role already exists..."
if aws iam get-role --role-name "$ROLE_NAME" 2>/dev/null; then
    echo "Role '$ROLE_NAME' already exists!"
    echo ""
    read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting existing role..."
        aws iam delete-role-policy --role-name "$ROLE_NAME" --policy-name eks-describe 2>/dev/null || true
        aws iam delete-role --role-name "$ROLE_NAME"
        echo "Existing role deleted."
    else
        echo "Skipping role creation."
        exit 0
    fi
fi

# Verify trust and policy files exist
if [ ! -f "$TRUST_FILE" ]; then
    echo "Error: $TRUST_FILE not found!"
    exit 1
fi

if [ ! -f "$POLICY_FILE" ]; then
    echo "Error: $POLICY_FILE not found!"
    exit 1
fi

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo ""

# Create the role
echo "Creating IAM role..."
ROLE_ARN=$(aws iam create-role \
    --role-name "$ROLE_NAME" \
    --assume-role-policy-document file://"$TRUST_FILE" \
    --output text \
    --query 'Role.Arn')

echo "Role created: $ROLE_ARN"
echo ""

# Attach the policy
echo "Attaching policy to role..."
aws iam put-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-name eks-describe \
    --policy-document file://"$POLICY_FILE"

echo "Policy attached successfully ✓"
echo ""

# Verify role
echo "Verifying role..."
aws iam get-role --role-name "$ROLE_NAME" --query 'Role.[RoleName,Arn]' --output table
echo ""

echo "======================================"
echo "IAM Role created successfully!"
echo "======================================"
echo ""
echo "Role Name: $ROLE_NAME"
echo "Role ARN: $ROLE_ARN"
echo ""
echo "Next step:"
echo "  Run ./update-eks-auth.sh to authorize this role in EKS"
echo ""

