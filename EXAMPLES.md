# CoGuard Skill Usage Examples

This document provides detailed examples of using the CoGuard skill in various
scenarios.

## Table of Contents

1. [Basic Project Scanning](#basic-project-scanning)
2. [Docker Image Analysis](#docker-image-analysis)
3. [Infrastructure as Code Review](#infrastructure-as-code-review)
4. [Cloud Configuration Audit](#cloud-configuration-audit)
5. [Fix and Verify Workflow](#fix-and-verify-workflow)
6. [Educational Use Cases](#educational-use-cases)
7. [Team Collaboration](#team-collaboration)

## Basic Project Scanning

### Example 1: First-time scan of a web application

**Scenario**: You have a Node.js application with Docker deployment and want to
check for security issues.

```
You: /misconfiguration-detection

Agent: I'll scan your project for security issues...

[Runs: coguard --output-format json folder .]

## CoGuard Security Scan Results

**Note**: You're using the free version. Some findings below show full details,
while others may only display titles. Upgrade for complete information on all
findings.

### Summary
- 1 critical issue found
- 2 high-priority issues found
- 9 medium/low issues found

### Critical Issues (Severity 5) — Fix Immediately

1. **Docker Container Running as Root**in `Dockerfile:8`
   - **Problem**: Container runs with root privileges (no USER directive)
   - **Security Impact**: If compromised, attacker has root access to container
     and potentially the host system
   - **Fix**: Add a non-root user before CMD instruction:

     ```dockerfile
     RUN adduser -D -u 1000 appuser
     USER appuser
     ```

### High Priority Issues (Severity 4)

2. **Missing Security Headers**in `nginx/nginx.conf:1`
   - **Problem**: No X-Frame-Options, X-Content-Type-Options, or CSP headers
   - **Impact**: Vulnerable to clickjacking and XSS attacks
   - **Fix**: Add security headers block

3. **Weak SSL Configuration**in `nginx/ssl.conf:5`
   - **Problem**: TLSv1.0 and TLSv1.1 enabled
   - **Impact**: Vulnerable to known TLS vulnerabilities (BEAST, POODLE)
   - **Fix**: Use only TLSv1.2 and TLSv1.3

### Moderate Issues (Severity 3)

4. **NGINX Version Disclosure**in `nginx/nginx.conf:12`
   - **Problem**: Server version exposed in HTTP headers and error pages
   - **Impact**: Provides information that could aid reconnaissance
   - **Fix**: Add to http block:

     ```nginx
     server_tokens off;
     ```

Would you like me to fix these issues?
```

### Example 2: Quick security check before deployment

```
You: I'm about to deploy to production. Can you do a quick security scan?

Agent: Absolutely, let me run a comprehensive security scan before your
deployment...

[Runs scan and analyzes]

Good news! Only minor issues found:
- 0 critical issues ✓
- 0 high-priority issues ✓
- 3 medium-priority best practice recommendations

The medium-priority items are:

1. Consider adding rate limiting to API endpoints
2. Database backup retention could be extended
3. Log retention period is shorter than recommended

Your project is safe to deploy. Would you like me to create a summary report of
these findings?
```

## Docker Image Analysis

### Example 3: Scanning a third-party Docker image

```
You: /misconfiguration-detection scan the postgres:14 image I'm planning to use

Agent: I'll scan the postgres:14 Docker image for security issues...

[Runs: coguard --output-format json docker-image postgres:14]

## PostgreSQL 14 Docker Image Security Analysis

### Summary

- 0 critical issues (this is the official image - well maintained!)
- 2 high-priority configuration recommendations
- 5 medium-priority best practices

### High Priority Recommendations (Severity 4)

1. **Default PostgreSQL Configuration**in
   `/var/lib/postgresql/data/postgresql.conf`
   - **Issue**: Image uses default configuration optimized for compatibility, not
     security
   - **Impact**: Not optimal for production use
   - **Recommendation**: Override with custom postgresql.conf that includes:
     - `ssl = on` (requires SSL certificates)
     - `password_encryption = scram-sha-256`
     - `log_connections = on`
     - `log_disconnections = on`

2. **Superuser Access**
   - **Issue**: POSTGRES_USER creates superuser by default
   - **Impact**: Application doesn't need superuser privileges
   - **Recommendation**: Create separate application user with limited
     privileges

### How to Use This Image Securely

Create a docker-compose.yml with proper configuration:

```yaml
version: '3.8'
services:
  postgres:
    image: postgres:14
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=myapp
    volumes:
      - ./postgresql.conf:/etc/postgresql/postgresql.conf
      - postgres-data:/var/lib/postgresql/data
    command: postgres -c config_file=/etc/postgresql/postgresql.conf
```

Would you like me to generate a secure postgresql.conf file for you?
```

### Example 3b: Creating Custom Docker Images for Configuration

```
You: The postgres image doesn't support all the security configs I need via
environment variables

Agent: Good observation! When a Docker image doesn't support environment variables
for all settings, the best approach is to create a custom image derived from the
official one. Let me show you how...

### Creating a Custom PostgreSQL Image with Security Hardening

First, I'll create a secure postgresql.conf:

[Creates config/postgresql.conf]

```conf
# Connection Settings
listen_addresses = '*'
max_connections = 100

# Security Settings
ssl = on
ssl_cert_file = '/var/lib/postgresql/certs/server.crt'
ssl_key_file = '/var/lib/postgresql/certs/server.key'
password_encryption = scram-sha-256

# Logging for Security Auditing
logging_collector = on
log_connections = on
log_disconnections = on
log_duration = on
log_line_prefix = '%m [%p] %u@%d '
log_statement = 'ddl'

# Performance with Security
shared_buffers = 256MB
effective_cache_size = 1GB
```

Now, create a custom Dockerfile:

[Creates Dockerfile.postgres]

```dockerfile
FROM postgres:14

# Copy custom configuration
COPY config/postgresql.conf /etc/postgresql/postgresql.conf

# Copy SSL certificates (you'll need to generate these)
COPY certs/server.crt /var/lib/postgresql/certs/
COPY certs/server.key /var/lib/postgresql/certs/

# Set proper permissions on SSL key
RUN chown postgres:postgres /var/lib/postgresql/certs/server.key && \
    chmod 600 /var/lib/postgresql/certs/server.key

# Use custom config file
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
```

Build and use your custom image:

```bash
docker build -f Dockerfile.postgres -t myapp/postgres-secure:14 .
docker run -d \
  -e POSTGRES_PASSWORD=${DB_PASSWORD} \
  -e POSTGRES_DB=myapp \
  -v postgres-data:/var/lib/postgresql/data \
  myapp/postgres-secure:14
```

### Benefits of Custom Images

1. **Full Control**: Configure any setting, not just those exposed via env vars
2. **Repeatability**: Configuration is version-controlled and consistent
3. **Security**: Bake in security configs that can't be accidentally disabled
4. **Compliance**: Meet specific compliance requirements for your organization

This pattern works for any Docker image - NGINX, Redis, MongoDB, etc.
```

### Example 3c: Recursive Scanning of Kubernetes Manifests

```
You: /misconfiguration-detection scan my Kubernetes deployment

Agent: I'll scan your Kubernetes configurations. Note that CoGuard performs
recursive scans, which means it will also analyze any Docker images referenced in
your manifests...

[Runs: coguard --output-format json folder .]

## Kubernetes Deployment Security Scan

### Summary

Scanned resources:

- 3 Kubernetes deployment manifests
- 2 ConfigMaps
- 1 Service definition
- **4 referenced Docker images** (scanned recursively)

Findings:

- 2 critical issues
- 6 high-priority issues
- 12 medium/low issues

### Critical Issues

1. **Insecure Redis Configuration** in referenced image `redis:6`
   - **Source**: `k8s/cache-deployment.yaml:18` references `redis:6`
   - **Problem**: Default Redis configuration has no password authentication
   - **Impact**: Anyone with cluster access can read/write cache data
   - **Solution**: Create custom Redis image with authentication

2. **Privileged Container** in `k8s/app-deployment.yaml:34`
   - **Problem**: Container runs with `privileged: true`
   - **Impact**: Full access to host system
   - **Fix**: Remove privileged flag and use specific capabilities

### High Priority Issues (Referenced Images)

3. **NGINX Default Configuration** in image `nginx:1.24` (referenced in
   `k8s/web-deployment.yaml:15`)
4. **PostgreSQL Weak Auth** in image `postgres:14` (referenced in
   `k8s/db-statefulset.yaml:22`)
5. **Node.js Running as Root** in image `node:18` (referenced in
   `k8s/api-deployment.yaml:19`)

### Recommended Approach: Custom Images

For the referenced third-party images with security issues, I recommend creating
custom derived images. Let me show you how to fix the Redis issue:

**Step 1**: Create a secure Redis configuration

[Creates redis/redis.conf]

```conf
# Security
requirepass ${REDIS_PASSWORD}
protected-mode yes
bind 0.0.0.0

# Disable dangerous commands
rename-command FLUSHDB ""
rename-command FLUSHALL ""
rename-command CONFIG ""
```

**Step 2**: Create custom Dockerfile

[Creates redis/Dockerfile]

```dockerfile
FROM redis:6

COPY redis.conf /usr/local/etc/redis/redis.conf

CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]
```

**Step 3**: Update Kubernetes manifest

[Updates k8s/cache-deployment.yaml]

```yaml
spec:
  containers:
  - name: redis
    image: myapp/redis-secure:6  # Use custom image
    env:
    - name: REDIS_PASSWORD
      valueFrom:
        secretKeyRef:
          name: redis-secret
          key: password
```

**Step 4**: Build and push custom image

```bash
docker build -t myapp/redis-secure:6 redis/
docker push myapp/redis-secure:6
```

This approach ensures:

- Security configs can't be accidentally disabled
- Configuration is version-controlled
- Changes are tested before deployment
- Compliance requirements are met

Would you like me to create custom images for the other referenced containers as
well?
```

## Infrastructure as Code Review

### Example 4: Terraform security audit

```
You: /misconfiguration-detection review my Terraform configs for AWS

Agent: I'll analyze your Terraform configurations for AWS security best
practices...

[Runs scan focused on .tf files]

## Terraform AWS Configuration Security Review

### Summary

- 2 critical issues found
- 4 high-priority issues found
- 11 medium/low issues found

### Critical Issues

1. **S3 Bucket Publicly Accessible** in `infrastructure/s3.tf:15`
   - **Problem**: S3 bucket has public read access enabled
     ```hcl
     resource "aws_s3_bucket" "app_data" {
       acl = "public-read"  # ⚠️ CRITICAL
     }
     ```
   - **Impact**: All bucket contents visible to the internet; potential data
     breach
   - **Fix**: Change to private and use presigned URLs or CloudFront:
     ```hcl
     resource "aws_s3_bucket" "app_data" {
       acl = "private"
     }

     resource "aws_s3_bucket_public_access_block" "app_data" {
       bucket = aws_s3_bucket.app_data.id
       block_public_acls       = true
       block_public_policy     = true
       ignore_public_acls      = true
       restrict_public_buckets = true
     }
     ```

2. **Security Group Allows 0.0.0.0/0 on SSH** in
   `infrastructure/security_groups.tf:23`
   - **Problem**: SSH port 22 open to entire internet
   - **Impact**: Exposed to brute force attacks and automated exploit attempts
   - **Fix**: Restrict to specific IP ranges or use AWS Systems Manager Session
     Manager

### High Priority Issues

3. **RDS Instance Not Encrypted** in `infrastructure/rds.tf:8`
4. **CloudWatch Logs Not Encrypted** in `infrastructure/cloudwatch.tf:12`
5. **EC2 Instance Has Public IP** in `infrastructure/ec2.tf:34`
6. **No MFA Delete on S3 Bucket** in `infrastructure/s3.tf:15`

Should I go through each of these and explain the fixes in detail?
```

## Cloud Configuration Audit

### Example 5: AWS infrastructure review

```
You: /misconfiguration-detection scan my AWS infrastructure

Agent: I'll extract and scan your current AWS configuration. This may take 2-3
minutes...

[Runs: coguard --output-format json cloud aws]

## AWS Infrastructure Security Audit

### Summary

Scanned 47 AWS resources across 5 services:

- ✓ IAM (12 users, 5 roles)
- ✓ EC2 (8 instances, 3 security groups)
- ✓ S3 (6 buckets)
- ✓ RDS (2 instances)
- ✓ Lambda (15 functions)

Findings:

- 3 critical issues
- 7 high-priority issues
- 15 medium-priority issues
- 8 low-priority issues

### Critical Issues

1. **IAM User with Hardcoded Access Keys**
   - **User**: deploy-user
   - **Problem**: Long-term access keys created 487 days ago, never rotated
   - **Impact**: If keys leaked, attacker has persistent access
   - **Fix**: Rotate keys immediately, consider using IAM roles instead

2. **RDS Instance Publicly Accessible**
   - **Instance**: production-db
   - **Problem**: `publicly_accessible = true`
   - **Impact**: Database exposed to internet
   - **Fix**: Set to false and access via bastion host or VPN

3. **S3 Bucket Versioning Disabled**
   - **Bucket**: critical-backups
   - **Problem**: No protection against accidental deletion
   - **Impact**: Permanent data loss risk
   - **Fix**: Enable versioning and lifecycle policies

### Positive Findings ✓

- All EC2 instances use IMDSv2 (good!)
- CloudTrail enabled in all regions
- VPC flow logs active
- MFA enabled for root account

This is a comprehensive report. Would you like me to:

1. Fix critical issues immediately?
2. Generate a detailed remediation plan?
3. Create Terraform to align infrastructure with best practices?
```

## Fix and Verify Workflow

### Example 6: Automated remediation

```
You: /misconfiguration-detection scan and fix all critical issues

Agent: I'll scan your project and fix critical security issues...

[Runs scan]

Found 2 critical issues. Let me fix them:

### Fixing Issue 1: Docker Root User

In Dockerfile:8, adding non-root user...

[Uses Edit tool]

```dockerfile
# Install dependencies
RUN npm ci --production

# Create non-root user
RUN adduser -D -u 1000 appuser && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Start application
CMD ["node", "server.js"]
```

✓ Fixed - Container now runs as appuser (uid 1000)

### Fixing Issue 2: Missing Security Headers

In nginx/nginx.conf, adding security headers...

[Uses Edit tool]

```nginx
http {
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Content-Security-Policy "default-src 'self'" always;

    # Existing configuration...
    include mime.types;
    default_type application/octet-stream;
    ...
}
```

✓ Fixed - Security headers now properly configured

### Verifying Fixes

Re-running CoGuard scan to confirm...

[Runs: coguard --output-format json folder .]

✓ Scan complete!

- Critical issues: 0 (was 1)
- High priority: 0 (was 2)
- Medium/Low: 9 (unchanged)

Both critical and high-priority issues have been successfully resolved! Your
container security is now significantly improved.

Would you like me to address the high-priority issues as well?
```

### Example 6b: Enterprise Auto-Fix Feature

```
You: /misconfiguration-detection scan and fix all issues automatically

Agent: I'll check if you have access to the enterprise fix feature...

[Runs: coguard --output-format json folder . --fix=true]

## Auto-Fix Results

CoGuard's enterprise fix feature has automatically remediated issues in your
configuration files:

### Files Modified:

1. **Dockerfile** (2 changes)
   - Added non-root user
   - Set USER directive

2. **nginx/nginx.conf** (3 changes)
   - Added security headers
   - Disabled server_tokens
   - [REQUIRES INPUT] SSL certificate path

3. **postgresql.conf** (1 change)
   - [REQUIRES INPUT] Database password encryption method

### User Input Required

I notice the fix feature has marked some items that need your input. Let me fill
those in:

**nginx/nginx.conf:45** - SSL certificate path

The fix added:

```nginx
ssl_certificate [USER_INPUT_REQUIRED];
ssl_certificate_key [USER_INPUT_REQUIRED];
```

I'll set this to standard paths:

[Uses Edit tool]

```nginx
ssl_certificate /etc/nginx/ssl/server.crt;
ssl_certificate_key /etc/nginx/ssl/server.key;
```

**postgresql.conf:78** - Password encryption

The fix added:

```conf
password_encryption = [USER_INPUT_REQUIRED: scram-sha-256 or md5]
```

I recommend scram-sha-256 for better security:

[Uses Edit tool]

```conf
password_encryption = scram-sha-256
```

### Verification

Running final scan to confirm all issues resolved...

[Runs: coguard --output-format json folder .]

✓ All issues resolved! Your configuration is now secure.

- 0 critical issues
- 0 high priority issues
- 2 informational notices

The auto-fix feature saved significant manual work. All security issues have been
addressed.
```

## Educational Use Cases

### Example 7: Learning about security best practices

```
You: /misconfiguration-detection I want to learn about securing my PostgreSQL database. Can you scan
it and explain?

Agent: Great question! Let me scan your PostgreSQL configuration and walk you
through security best practices...

[Runs scan]

## PostgreSQL Security Configuration Review

I found your PostgreSQL config at `config/postgresql.conf`. Let me explain each
security aspect:

### 1. Authentication Methods

**Current setting** (pg_hba.conf:15):
```
host  all  all  0.0.0.0/0  md5
```

**Why this matters**: This allows password authentication from any IP address.
While convenient, it has two problems:

- Anyone can attempt to connect (brute force risk)
- MD5 is cryptographically weak

**Better approach**:

```
hostssl  all  all  10.0.0.0/8  scram-sha-256
```

This means:

- `hostssl`: Require SSL/TLS encryption
- `10.0.0.0/8`: Only allow from private network
- `scram-sha-256`: Modern password hashing

### 2. SSL/TLS Configuration

**Current**: SSL disabled

**Why this matters**: Without SSL, all data including passwords travels in plain
text across the network. Anyone with network access can intercept it.

**How to enable**:

```
ssl = on
ssl_cert_file = '/path/to/server.crt'
ssl_key_file = '/path/to/server.key'
```

### 3. Logging and Auditing

**Current**: Minimal logging

**Why this matters**: If a breach occurs, you need logs to:

- Detect the intrusion
- Understand what was accessed
- Meet compliance requirements

**Recommended settings**:

```
logging_collector = on
log_connections = on
log_disconnections = on
log_duration = on
log_statement = 'ddl'  # Log all schema changes
```

Want me to generate a secure postgresql.conf with all these settings?
```

## Team Collaboration

### Example 8: Security report for team review

```
You: /misconfiguration-detection create a security report I can share with my team

Agent: I'll generate a comprehensive security report suitable for team review...

[Runs scan and formats results]

# Infrastructure Security Report
**Generated**: 2024-02-23
**Project**: MyApp Platform
**Scanned by**: CoGuard CLI via coding agent

## Executive Summary

Security scan identified 23 findings across Docker configurations, infrastructure
code, and application settings. Immediate attention required for 2 critical items
that pose significant security risks.

## Risk Overview

| Severity | Count | Status |
|----------|-------|--------|
| Critical | 2     | 🔴 Action Required |
| High     | 5     | 🟡 Attention Needed |
| Medium   | 11    | 🟢 Best Practices |
| Low      | 5     | 📋 Informational |

## Critical Findings Requiring Immediate Action

### 1. Public Database Exposure
- **Location**: `docker-compose.yml:34`
- **Risk**: Database port 5432 exposed to 0.0.0.0
- **Impact**: Production data accessible from internet
- **Effort**: 5 minutes
- **Owner**: DevOps team
- **Recommendation**: Remove port mapping; access via application layer only

### 2. Container Root Privileges
- **Location**: `Dockerfile:18`
- **Risk**: Application runs as root user
- **Impact**: Container compromise = host system compromise
- **Effort**: 10 minutes
- **Owner**: Backend team
- **Recommendation**: Create and use non-privileged user

## High Priority Findings

[Detailed breakdown of each...]

## Remediation Timeline

**Week 1 (Critical)**:
- [ ] Remove database port exposure
- [ ] Implement non-root container user

**Week 2 (High Priority)**:
- [ ] Add security headers to NGINX
- [ ] Enable SSL/TLS for all services
- [ ] Implement secrets management
- [ ] Configure proper CORS policies
- [ ] Enable audit logging

**Week 3-4 (Medium Priority)**:
- [ ] Implement rate limiting
- [ ] Add container resource limits
- [ ] Configure backup encryption
- [... 8 more items ...]

## Resources and References

- [OWASP Docker Security Cheat Sheet](...)
- [CIS Kubernetes Benchmark](...)
- [AWS Security Best Practices](...)

---
Report saved to: `security-report-2024-02-23.md`

I've created a detailed report. Would you like me to also:

1. Create GitHub issues for each finding?
2. Generate a presentation version?
3. Set up a tracking board for remediation progress?
```

## Advanced Workflows

### Example 9: Continuous security integration

```
You: /misconfiguration-detection set up continuous security scanning in CI/CD

Agent: I'll help you integrate CoGuard into your CI/CD pipeline...

First, let me scan your current setup and then generate the pipeline
configuration...

[Analyzes project]

I see you're using GitHub Actions. I'll create a workflow that:

- Scans on every pull request
- Fails if critical issues found
- Posts findings as PR comments
- Tracks trends over time

[Creates .github/workflows/coguard-scan.yml]

```yaml
name: CoGuard Security Scan

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install CoGuard
        run: pip3 install coguard-cli

      - name: Run Security Scan
        env:
          COGUARD_API_KEY: ${{ secrets.COGUARD_API_KEY }}
        run: |
          coguard --output-format json folder . > scan-results.json

      - name: Check for Critical Issues
        run: |
          CRITICAL=$(jq '.findings[] | select(.severity=="critical") | \
            length' scan-results.json)
          if [ "$CRITICAL" -gt 0 ]; then
            echo "❌ Critical security issues found!"
            exit 1
          fi

      - name: Post Results to PR
        uses: actions/github-script@v6
        with:
          script: |
            const results = require('./scan-results.json');
            // Format and post comment...
```

✓ Created GitHub Actions workflow
✓ Configured to fail on critical issues
✓ Set up PR commenting

Next steps:

1. Add `COGUARD_API_KEY` to GitHub Secrets
2. Merge this workflow to your main branch
3. Watch it run on the next PR!

Would you like me to create similar configs for other CI systems?
```

### Example 10: JFrog Evidence Integration

```
You: We use JFrog Artifactory. Can we integrate CoGuard scan results?

Agent: Yes! CoGuard integrates with JFrog Evidence to attach security scan
results as evidence to your artifacts. This requires CoGuard Enterprise and JFrog
Cloud Enterprise+ subscriptions.

Let me create a complete GitHub Actions workflow that builds a Docker image,
pushes it to JFrog, scans it with CoGuard, and uploads the evidence...

[Creates .github/workflows/jfrog-coguard.yml]

```yaml
name: Build, Scan, and Upload Evidence to JFrog

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  JFROG_URL: https://yourorg.jfrog.io
  IMAGE_NAME: myapp
  IMAGE_TAG: ${{ github.sha }}

permissions:
  contents: read
  pull-requests: read

jobs:
  build-scan-upload:
    timeout-minutes: 15
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          submodules: true

      - name: Set up JFrog CLI
        uses: jfrog/setup-jfrog-cli@v4
        env:
          JF_URL: ${{ env.JFROG_URL }}
          JF_ACCESS_TOKEN: ${{ secrets.JF_ACCESS_TOKEN }}

      - name: Build and push Docker image to JFrog
        run: |
          docker build -t ${{ env.IMAGE_NAME }}:${{ env.IMAGE_TAG }} .
          jf docker push yourorg.jfrog.io/docker-repo/\
            ${{ env.IMAGE_NAME }}:${{ env.IMAGE_TAG }}

      - name: Run CoGuard scan
        uses: coguardio/coguard-scan-action@latest
        with:
          username: ${{ secrets.COGUARD_USERNAME }}
          password: ${{ secrets.COGUARD_PASSWORD }}
          outputFormat: json,markdown
          repositoryScan: false
          dockerImageName: ${{ env.IMAGE_NAME }}:${{ env.IMAGE_TAG }}

      - name: Upload evidence to JFrog
        if: always()
        run: |
          jf evd create \
            --package-name ${{ env.IMAGE_NAME }} \
            --package-version ${{ env.IMAGE_TAG }} \
            --package-repo-name docker-repo \
            --markdown result.md \
            --key "${{ secrets.JF_PRIVATE_KEY }}" \
            --key-alias ${{ secrets.JF_KEY_ALIAS }} \
            --predicate result.json \
            --predicate-type https://www.coguard.io/schema-v1
```

✓ Created JFrog Evidence integration workflow

**Setup Requirements**:

1. Add secrets to GitHub:
   - `COGUARD_USERNAME` and `COGUARD_PASSWORD`
   - `JF_ACCESS_TOKEN` (JFrog access token)
   - `JF_PRIVATE_KEY` (for signing evidence)
   - `JF_KEY_ALIAS` (key alias for evidence)
2. Set up key pair for signing evidence (see JFrog Evidence documentation)
3. Update `JFROG_URL` and repository names in the workflow

This workflow will:

- Build your Docker image
- Push it to JFrog Artifactory
- Scan for security issues with CoGuard
- Attach scan results as evidence in JFrog

You can view the evidence in your JFrog platform for compliance tracking!
```

### Example 11: Coverity Integration

```
You: We use Coverity for static analysis. Can CoGuard integrate with it?

Agent: Absolutely! CoGuard can integrate configuration security findings into
your Coverity reports. This requires CoGuard Enterprise and a valid Coverity
license.

I'll create a shell script that can be run in your CI/CD pipeline...

[Creates scripts/coguard-coverity-integration.sh]

```bash
#!/bin/bash
set -ex

# Configuration parameters
COGUARD_CLUSTER=$1                          # CoGuard cluster name
COVERITY_LOCATION=$2                        # Path to cov-analysis-VERSION folder
COVERITY_HOST=$3                            # Coverity server host
COVERITY_PORT=${4:-443}                     # Coverity server port (default: 443)
COVERITY_USER=${5:-admin}                   # Coverity username (default: admin)
COVERITY_STREAM=${6:-$COGUARD_CLUSTER}     # Coverity stream (default: cluster name)
TEMP_LOCATION_PREFIX=${7:-$(pwd)}          # Temporary files location

# Validate required parameters
test -n "$COGUARD_CLUSTER"
test -n "$COVERITY_LOCATION"
test -n "$COVERITY_HOST"
test -n "$COVERITY_PASSWORD"  # Must be set in environment

echo "Starting CoGuard-Coverity integration..."

# Create temporary directory for results
TEMP_DIR=$(mktemp -d --tmpdir="$TEMP_LOCATION_PREFIX")
echo "Using temp directory: $TEMP_DIR"

# Step 1: Download CoGuard cluster report
echo "Downloading CoGuard cluster report..."
coguard account download-cluster-report \
    "$COGUARD_CLUSTER" \
    "$TEMP_DIR"/"$COGUARD_CLUSTER"_DOWNLOAD.zip

# Step 2: Extract report and snapshot
echo "Extracting report and snapshot..."
unzip -u "$TEMP_DIR"/"$COGUARD_CLUSTER"_DOWNLOAD.zip -d "$TEMP_DIR"
unzip -u "$TEMP_DIR"/cluster_snapshot.zip -d "$TEMP_DIR"/cluster_snapshot

# Step 3: Translate CoGuard results to Coverity format
echo "Translating results to Coverity format..."
coguard-coverity-translator "$TEMP_DIR"

# Step 4: Create Coverity intermediate directory
mkdir -p "$TEMP_DIR"/cov-translation

# Step 5: Import results into Coverity
echo "Importing results into Coverity..."
"$COVERITY_LOCATION"/bin/cov-import-results \
    --dir "$TEMP_DIR"/cov-translation \
    "$TEMP_DIR"/result_coverity.json

# Step 6: Commit defects to Coverity platform
echo "Committing defects to Coverity..."
"$COVERITY_LOCATION"/bin/cov-commit-defects \
    --dir "$TEMP_DIR"/cov-translation \
    --host "$COVERITY_HOST" \
    --user "$COVERITY_USER" \
    --password "$COVERITY_PASSWORD" \
    --port "$COVERITY_PORT" \
    --stream "$COVERITY_STREAM"

# Cleanup
echo "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

echo "✓ CoGuard results successfully integrated into Coverity!"
```

✓ Created Coverity integration script

**Usage**:

```bash
export COVERITY_PASSWORD="your-coverity-password"
./scripts/coguard-coverity-integration.sh \
    "my-cluster" \
    "/opt/cov-analysis-2024.3.0" \
    "coverity.yourcompany.com" \
    8443 \
    "admin" \
    "main-stream"
```

**CI/CD Integration Example (Jenkins)**:

[Creates Jenkinsfile snippet]

```groovy
stage('CoGuard-Coverity Integration') {
    environment {
        COVERITY_PASSWORD = credentials('coverity-password')
    }
    steps {
        sh '''
            chmod +x scripts/coguard-coverity-integration.sh
            ./scripts/coguard-coverity-integration.sh \
                "${COGUARD_CLUSTER}" \
                "${COVERITY_HOME}" \
                "${COVERITY_HOST}" \
                "${COVERITY_PORT}" \
                "${COVERITY_USER}" \
                "${COVERITY_STREAM}"
        '''
    }
}
```

This integration:

- Downloads your CoGuard cluster scan results
- Translates them to Coverity's defect format
- Imports configuration issues alongside code issues
- Provides unified security reporting in Coverity

Configuration security findings will now appear in your Coverity dashboard!
```

---

These examples demonstrate the versatility and power of the CoGuard skill. Use
them as inspiration for your own security workflows!

For more examples and use cases, visit the
[CoGuard blog](https://coguard.io/blog).
