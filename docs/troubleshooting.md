# Troubleshooting Guide

This guide helps you diagnose and resolve common issues when deploying and operating the CloudNative SaaS EKS platform.

## Common Issues

### Infrastructure Deployment

#### Issue: Terraform Init Fails

**Symptoms:**
```
Error: Failed to initialize backend
Error: Failed to get existing workspaces
```

**Solutions:**
1. **Check AWS Credentials**
   ```bash
   aws sts get-caller-identity
   ```

2. **Verify S3 Backend Configuration**
   - Ensure S3 bucket exists
   - Verify bucket permissions
   - Check DynamoDB table exists (for state locking)

3. **Check Terraform Version**
   ```bash
   terraform version  # Should be >= 1.0
   ```

#### Issue: VPC Creation Fails

**Symptoms:**
```
Error: error creating VPC: InvalidParameterValue
```

**Solutions:**
1. **Check CIDR Conflicts**
   - Ensure VPC CIDR doesn't conflict with existing VPCs
   - Use a unique CIDR block (e.g., `10.1.0.0/16`)

2. **Verify Region**
   - Ensure you're deploying to a valid AWS region
   - Check region supports VPC creation

3. **Check AWS Limits**
   ```bash
   aws service-quotas get-service-quota \
     --service-code vpc \
     --quota-code L-F678F1CE
   ```

#### Issue: EKS Cluster Creation Fails

**Symptoms:**
```
Error: error creating EKS Cluster: ResourceInUseException
Error: error creating EKS Cluster: InvalidParameterException
```

**Solutions:**
1. **Check Cluster Name**
   - Cluster name must be unique in the region
   - Must match pattern: `^[0-9A-Za-z][A-Za-z0-9\-_]*$`
   - Must be between 1-100 characters

2. **Verify IAM Permissions**
   - Ensure cluster role has correct trust policy
   - Verify required IAM permissions

3. **Check Service Quotas**
   ```bash
   aws service-quotas get-service-quota \
     --service-code eks \
     --quota-code L-1194A341
   ```

4. **Wait for Cluster Deletion**
   - If previous cluster exists, wait for complete deletion
   - Check deletion status: `aws eks describe-cluster --name <name>`

#### Issue: Node Groups Not Joining Cluster

**Symptoms:**
```
Nodes show NotReady status
kubectl get nodes shows NoSchedule taint
```

**Solutions:**
1. **Check Node IAM Role**
   ```bash
   # Verify node role has correct policies
   aws iam get-role-policy \
     --role-name <node-role-name> \
     --policy-name <policy-name>
   ```

2. **Verify Security Groups**
   - Ensure node security group allows traffic from cluster
   - Check security group rules:
     ```bash
     aws ec2 describe-security-groups \
       --group-ids <sg-id>
     ```

3. **Check VPC Routing**
   - Ensure private subnets have NAT Gateway routes
   - Verify route tables are correct

4. **Check Node Group Status**
   ```bash
   aws eks describe-nodegroup \
     --cluster-name <cluster-name> \
     --nodegroup-name <nodegroup-name>
   ```

5. **View Node Logs**
   ```bash
   # SSH to node (if possible) or check CloudWatch logs
   aws logs tail /aws/eks/<cluster-name>/cluster --follow
   ```

### Tenant Provisioning

#### Issue: Namespace Creation Fails

**Symptoms:**
```
Error: namespaces "<namespace>" already exists
```

**Solutions:**
1. **Check Existing Namespaces**
   ```bash
   kubectl get namespaces
   ```

2. **Delete Existing Namespace** (if appropriate)
   ```bash
   kubectl delete namespace <namespace>
   ```

3. **Use Different Namespace Name**
   - Update tenant configuration with unique namespace name

#### Issue: Resource Quota Exceeded

**Symptoms:**
```
Error: pods "<pod-name>" is forbidden: exceeded quota
```

