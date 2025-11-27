# GitHub Personal Access Token Instructions

## Why You Need This

The CI/CD pipeline needs a GitHub Personal Access Token to:
- Monitor your repository for code changes
- Automatically trigger builds when you push commits
- Clone your repository for building

## How to Generate Your Token

### Step 1: Go to GitHub Settings
1. Go to https://github.com/settings/tokens
2. Or navigate: GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)

### Step 2: Generate New Token
1. Click **"Generate new token"** → **"Generate new token (classic)"**
2. Give it a descriptive name, e.g., "Udacity EKS Pipeline"
3. Set expiration (recommend 90 days for this project)

### Step 3: Select Scopes
**Required Permissions:**
- ✅ **repo** (Full control of private repositories)
  - This gives access to:
    - repo:status
    - repo_deployment
    - public_repo
    - repo:invite
    - security_events

### Step 4: Generate and Save
1. Click **"Generate token"** at the bottom
2. **IMPORTANT**: Copy the token immediately and save it somewhere secure
3. You won't be able to see it again!

## Example Token Format
Your token will look like this:
```
ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

## Next Steps

Once you have your token:

1. **Keep it secure** - Don't commit it to git or share it publicly
2. **Use it when running the deployment script**:
   ```bash
   ./deploy-stack.sh
   ```
   The script will prompt you to enter the token securely

3. **After project review**: You can delete this token from GitHub settings

## Security Best Practices

- ✅ DO: Use the token only for this project
- ✅ DO: Delete the token after project completion
- ✅ DO: Set an expiration date
- ❌ DON'T: Commit the token to your repository
- ❌ DON'T: Share the token with anyone
- ❌ DON'T: Store it in plain text in your code

## Troubleshooting

**Token doesn't work?**
- Verify you selected the **repo** scope
- Make sure you copied the entire token
- Check if the token has expired

**Need to regenerate?**
- You can always generate a new token following the same steps
- Update it in AWS CloudFormation stack parameters if needed

