#!/bin/bash

# Test Endpoints Script
# Tests Flask API endpoints locally and on EKS

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

# Test configuration
EMAIL="test@example.com"
PASSWORD="testpassword"
JWT_SECRET="${JWT_SECRET:-myjwtsecret}"

echo "======================================"
echo "Flask API Endpoint Testing"
echo "======================================"
echo ""

# Function to test endpoints
test_endpoints() {
    local BASE_URL=$1
    local LABEL=$2
    
    echo "Testing $LABEL at $BASE_URL"
    echo "--------------------------------------"
    
    # Test health endpoint
    echo "1. Testing GET / (health check)..."
    HEALTH_RESPONSE=$(curl -s "$BASE_URL/")
    if [ "$HEALTH_RESPONSE" = '"Healthy"' ]; then
        echo "   ✓ Health check passed"
    else
        echo "   ✗ Health check failed: $HEALTH_RESPONSE"
        return 1
    fi
    
    # Test auth endpoint
    echo "2. Testing POST /auth (authentication)..."
    AUTH_RESPONSE=$(curl -s -X POST "$BASE_URL/auth" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")
    
    TOKEN=$(echo "$AUTH_RESPONSE" | jq -r '.token' 2>/dev/null)
    
    if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
        echo "   ✓ Auth endpoint passed"
        echo "   Token: ${TOKEN:0:50}..."
    else
        echo "   ✗ Auth endpoint failed: $AUTH_RESPONSE"
        return 1
    fi
    
    # Test contents endpoint
    echo "3. Testing GET /contents (decode JWT)..."
    CONTENTS_RESPONSE=$(curl -s "$BASE_URL/contents" \
        -H "Authorization: Bearer $TOKEN")
    
    DECODED_EMAIL=$(echo "$CONTENTS_RESPONSE" | jq -r '.email' 2>/dev/null)
    
    if [ "$DECODED_EMAIL" = "$EMAIL" ]; then
        echo "   ✓ Contents endpoint passed"
        echo "   Decoded: $CONTENTS_RESPONSE" | jq '.'
    else
        echo "   ✗ Contents endpoint failed: $CONTENTS_RESPONSE"
        return 1
    fi
    
    echo ""
    return 0
}

# Menu
echo "Select test mode:"
echo "1. Test local Flask app (port 8080)"
echo "2. Test local Docker container (port 80)"
echo "3. Test production EKS deployment"
echo "4. Run all tests"
echo ""
read -p "Enter choice (1-4): " -n 1 -r
echo ""
echo ""

case $REPLY in
    1)
        echo "Testing local Flask app..."
        echo ""
        if ! curl -s http://localhost:8080/ > /dev/null 2>&1; then
            echo "Error: Flask app not running on port 8080"
            echo "Start it with: python main.py"
            exit 1
        fi
        test_endpoints "http://localhost:8080" "Local Flask App"
        ;;
    2)
        echo "Testing local Docker container..."
        echo ""
        if ! curl -s http://localhost:80/ > /dev/null 2>&1; then
            echo "Error: Docker container not running on port 80"
            echo "Start it with: docker run --name myContainer --env-file=.env_file -p 80:8080 myimage"
            exit 1
        fi
        test_endpoints "http://localhost:80" "Local Docker Container"
        ;;
    3)
        echo "Testing production EKS deployment..."
        echo ""
        echo "Getting LoadBalancer external IP..."
        EXTERNAL_IP=$(kubectl get service simple-jwt-api -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
        
        if [ -z "$EXTERNAL_IP" ]; then
            echo "Error: Unable to get external IP"
            echo "Make sure the service is deployed:"
            echo "  kubectl get services simple-jwt-api"
            exit 1
        fi
        
        echo "External URL: http://$EXTERNAL_IP"
        echo ""
        
        # Wait for LoadBalancer to be ready
        echo "Waiting for LoadBalancer to be ready..."
        sleep 5
        
        test_endpoints "http://$EXTERNAL_IP" "Production EKS"
        
        echo ""
        echo "======================================"
        echo "External IP for Project Submission:"
        echo "$EXTERNAL_IP"
        echo "======================================"
        ;;
    4)
        echo "Running all tests..."
        echo ""
        
        # Test local Flask
        if curl -s http://localhost:8080/ > /dev/null 2>&1; then
            test_endpoints "http://localhost:8080" "Local Flask App" || true
            echo ""
        else
            echo "Skipping local Flask app (not running)"
            echo ""
        fi
        
        # Test Docker
        if curl -s http://localhost:80/ > /dev/null 2>&1; then
            test_endpoints "http://localhost:80" "Local Docker Container" || true
            echo ""
        else
            echo "Skipping Docker container (not running)"
            echo ""
        fi
        
        # Test EKS
        EXTERNAL_IP=$(kubectl get service simple-jwt-api -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
        if [ -n "$EXTERNAL_IP" ]; then
            sleep 5
            test_endpoints "http://$EXTERNAL_IP" "Production EKS" || true
        else
            echo "Skipping EKS deployment (not deployed)"
        fi
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "======================================"
echo "Testing completed!"
echo "======================================"
echo ""