**Solutions:**
1. **Check Resource Usage**
   ```bash
   kubectl describe quota -n <namespace>
   kubectl top pods -n <namespace>
   ```

2. **Adjust Tenant Quotas**
   - Update quotas in `tenants.tfvars`
   - Run `terraform apply`

3. **Scale Down Existing Workloads**
   ```bash
   kubectl scale deployment <deployment> --replicas=0 -n <namespace>
   ```

#### Issue: Network Policies Block Traffic

**Symptoms:**
```
Pods cannot communicate with each other
Services are not reachable
```

**Solutions:**
1. **Check Network Policies**
   ```bash
   kubectl get networkpolicies -n <namespace>
   kubectl describe networkpolicy <policy-name> -n <namespace>
   ```

2. **Allow Required Traffic**
   - Update network policies to allow required traffic
   - Consider DNS traffic (port 53/UDP)
   - Allow service discovery traffic

3. **Temporarily Disable Network Policies**
   - For testing, disable network policies per tenant
   - Set `enable_network_policy = false` in tenant config

### Database Connectivity Issues

#### Issue: Backend Pods Cannot Connect to RDS

**Symptoms:**
```
Error: no pg_hba.conf entry for host "...", user "...", database "...", no encryption
Error: Connection terminated due to connection timeout
Readiness probe failed: HTTP probe failed with statuscode: 503
```

**Solutions:**
1. **Enable SSL in Database Connection**
   - The backend application now includes SSL support for RDS connections
   - Ensure `ssl: { rejectUnauthorized: false }` is configured in database connection
   - This is automatically handled in the latest backend code

2. **Verify RDS Security Group Rules**
   - RDS security group must allow traffic from both:
     - EKS nodes security group
     - EKS cluster security group (for pod networking)
   - Port 5432 (PostgreSQL) must be open
   ```bash
   # Check security group rules
   aws ec2 describe-security-groups --group-ids <rds-sg-id>
   ```

3. **Check Network Policies (if enabled)**
   - Network policies may block egress to RDS if not configured correctly
   - Ensure network policy allows egress on port 5432 (PostgreSQL)
   - Check if network policies are enabled:
     ```bash
     kubectl get networkpolicies -n <namespace>
     ```
   - If network policies are blocking, the multi-tenancy module now includes egress rules for:
     - Port 5432 (PostgreSQL/RDS)
     - Port 443 (HTTPS for AWS API calls)
   - Re-apply tenants Terraform to update network policies:
     ```bash
     cd tenants
     terraform apply
     ```

4. **Check Database Connection Timeout**
   - Connection timeout is set to 15 seconds in backend (`connectionTimeoutMillis: 15000`)
   - Health check wrapper timeout: 18 seconds (prevents readiness check from hanging)
   - Readiness probe timeout: 20 seconds (matches health check wrapper)
   - Initial delay: 20 seconds (allows pod startup time)
   - If timeouts persist, check network latency and RDS performance

5. **Verify Secrets**
   ```bash
   # Platform namespace (uses AWS Secrets Manager)
   kubectl get secret db-credentials -n platform
   
   # Analytics namespace (uses Terraform-created secret)
   kubectl get secret postgresql-secret -n analytics
   ```

#### Issue: Analytics Namespace Backend Fails with Authentication Error

**Symptoms:**
```
Error: password authentication failed for user "dGFza3VzZXI="
```

**Solutions:**
1. **Check Secret Encoding**
   - Ensure `postgresql-secret` in analytics namespace has correct, single-encoded values
   - Terraform automatically handles base64 encoding correctly
   - If manually created, ensure values are not double-encoded

2. **Verify Secret Values**
   ```bash
   kubectl get secret postgresql-secret -n analytics -o jsonpath='{.data.db-user}' | base64 -d
   kubectl get secret postgresql-secret -n analytics -o jsonpath='{.data.db-password}' | base64 -d
   ```

3. **Recreate Secret from Terraform**
   ```bash
   cd cloudnative-saas-eks/examples/dev-environment/tenants
   terraform apply -var-file="../tenants.tfvars"
   ```

