# Project Summary: Flask App CI/CD Pipeline to AWS EKS

## ✅ Completed Configuration

### Files Modified
1. **trust.json** - Updated with AWS Account ID: `837607108472`
2. **ci-cd-codepipeline.cfn.yml** - Updated with GitHub username: `SebAustin`
3. **test_main.py** - Added `test_contents()` unit test for JWT validation
4. **buildspec.yml** - Added pytest to pre_build phase, updated kubectl to v1.30.4
5. **.env_file** - Created for local Docker environment variables

### Automation Scripts Created
All scripts are executable and located in the project root:

1. **setup-project.sh** - Validates prerequisites and configuration
2. **create-eks-cluster.sh** - Creates EKS cluster (v1.30, 2 nodes)
3. **setup-iam-role.sh** - Creates IAM role for CodeBuild
4. **update-eks-auth.sh** - Updates EKS ConfigMap for CodeBuild access
5. **deploy-stack.sh** - Deploys CloudFormation stack (prompts for GitHub token)
6. **test-endpoints.sh** - Tests API endpoints (local, Docker, production)
7. **cleanup.sh** - Tears down all AWS resources

## ✅ AWS Resources Created

### Current Status
- **AWS Account ID**: 837607108472
- **Region**: us-east-2
- **IAM Role**: UdacityFlaskDeployCBKubectlRole (Created ✓)
- **Parameter Store**: JWT_SECRET stored (Created ✓)
- **EKS Cluster**: simple-jwt-api (In Progress...)

### Pending Resources
- EKS cluster completion (15-20 minutes total)
- EKS ConfigMap update (after cluster is ready)
- CloudFormation stack for CodePipeline/CodeBuild
- ECR repository (created by CloudFormation)
- S3 bucket (created by CloudFormation)

## ✅ Local Testing Completed

### Unit Tests
All tests pass:
```bash
pytest test_main.py -v
✓ test_health
✓ test_auth  
✓ test_contents (NEW)
```

### Flask App (Port 8080)
- Health endpoint: ✓
- Auth endpoint: ✓
- Contents endpoint: ✓

### Docker Container (Port 8081)
- Image built: ✓
- Container tested: ✓
- All endpoints working: ✓

## 📋 Remaining Steps

### 1. Wait for EKS Cluster
Monitor progress:
```bash
tail -f /Users/shenry/.cursor/projects/.../terminals/2.txt
```

Or check status:
```bash
eksctl get cluster --name simple-jwt-api --region us-east-2
kubectl get nodes
```

### 2. Update EKS ConfigMap
Once cluster is ready:
```bash
./update-eks-auth.sh
```

This adds the IAM role to allow CodeBuild to deploy to the cluster.

### 3. Generate GitHub Token
Follow instructions in `GITHUB_TOKEN_INSTRUCTIONS.md`:
- Go to https://github.com/settings/tokens
- Generate new token (classic)
- Select "repo" scope (full control)
- Save token securely

### 4. Deploy CloudFormation Stack
```bash
./deploy-stack.sh
```

This will:
- Prompt for your GitHub token
- Create CodePipeline and CodeBuild
- Create ECR repository
- Create S3 bucket for artifacts
- Set up automatic deployments

### 5. Initialize Git Repository
If not already done:
```bash
git init
git remote add origin https://github.com/SebAustin/cd0157-Server-Deployment-and-Containerization.git
git add .
git commit -m "Initial commit with CI/CD pipeline"
git push -u origin master
```

### 6. Monitor First Build
- Go to AWS CodePipeline console
- Watch the pipeline execute
- Check CodeBuild logs for any issues

### 7. Test Production Deployment
Once pipeline completes:
```bash
./test-endpoints.sh
# Select option 3 for production testing
```

This will:
- Get the LoadBalancer external IP
- Test all endpoints
- Display the external IP for project submission

### 8. Get External IP for Submission
```bash
kubectl get service simple-jwt-api -o wide
```

Save the EXTERNAL-IP (LoadBalancer hostname) for your project submission.

## 🧪 Testing Your Deployment

