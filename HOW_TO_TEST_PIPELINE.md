# How to Test the CI/CD Pipeline

## Quick Test - 3 Options

### ✅ Option 1: Manual Trigger (Easiest - No Code Changes)

1. Go to GitHub: `https://github.com/SaaSInfraLab/cloudnative-saas-eks`
2. Click **Actions** tab
3. In the left sidebar, find **"Trigger Infrastructure Deployment"**
4. If you see it, click on it
5. Click **"Run workflow"** button (top right)
6. Select:
   - Branch: `testing`
   - Environment: `dev`
7. Click **"Run workflow"**

**This will trigger the workflow immediately!**

---

### ✅ Option 2: Make a Config Change

Make a small change to trigger automatically:

```bash
# Add a comment to trigger the workflow
echo "" >> examples/dev-environment/config/infrastructure.tfvars
echo "# Pipeline test - $(date)" >> examples/dev-environment/config/infrastructure.tfvars

git add examples/dev-environment/config/infrastructure.tfvars
git commit -m "Test: Trigger CI/CD pipeline"
git push origin testing
```

---

### ✅ Option 3: Check if Workflow is Visible

If you don't see the workflow in Actions tab:

1. **Verify the file exists in remote:**
   ```bash
   git log --oneline --all -- .github/workflows/trigger-infrastructure-deployment.yml
   ```

2. **If not pushed, push it:**
   ```bash
   git add .github/workflows/trigger-infrastructure-deployment.yml
   git commit -m "Add CI/CD pipeline workflow"
   git push origin testing
   ```

3. **Wait 10-30 seconds** and refresh the Actions tab

---

## Required Setup

### Add GitHub Secret (Required for GitOps Trigger)

1. Go to: `https://github.com/SaaSInfraLab/cloudnative-saas-eks/settings/secrets/actions`
2. Click **"New repository secret"**
3. Name: `GITOPS_TRIGGER_TOKEN`
4. Value: GitHub Personal Access Token (PAT)
   - Create token: https://github.com/settings/tokens
   - Scopes needed: `repo` (full control)
5. Click **"Add secret"**

**Note:** Without this secret, the workflow will run but won't trigger Gitops-pipeline (it will show a warning).

---

## What to Expect

### When Workflow Runs:

1. ✅ **Terraform Validation** (2-3 minutes)
   - Format check
   - Infrastructure validation
   - Tenants validation

2. ✅ **Trigger GitOps** (if secret is set)
   - Sends event to Gitops-pipeline
   - Gitops-pipeline starts deployment

3. ✅ **Check Gitops-pipeline**
   - Go to: `https://github.com/SaaSInfraLab/Gitops-pipeline/actions`
   - Look for **"Auto-Apply Infrastructure"** workflow

---

## Troubleshooting

### Workflow Not Showing in Actions Tab

**Cause:** Workflow file not in repository or not recognized

**Fix:**
```bash
# Verify file exists
ls -la .github/workflows/trigger-infrastructure-deployment.yml

# If missing, the file needs to be committed and pushed
git add .github/workflows/trigger-infrastructure-deployment.yml
git commit -m "Add workflow"
git push origin testing
```

### Workflow Runs But Shows Warning About Token

**Cause:** `GITOPS_TRIGGER_TOKEN` secret not configured

**Fix:** Add the secret (see "Required Setup" above)

### Workflow Fails on Terraform Validation

**Cause:** Terraform code has errors

**Fix:** Check workflow logs for specific errors and fix them

---

## Test Right Now

**Quickest way to test:**

1. Go to: https://github.com/SaaSInfraLab/cloudnative-saas-eks/actions
2. Look for **"Trigger Infrastructure Deployment"** in sidebar
3. Click **"Run workflow"** → Select `testing` branch → Run

That's it! The workflow will run and you can see the logs.

