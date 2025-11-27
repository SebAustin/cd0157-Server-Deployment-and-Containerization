#!/bin/bash

# Create EKS Cluster Script
# Creates an EKS cluster with 2 nodes in us-east-2

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

CLUSTER_NAME="simple-jwt-api"
REGION="us-east-2"
NODE_COUNT=2
INSTANCE_TYPE="t2.medium"

echo "======================================"
echo "Creating EKS Cluster"
echo "======================================"
echo ""
echo "Cluster Name: $CLUSTER_NAME"
echo "Region: $REGION"
echo "Node Count: $NODE_COUNT"
echo "Instance Type: $INSTANCE_TYPE"
echo ""
echo "This process will take 15-20 minutes..."
echo ""

# Check if cluster already exists
echo "Checking if cluster already exists..."
if eksctl get cluster --name "$CLUSTER_NAME" --region "$REGION" 2>/dev/null | grep -q "$CLUSTER_NAME"; then
    echo "Cluster '$CLUSTER_NAME' already exists!"
    echo ""
    echo "To delete it, run:"
    echo "  eksctl delete cluster $CLUSTER_NAME --region $REGION"
    exit 1
fi

# Get kubectl version
echo "Checking kubectl version..."
KUBECTL_VERSION=$(kubectl version --client -o json | jq -r '.clientVersion.gitVersion' | sed 's/v//')
echo "Local kubectl version: $KUBECTL_VERSION"
echo ""

# Create the cluster
echo "Creating EKS cluster..."
eksctl create cluster \
    --name "$CLUSTER_NAME" \
    --nodes=$NODE_COUNT \
    --version=1.30 \
    --instance-types=$INSTANCE_TYPE \
    --region=$REGION

echo ""
echo "======================================"
echo "Cluster created successfully!"
echo "======================================"
echo ""

# Verify cluster
echo "Verifying cluster..."
kubectl get nodes
echo ""

# Get cluster details
echo "Cluster details:"
eksctl get cluster --name "$CLUSTER_NAME" --region "$REGION"
echo ""

echo "======================================"
echo "Next steps:"
echo "1. Run ./setup-iam-role.sh to create IAM role for CodeBuild"
echo "2. Run ./update-eks-auth.sh to authorize CodeBuild"
echo "======================================"
echo ""

