#!/bin/bash

# Update EKS Auth Script
# Adds IAM role to EKS cluster's aws-auth ConfigMap

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

CLUSTER_NAME="simple-jwt-api"
REGION="us-east-2"
ROLE_NAME="UdacityFlaskDeployCBKubectlRole"
TEMP_FILE="/tmp/aws-auth-patch.yml"

echo "======================================"
echo "Updating EKS aws-auth ConfigMap"
echo "======================================"
echo ""

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME}"

echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo "Role ARN: $ROLE_ARN"
echo "Cluster: $CLUSTER_NAME"
echo "Region: $REGION"
echo ""

# Verify cluster exists
echo "Verifying EKS cluster..."
if ! eksctl get cluster --name "$CLUSTER_NAME" --region "$REGION" 2>/dev/null | grep -q "$CLUSTER_NAME"; then
    echo "Error: Cluster '$CLUSTER_NAME' not found!"
    echo "Run ./create-eks-cluster.sh first."
    exit 1
fi
echo "Cluster found ✓"
echo ""

# Update kubeconfig
echo "Updating kubeconfig..."
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$REGION"
echo ""

# Get current configmap
echo "Fetching current aws-auth ConfigMap..."
kubectl get -n kube-system configmap/aws-auth -o yaml > "$TEMP_FILE"
echo "ConfigMap saved to $TEMP_FILE"
echo ""

# Check if role already exists in configmap
if grep -q "$ROLE_ARN" "$TEMP_FILE"; then
    echo "Role already exists in aws-auth ConfigMap!"
    echo "No changes needed."
    exit 0
fi

# Create backup
BACKUP_FILE="${TEMP_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$TEMP_FILE" "$BACKUP_FILE"
echo "Backup created: $BACKUP_FILE"
echo ""

# Instructions for manual edit
echo "======================================"
echo "MANUAL STEP REQUIRED"
echo "======================================"
echo ""
echo "The aws-auth ConfigMap needs to be updated manually to avoid formatting issues."
echo ""
echo "Please follow these steps:"
echo ""
echo "1. Open the ConfigMap in your editor:"
echo "   kubectl edit -n kube-system configmap/aws-auth"
echo ""
echo "2. In the 'mapRoles' section, add the following entry:"
echo ""
echo "    - groups:"
echo "      - system:masters"
echo "      rolearn: $ROLE_ARN"
echo "      username: build"
echo ""
echo "3. Make sure the indentation matches the existing entries"
echo ""
echo "4. Save and exit the editor"
echo ""
echo "Or, you can try the automated patch (may have formatting issues):"
echo ""
read -p "Do you want to try the automated patch? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Attempting to patch ConfigMap..."
    
    # Create a patch file
    cat > /tmp/auth-patch.yml <<EOF
data:
  mapRoles: |
    - groups:
      - system:masters
      rolearn: $ROLE_ARN
      username: build
EOF
    
    kubectl patch configmap/aws-auth -n kube-system --patch "$(cat /tmp/auth-patch.yml)" || {
        echo ""
        echo "Automatic patch failed. Please update manually using the instructions above."
        exit 1
    }
    
    echo "ConfigMap patched successfully ✓"
fi

echo ""
echo "======================================"
echo "Verification"
echo "======================================"
echo ""
echo "To verify the update, run:"
echo "  kubectl get configmap/aws-auth -n kube-system -o yaml"
echo ""
echo "Next step:"
echo "  Generate GitHub personal access token, then run ./deploy-stack.sh"
echo ""

