#!/bin/bash

# Deploy CloudFormation Stack Script
# Creates CodeBuild and CodePipeline resources

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

STACK_NAME="udacity-flask-eks-stack"
TEMPLATE_FILE="ci-cd-codepipeline.cfn.yml"
REGION="us-east-2"

echo "======================================"
echo "Deploy CloudFormation Stack"
echo "======================================"
echo ""

# Verify template file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Error: Template file '$TEMPLATE_FILE' not found!"
    exit 1
fi

# Get parameters from template defaults
EKS_CLUSTER_NAME="simple-jwt-api"
GIT_SOURCE_REPO="cd0157-Server-Deployment-and-Containerization"
GIT_BRANCH="master"
GIT_HUB_USER=$(grep -A 2 "GitHubUser:" "$TEMPLATE_FILE" | grep "Default:" | awk '{print $2}')
KUBECTL_ROLE_NAME="UdacityFlaskDeployCBKubectlRole"

# Validate GitHub username
if [ -z "$GIT_HUB_USER" ]; then
    echo "Warning: Could not extract GitHub username from template."
    GIT_HUB_USER="SebAustin"
    echo "Using default: $GIT_HUB_USER"
fi

echo "Stack Configuration:"
echo "  Stack Name: $STACK_NAME"
echo "  Region: $REGION"
echo "  EKS Cluster: $EKS_CLUSTER_NAME"
echo "  GitHub User: $GIT_HUB_USER"
echo "  GitHub Repo: $GIT_SOURCE_REPO"
echo "  GitHub Branch: $GIT_BRANCH"
echo "  IAM Role: $KUBECTL_ROLE_NAME"
echo ""

# Check if stack already exists
echo "Checking if stack already exists..."
if aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" 2>/dev/null; then
    echo "Stack '$STACK_NAME' already exists!"
    echo ""
    read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting existing stack..."
        aws cloudformation delete-stack --stack-name "$STACK_NAME" --region "$REGION"
        echo "Waiting for stack deletion..."
        aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME" --region "$REGION"
        echo "Stack deleted."
    else
        echo "Skipping stack creation."
        exit 0
    fi
fi

# Prompt for GitHub token
echo ""
echo "======================================"
echo "GitHub Personal Access Token Required"
echo "======================================"
echo ""
echo "Generate a token at: https://github.com/settings/tokens"
echo "Required permissions: Full control of private repositories"
echo ""
read -sp "Enter your GitHub Personal Access Token: " GITHUB_TOKEN
echo ""
echo ""

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GitHub token is required!"
    exit 1
fi

# Create the stack
echo "Creating CloudFormation stack..."
echo "This will take 5-10 minutes..."
echo ""

aws cloudformation create-stack \
    --stack-name "$STACK_NAME" \
    --template-body file://"$TEMPLATE_FILE" \
    --parameters \
        ParameterKey=EksClusterName,ParameterValue="$EKS_CLUSTER_NAME" \
        ParameterKey=GitSourceRepo,ParameterValue="$GIT_SOURCE_REPO" \
        ParameterKey=GitBranch,ParameterValue="$GIT_BRANCH" \
        ParameterKey=GitHubUser,ParameterValue="$GIT_HUB_USER" \
        ParameterKey=GitHubToken,ParameterValue="$GITHUB_TOKEN" \
        ParameterKey=KubectlRoleName,ParameterValue="$KUBECTL_ROLE_NAME" \
    --capabilities CAPABILITY_IAM \
    --region "$REGION"

echo "Stack creation initiated..."
echo ""
echo "Waiting for stack creation to complete..."
aws cloudformation wait stack-create-complete \
    --stack-name "$STACK_NAME" \
    --region "$REGION"

echo ""
echo "======================================"
echo "Stack created successfully!"
echo "======================================"
echo ""

# Get stack outputs
echo "Stack Resources:"
aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query 'Stacks[0].Outputs' \
    --output table

echo ""
echo "CodePipeline: https://console.aws.amazon.com/codesuite/codepipeline/pipelines"
echo "CodeBuild: https://console.aws.amazon.com/codesuite/codebuild/projects"
echo "ECR: https://console.aws.amazon.com/ecr/repositories"
echo ""
echo "Next step:"
echo "  Run ./test-endpoints.sh after the first pipeline run completes"
echo ""

