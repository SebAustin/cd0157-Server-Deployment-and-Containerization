# Quick Start Guide

## Current Status: EKS Cluster Creating... ⏳

Your EKS cluster is currently being created in the background. This takes 15-20 minutes.

## What's Been Completed ✅

### 1. Configuration Files Updated
- ✅ `trust.json` - AWS Account ID configured
- ✅ `ci-cd-codepipeline.cfn.yml` - GitHub username configured  
- ✅ `test_main.py` - New test added for /contents endpoint
- ✅ `buildspec.yml` - pytest added + kubectl version updated
- ✅ `.env_file` - Created for local Docker testing

### 2. Local Testing Complete
- ✅ Unit tests pass (3/3)
- ✅ Flask app tested locally
- ✅ Docker container built and tested

### 3. AWS Resources Created
- ✅ IAM Role: `UdacityFlaskDeployCBKubectlRole`
- ✅ Parameter Store: `JWT_SECRET` stored securely
- ⏳ EKS Cluster: `simple-jwt-api` (creating...)

### 4. Automation Scripts Ready
All executable scripts are in the project root - see below for usage.

## Next Steps (Once Cluster is Ready)

### Step 1: Check Cluster Status
```bash
# Monitor cluster creation
tail -f /Users/shenry/.cursor/projects/Users-shenry-Documents-Personal-Training-Project-Udacity-Backend-Developper-with-Python-Deploy-Your-Flask-App-to-Kubernetes-Using-EKS/terminals/2.txt

# Or check if ready
eksctl get cluster --name simple-jwt-api --region us-east-2
kubectl get nodes
```

### Step 2: Update EKS ConfigMap
```bash
cd "cd0157-Server-Deployment-and-Containerization-master"
./update-eks-auth.sh
```

### Step 3: Generate GitHub Token
1. Go to: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Name it: "Udacity EKS Pipeline"
4. Select scope: **repo** (Full control of private repositories)
5. Generate and copy the token
6. See `GITHUB_TOKEN_INSTRUCTIONS.md` for detailed steps

### Step 4: Deploy CI/CD Pipeline
```bash
./deploy-stack.sh
# When prompted, paste your GitHub token
```

### Step 5: Push to GitHub
```bash
# If not already initialized
git init
git add .
git commit -m "Initial commit with CI/CD pipeline"
git branch -M master
git remote add origin https://github.com/SebAustin/cd0157-Server-Deployment-and-Containerization.git
git push -u origin master
```

### Step 6: Monitor Deployment
- Go to AWS Console → CodePipeline
- Watch your pipeline execute
- First build takes ~5-10 minutes

### Step 7: Test Production
```bash
./test-endpoints.sh
# Select option 3 for production EKS testing
```

### Step 8: Get External IP for Submission
```bash
kubectl get service simple-jwt-api
# Copy the EXTERNAL-IP for your project submission
```

## Quick Commands

### Check EKS Cluster
```bash
eksctl get cluster --name simple-jwt-api --region us-east-2
kubectl get nodes
kubectl get pods --all-namespaces
```

### Check Services
```bash
kubectl get services simple-jwt-api
kubectl describe service simple-jwt-api
```

### View Logs
```bash
kubectl get pods
kubectl logs <pod-name>
```

### Test Endpoints
```bash
./test-endpoints.sh
```

## Automation Scripts

| Script | Purpose |
|--------|---------|
| `setup-project.sh` | Validates prerequisites |
| `create-eks-cluster.sh` | Creates EKS cluster (running) |
| `setup-iam-role.sh` | Creates IAM role (done) |
| `update-eks-auth.sh` | Updates ConfigMap (run after cluster ready) |
| `deploy-stack.sh` | Deploys CloudFormation (run after ConfigMap) |
| `test-endpoints.sh` | Tests all endpoints |
| `cleanup.sh` | Tears down everything (after project graded) |

## Troubleshooting

### Cluster Taking Long?
- Normal: 15-20 minutes
- Check CloudFormation console for progress
- Region: us-east-2

### ConfigMap Update Fails?
```bash
# Make sure cluster is ready first
kubectl get nodes

# Try manual edit
kubectl edit configmap aws-auth -n kube-system
```

### Pipeline Fails?
- Check CodeBuild logs in AWS Console
- Verify GitHub token is valid
- Ensure tests pass locally first

### Can't Access Endpoints?
```bash
# Check LoadBalancer status
kubectl get svc simple-jwt-api

# May take 5-10 minutes to provision
# Wait for EXTERNAL-IP to show
```

## Cost Warning ⚠️

Remember to run `./cleanup.sh` after receiving your project grade to avoid AWS charges!

## Files Modified

You'll commit these files:
- `trust.json`
- `ci-cd-codepipeline.cfn.yml`
- `test_main.py`
- `buildspec.yml`
- `Dockerfile` (if modified)
- `.env_file` (local only - in .gitignore)

## Project Structure

```
cd0157-Server-Deployment-and-Containerization-master/
├── main.py                          # Flask application
├── test_main.py                     # Unit tests (updated)
├── requirements.txt                 # Python dependencies
├── Dockerfile                       # Docker configuration
├── buildspec.yml                    # CodeBuild instructions (updated)
├── simple_jwt_api.yml              # Kubernetes deployment
├── trust.json                       # IAM trust policy (updated)
├── iam-role-policy.json            # IAM permissions
├── ci-cd-codepipeline.cfn.yml     # CloudFormation template (updated)
├── aws-auth-patch.yml              # Sample ConfigMap
├── .env_file                        # Local environment (new)
├── QUICK_START.md                   # This file
├── PROJECT_SUMMARY.md               # Detailed summary
├── GITHUB_TOKEN_INSTRUCTIONS.md     # Token guide
└── Scripts:
    ├── setup-project.sh
    ├── create-eks-cluster.sh
    ├── setup-iam-role.sh
    ├── update-eks-auth.sh
    ├── deploy-stack.sh
    ├── test-endpoints.sh
    └── cleanup.sh
```

## Estimated Time to Complete

- ⏳ EKS cluster: ~15-20 minutes (in progress)
- 2 minutes: Update ConfigMap
- 5 minutes: Generate GitHub token
- 10 minutes: Deploy CloudFormation stack
- 10 minutes: First pipeline run
- 5 minutes: Test and verify

**Total remaining: ~30-40 minutes**

## Support

- **AWS Documentation**: https://docs.aws.amazon.com/eks/
- **eksctl Guide**: https://eksctl.io/
- **Troubleshooting**: See PROJECT_SUMMARY.md

---

**Current Action**: Waiting for EKS cluster creation to complete...

Check status with:
```bash
tail -f /Users/shenry/.cursor/projects/Users-shenry-Documents-Personal-Training-Project-Udacity-Backend-Developper-with-Python-Deploy-Your-Flask-App-to-Kubernetes-Using-EKS/terminals/2.txt
```