### Connectivity Issues

#### Issue: Cannot Connect to Cluster

**Symptoms:**
```
error: unable to connect to server
error: context deadline exceeded
dial tcp: lookup <endpoint>: no such host
```

**Solutions:**
1. **Update kubeconfig**
   ```bash
   aws eks update-kubeconfig --name <cluster-name> --region <region>
   ```

2. **Verify AWS Credentials**
   ```bash
   aws sts get-caller-identity
   ```

3. **Check Cluster Endpoint Access**
   - Verify cluster has public/private endpoint access enabled
   - Check if your IP is whitelisted (if private endpoint only)

4. **Test Cluster Access**
   ```bash
   kubectl cluster-info
   kubectl get nodes
   ```

#### Issue: Stale Cluster Endpoint in Remote State (RESOLVED)

**Symptoms:**
```
Error: Get "https://<old-endpoint>/api/v1/namespaces/...": dial tcp: lookup <old-endpoint>: no such host
```

**Root Cause (Historical):**
Previously, the tenants module read the cluster endpoint from remote state, which could become stale if the cluster endpoint changed.

**Solution (Implemented):**
The tenants module now fetches the cluster endpoint directly from AWS using `data.aws_eks_cluster`, ensuring it always uses the current endpoint. This makes the module resilient to stale state data.

**If you still encounter this error:**
1. Verify the cluster exists: `aws eks describe-cluster --name <cluster-name> --region <region>`
2. Check AWS permissions: Ensure your IAM user/role has `eks:DescribeCluster` permission
3. Verify the cluster name in remote state matches the actual cluster name

#### Issue: Pods Cannot Pull Images

**Symptoms:**
```
Error: ImagePullBackOff
Error: ErrImagePull
```

**Solutions:**
1. **Check Image Pull Secrets**
   ```bash
   kubectl get secrets -n <namespace>
   ```

2. **Verify Private Registry Access**
   - Configure image pull secrets for private registries
   - Ensure node role has ECR permissions (if using ECR)

3. **Check Network Connectivity**
   - Verify NAT Gateway is working
   - Check security group rules allow HTTPS (443) for Docker Hub/ECR

4. **Test Image Pull Manually**
   ```bash
   # On a node
   docker pull <image-name>
   ```

#### Issue: Backend Pods Not Becoming Ready

**Symptoms:**
```
Readiness probe failed: HTTP probe failed with statuscode: 503
Readiness probe failed: context deadline exceeded
```

**Solutions:**
1. **Check Health Check Endpoints**
   - Liveness probe: `/health/live` (should always return 200)
   - Readiness probe: `/health/ready` (checks database connection)
   - Ensure backend code has these endpoints implemented

2. **Verify Database Connection**
   - Check database credentials in secrets
   - Verify RDS security group allows traffic from EKS
   - Test database connectivity from a pod:
     ```bash
     kubectl run -it --rm debug --image=postgres:15 --restart=Never -- \
       psql -h <rds-endpoint> -U <username> -d <database>
     ```

3. **Check Pod Logs**
   ```bash
   kubectl logs <pod-name> -n <namespace> --tail=50
   ```

4. **Review Resource Limits**
   - Ensure sufficient memory (minimum 512Mi request, 2Gi limit for platform)
   - Check Node.js heap size: `NODE_OPTIONS=--max-old-space-size=1200`
   - Verify CPU limits are not too restrictive

5. **Check Timeout Configurations**
   - Database connection timeout: 15 seconds (configured in `database.js`)
   - Health check wrapper: 18 seconds (prevents hanging)
   - Readiness probe timeout: 20 seconds (matches health check)
   - If deployments timeout, check CI/CD pipeline rollout timeout (10 minutes)

6. **CI/CD Pipeline Timeouts**
   - Backend rollout timeout: 10 minutes
   - Frontend rollout timeout: 10 minutes
   - Deploy step timeout: 20 minutes
   - If pipeline times out, check pod logs and database connectivity

