# CoGuard Skill Usage Examples

This document provides detailed examples of using the CoGuard skill in various scenarios.

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

**Scenario**: You have a Node.js application with Docker deployment and want to check for security issues.

```
You: /coguard

Claude: I'll scan your project for security issues. Let me first check if CoGuard is installed...

[Runs: coguard --version]

CoGuard is installed (v2.1.0). Now scanning your project...

[Runs: coguard folder scan .]

## CoGuard Security Scan Results

### Summary
- 1 critical issue found
- 3 high-priority issues found
- 8 medium/low issues found

### Critical Issues (Fix Immediately)

1. **Docker Container Running as Root** in `Dockerfile:8`
   - **Problem**: Container runs with root privileges (no USER directive)
   - **Impact**: If compromised, attacker has root access to container and
     potentially the host system
   - **Fix**: Add a non-root user before CMD instruction:
     ```dockerfile
     RUN adduser -D -u 1000 appuser
     USER appuser
     ```

### High Priority Issues

2. **NGINX Version Disclosure** in `nginx/nginx.conf:12`
   - **Problem**: Server version exposed in HTTP headers and error pages
   - **Impact**: Attackers can identify specific CVEs for your version
   - **Fix**: Add to http block:
     ```nginx
     server_tokens off;
     ```

3. **Missing Security Headers** in `nginx/nginx.conf`
   - **Problem**: No X-Frame-Options, X-Content-Type-Options, or CSP headers
   - **Impact**: Vulnerable to clickjacking and XSS attacks
   - **Fix**: Add security headers block

4. **Weak SSL Configuration** in `nginx/ssl.conf:5`
   - **Problem**: TLSv1.0 and TLSv1.1 enabled
   - **Impact**: Vulnerable to known TLS vulnerabilities (BEAST, POODLE)
   - **Fix**: Use only TLSv1.2 and TLSv1.3

Would you like me to fix these issues?
```

### Example 2: Quick security check before deployment

```
You: I'm about to deploy to production. Can you do a quick security scan?

Claude: Absolutely, let me run a comprehensive security scan before your deployment...

[Runs scan and analyzes]

Good news! Only minor issues found:
- 0 critical issues ✓
- 0 high-priority issues ✓
- 3 medium-priority best practice recommendations

The medium-priority items are:
1. Consider adding rate limiting to API endpoints
2. Database backup retention could be extended
3. Log retention period is shorter than recommended

Your project is safe to deploy. Would you like me to create a summary report of these findings?
```

## Docker Image Analysis

### Example 3: Scanning a third-party Docker image

```
You: /coguard scan the postgres:14 image I'm planning to use

Claude: I'll scan the postgres:14 Docker image for security issues...

[Runs: coguard docker-image scan postgres:14]

## PostgreSQL 14 Docker Image Security Analysis

### Summary
- 0 critical issues (this is the official image - well maintained!)
- 2 high-priority configuration recommendations
- 5 medium-priority best practices

### High Priority Recommendations

1. **Default PostgreSQL Configuration** in `/var/lib/postgresql/data/postgresql.conf`
   - **Issue**: Image uses default configuration optimized for compatibility,
     not security
   - **Impact**: Not optimal for production use
   - **Recommendation**: Override with custom postgresql.conf that includes:
     - `ssl = on` (requires SSL certificates)
     - `password_encryption = scram-sha-256`
     - `log_connections = on`
     - `log_disconnections = on`

2. **Superuser Access**
   - **Issue**: POSTGRES_USER creates superuser by default
   - **Impact**: Application doesn't need superuser privileges
   - **Recommendation**: Create separate application user with limited privileges

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

## Infrastructure as Code Review

### Example 4: Terraform security audit

```
You: /coguard review my Terraform configs for AWS

Claude: I'll analyze your Terraform configurations for AWS security best practices...

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
   - **Impact**: All bucket contents visible to the internet; potential data breach
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

2. **Security Group Allows 0.0.0.0/0 on SSH** in `infrastructure/security_groups.tf:23`
   - **Problem**: SSH port 22 open to entire internet
   - **Impact**: Exposed to brute force attacks and automated exploit attempts
   - **Fix**: Restrict to specific IP ranges or use AWS Systems Manager Session Manager

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
You: /coguard scan my AWS infrastructure

Claude: I'll extract and scan your current AWS configuration. This may take 2-3 minutes...

[Runs: coguard cloud scan aws]

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
You: /coguard scan and fix all critical issues

Claude: I'll scan your project and fix critical security issues...

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

### Fixing Issue 2: NGINX Server Tokens

In nginx/nginx.conf:12, disabling version disclosure...

[Uses Edit tool]

```nginx
http {
    # Security: Hide nginx version
    server_tokens off;

    # Existing configuration...
    include mime.types;
    default_type application/octet-stream;
    ...
}
```

✓ Fixed - Server version no longer exposed

### Verifying Fixes

Re-running CoGuard scan to confirm...

[Runs: coguard folder scan .]

✓ Scan complete!
- Critical issues: 0 (was 2)
- High priority: 3 (unchanged)
- Medium/Low: 8 (unchanged)

Both critical issues have been successfully resolved! Your container security is now significantly improved.

Would you like me to address the high-priority issues as well?
```

## Educational Use Cases

### Example 7: Learning about security best practices

```
You: /coguard I want to learn about securing my PostgreSQL database. Can you scan it and explain?

Claude: Great question! Let me scan your PostgreSQL configuration and walk you through security best practices...

[Runs scan]

## PostgreSQL Security Configuration Review

I found your PostgreSQL config at `config/postgresql.conf`. Let me explain each security aspect:

### 1. Authentication Methods

**Current setting** (pg_hba.conf:15):
```
host  all  all  0.0.0.0/0  md5
```

**Why this matters**: This allows password authentication from any IP address. While convenient, it has two problems:
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

**Why this matters**: Without SSL, all data including passwords travels in plain text across the network. Anyone with network access can intercept it.

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
You: /coguard create a security report I can share with my team

Claude: I'll generate a comprehensive security report suitable for team review...

[Runs scan and formats results]

# Infrastructure Security Report
**Generated**: 2024-02-23
**Project**: MyApp Platform
**Scanned by**: CoGuard CLI via Claude Code

## Executive Summary

Security scan identified 23 findings across Docker configurations, infrastructure code, and application settings. Immediate attention required for 2 critical items that pose significant security risks.

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
You: /coguard set up continuous security scanning in CI/CD

Claude: I'll help you integrate CoGuard into your CI/CD pipeline...

First, let me scan your current setup and then generate the pipeline configuration...

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
          coguard folder scan . --output json > scan-results.json

      - name: Check for Critical Issues
        run: |
          CRITICAL=$(jq '.findings[] | select(.severity=="critical") | length' scan-results.json)
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

---

These examples demonstrate the versatility and power of the CoGuard skill. Use them as inspiration for your own security workflows!

For more examples and use cases, visit the [CoGuard blog](https://coguard.io/blog).