### Test Local Changes
```bash
# Make code changes
git add .
git commit -m "Update feature"
git push

# This automatically triggers:
# 1. CodePipeline detects commit
# 2. CodeBuild runs tests
# 3. Builds Docker image
# 4. Pushes to ECR
# 5. Deploys to EKS
```

### Manual Testing Script
Use the comprehensive testing script:
```bash
./test-endpoints.sh
```

Options:
1. Test local Flask app (port 8080)
2. Test local Docker container (port 80/8081)
3. Test production EKS deployment
4. Run all tests

## 📊 Project Requirements Checklist

### Rubric Requirements
- [x] Dockerfile set up correctly
- [x] Docker compiles locally
- [x] Docker image runs and endpoints respond
- [x] Environment variable JWT_SECRET is set
- [x] buildspec.yml uses JWT_SECRET from parameter store
- [x] Default values set in CloudFormation template
- [ ] External IP submitted in project notes (pending deployment)
- [ ] API runs successfully from EKS (pending deployment)
- [x] Tests added to CodeBuild (pytest in buildspec.yml)

### Testing
- [x] test_health() - Tests health endpoint
- [x] test_auth() - Tests authentication and JWT generation
- [x] test_contents() - Tests JWT decoding (NEW)

## 🔧 Troubleshooting

### EKS Cluster Issues
```bash
# Check cluster status
eksctl get cluster --name simple-jwt-api --region us-east-2

# Check nodes
kubectl get nodes

# View cluster events
kubectl get events --all-namespaces
```

### Pipeline Issues
```bash
# Check pipeline status
aws codepipeline get-pipeline-state --name <pipeline-name> --region us-east-2

# View build logs
aws codebuild batch-get-builds --ids <build-id> --region us-east-2
```

### Common Errors

**Error: Role not authorized**
- Run `./update-eks-auth.sh` again
- Verify role ARN in ConfigMap

**Error: Tests failing in CodeBuild**
- Check pytest is installed in buildspec.yml
- Verify JWT_SECRET in Parameter Store

**Error: Cannot access endpoints**
- Check LoadBalancer is created: `kubectl get svc`
- Wait for LoadBalancer to provision (5-10 minutes)

## 🧹 Cleanup After Project

After receiving your project grade:
```bash
./cleanup.sh
```

This removes:
- EKS cluster
- IAM role
- Parameter Store secret
- CloudFormation stack (and all associated resources)
- Local Docker images

**Cost Warning**: Leaving resources running will incur AWS charges!

## 📝 Files for Submission

Submit via GitHub repository URL with:
1. All modified files (trust.json, ci-cd-codepipeline.cfn.yml, test_main.py, buildspec.yml)
2. Working Dockerfile
3. External IP in submission notes

## 🎯 Expected Timeline

- ✅ Local setup: Complete
- ⏳ EKS cluster creation: ~15-20 minutes (in progress)
- ⏳ ConfigMap update: ~2 minutes
- ⏳ CloudFormation stack: ~5-10 minutes
- ⏳ First pipeline run: ~5-10 minutes
- Total remaining: ~30-40 minutes

## 📚 Additional Resources

- **AWS EKS Documentation**: https://docs.aws.amazon.com/eks/
- **eksctl Guide**: https://eksctl.io/
- **kubectl Reference**: https://kubernetes.io/docs/reference/kubectl/
- **CodePipeline Guide**: https://docs.aws.amazon.com/codepipeline/
- **GitHub Token Help**: See GITHUB_TOKEN_INSTRUCTIONS.md

## 🎓 Learning Outcomes

This project demonstrates:
- ✅ Local Flask application development
- ✅ Containerization with Docker
- ✅ Kubernetes cluster management (EKS)
- ✅ Infrastructure as Code (CloudFormation)
- ✅ CI/CD pipeline automation (CodePipeline/CodeBuild)
- ✅ AWS IAM and security
- ✅ Automated testing in CI/CD
- ✅ Production deployment and monitoring

---

**Next Action**: Wait for EKS cluster completion, then run `./update-eks-auth.sh`