### Performance Issues

#### Issue: Slow Cluster Operations

**Symptoms:**
```
kubectl commands take long time
API server slow to respond
```

**Solutions:**
1. **Check Cluster Health**
   ```bash
   aws eks describe-cluster --name <cluster-name>
   ```

2. **Monitor Control Plane Metrics**
   - Check CloudWatch Container Insights
   - Review EKS control plane logs

3. **Scale Node Groups**
   - Add more nodes if cluster is resource-constrained
   - Check node capacity: `kubectl describe nodes`

#### Issue: High CloudWatch Costs

**Symptoms:**
```
Unexpected CloudWatch charges
High log ingestion costs
```

**Solutions:**
1. **Reduce Log Retention**
   ```hcl
   log_retention_days = 7  # Instead of 30
   ```

2. **Filter Logs**
   - Configure log filters to reduce ingestion
   - Disable verbose logging in applications

3. **Use Log Groups Selectively**
   - Enable only necessary log groups
   - Disable Container Insights if not needed

### Security Issues

#### Issue: Pod Security Standards Violations

**Symptoms:**
```
Error: pods "<pod-name>" is forbidden: violates PodSecurity
```

**Solutions:**
1. **Check Pod Security Labels**
   ```bash
   kubectl get namespace <namespace> -o yaml
   ```

2. **Adjust Pod Security Policy**
   - Update namespace labels
   - Or modify pod specifications to comply

3. **Review Pod Security Standards**
   - Understand baseline, restricted policies
   - Update application manifests accordingly

## Diagnostic Commands

### Cluster Health

```bash
# Cluster status
kubectl cluster-info

# Node status
kubectl get nodes -o wide

# All resources
kubectl get all --all-namespaces

# Resource usage
kubectl top nodes
kubectl top pods --all-namespaces
```

### Network Diagnostics

```bash
# Network policies
kubectl get networkpolicies --all-namespaces

# Services
kubectl get svc --all-namespaces

# Endpoints
kubectl get endpoints --all-namespaces

# DNS
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup <service-name>
```

### Resource Quotas

```bash
# All quotas
kubectl get quota --all-namespaces

# Detailed quota
kubectl describe quota -n <namespace>

# Resource usage
kubectl top pods -n <namespace> --containers
```

### AWS Resources

```bash
# EKS cluster
aws eks describe-cluster --name <cluster-name>

# Node groups
aws eks list-nodegroups --cluster-name <cluster-name>
aws eks describe-nodegroup --cluster-name <cluster-name> --nodegroup-name <name>

# VPC
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=SaaSInfraLab"

# Security groups
aws ec2 describe-security-groups --filters "Name=tag:Project,Values=SaaSInfraLab"
```

## Getting Help

If you're still experiencing issues:

1. **Check Logs**
   - CloudWatch Logs: `/aws/eks/<cluster-name>/cluster`
   - Container logs: `kubectl logs <pod-name> -n <namespace>`

2. **Review Documentation**
   - [Architecture Guide](architecture.md)
   - [Deployment Guide](deployment-guide.md)
   - [FAQ](faq.md)

3. **Search Issues**
   - [GitHub Issues](https://github.com/SaaSInfraLab/cloudnative-saas-eks/issues)

4. **Ask for Help**
   - [GitHub Discussions](https://github.com/SaaSInfraLab/cloudnative-saas-eks/discussions)
   - Create a new issue with detailed information

## Prevention Tips

1. **Test in Development First**
   - Always test changes in development environment
   - Use separate AWS accounts for dev/staging/prod

2. **Monitor Regularly**
   - Set up CloudWatch alarms
   - Monitor resource usage
   - Review logs regularly

3. **Backup State**
   - Enable Terraform state backups
   - Export Kubernetes manifests regularly

4. **Document Changes**
   - Keep track of custom configurations
   - Document any manual changes made

