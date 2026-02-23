# CoGuard Security Scanning Skill for Claude Code

A comprehensive skill that enables Claude Code to automatically scan your infrastructure
configurations for security vulnerabilities and misconfigurations using
[CoGuard](https://coguard.io), then interpret and help fix the findings.

## What is This?

This is a custom skill for [Claude Code](https://claude.com/claude-code) that brings
infrastructure security scanning capabilities directly into your development workflow.
When you invoke this skill, Claude will:

1. ✅ Scan your project with CoGuard
2. 🔍 Analyze and interpret security findings
3. 📊 Prioritize issues by severity and impact
4. 🛠️ Suggest concrete fixes with explanations
5. ⚡ Optionally implement the fixes for you

## Why Use This Skill?

- **Shift Security Left**: Catch configuration issues before they reach production
- **Learn as You Go**: Understand *why* certain configurations are insecure
- **Save Time**: Let Claude interpret complex security reports and suggest fixes
- **Comprehensive Coverage**: Scan Docker images, IaC files, cloud configs, and more
- **Actionable Results**: Get specific, implementable fixes, not just warnings

## Prerequisites

1. **Claude Code**: Install from [claude.com/claude-code](https://claude.com/claude-code)
2. **CoGuard CLI**: Install via pip
   ```bash
   pip3 install coguard-cli
   ```
3. **Docker**: Required for Docker image/container scanning
4. **CoGuard Account**: Free account created on first scan

## Installation

### Option 1: Install from GitHub (Recommended)

```bash
# Clone this repository
git clone https://github.com/coguardio/coguard-skill.git

# Install the skill in Claude Code
claude code skill install ./coguard-skill
```

### Option 2: Manual Installation

1. Download this repository
2. Place the `skill.json` and `prompt.md` files in your Claude Code skills
   directory:
   - **macOS/Linux**: `~/.claude-code/skills/coguard/`
   - **Windows**: `%USERPROFILE%\.claude-code\skills\coguard\`
3. Restart Claude Code

### Option 3: Direct URL Install (if supported)

```bash
claude code skill install https://github.com/coguardio/coguard-skill
```

## Usage

Once installed, invoke the skill in any project directory:

```
/coguard
```

### Example Workflows

#### 1. Scan Your Current Project

```
You: /coguard
Claude: I'll scan your project for security issues...
[Runs scan, analyzes results, presents findings]
```

#### 2. Scan and Fix Issues

```
You: /coguard and fix any critical issues
Claude: I'll scan and fix critical security issues...
[Scans, identifies problems, applies fixes, verifies]
```

#### 3. Scan Specific Docker Image

```
You: /coguard scan the nginx:latest Docker image
Claude: I'll scan the nginx:latest image...
[Analyzes Docker image configuration]
```

#### 4. Scan Cloud Configuration

```
You: /coguard scan my AWS infrastructure
Claude: I'll scan your AWS configuration...
[Extracts and analyzes AWS settings]
```

## What Gets Scanned?

CoGuard analyzes configurations for:

### Infrastructure as Code
- 🏗️ Terraform
- ☸️ Kubernetes & Helm
- 📋 CloudFormation
- 📦 Ansible
- 🐳 Docker & Dockerfiles

### Applications & Databases
- 🌐 NGINX, Apache, Tomcat
- 🗄️ PostgreSQL, MySQL, MongoDB
- 📊 Elasticsearch, Redis, Cassandra
- 📮 Apache Kafka
- 🔐 Kerberos

### Cloud Platforms
- ☁️ AWS
- 🔵 Azure
- 🌩️ Google Cloud Platform

### CI/CD & DevOps
- 🔧 Jenkins
- 🚀 GitHub Actions
- 📊 BitBucket Pipelines
- 📡 OpenTelemetry Collector

[See full list of supported technologies]
(https://github.com/coguardio/coguard-cli#supported-technologies)

## Example Output

```
## CoGuard Security Scan Results

### Summary
- 2 critical issues found
- 5 high-priority issues found
- 12 medium/low issues found

### Critical Issues (Fix Immediately)

1. **PostgreSQL Password Authentication Enabled** in `docker-compose.yml:15`
   - **Problem**: PostgreSQL is configured to allow password authentication without
     SSL/TLS encryption
   - **Impact**: Database credentials can be intercepted in plain text
   - **Fix**: Enable SSL and use certificate-based authentication

2. **Kubernetes Secret Stored in Plain Text** in `k8s/secrets.yaml:3`
   - **Problem**: Sensitive data stored unencrypted in version control
   - **Impact**: Credentials exposed to anyone with repository access
   - **Fix**: Use sealed secrets or external secret management

### High Priority Issues

3. **NGINX Server Tokens Exposed** in `nginx/nginx.conf:25`
   - **Problem**: Server version information disclosed in HTTP headers
   - **Impact**: Attackers can identify specific vulnerabilities for your version
   - **Fix**: Add `server_tokens off;` to http block

[... more findings ...]

Would you like me to fix any of these issues?
```

## Features

### 🎯 Smart Scanning
- Automatically detects project type and runs appropriate scan
- Scans Docker images, containers, folders, and cloud configurations
- Comprehensive or targeted scanning based on your needs

### 📝 Clear Explanations
- Every finding explained in plain language
- Security impact clearly stated
- References to specific files and line numbers

### 🔧 Actionable Fixes
- Concrete remediation steps for each issue
- Can automatically apply fixes with your approval
- Re-scans to verify fixes worked

### 📚 Educational
- Learn *why* configurations are insecure
- Understand security best practices
- Build security knowledge over time

## Advanced Usage

### Scan Only Specific File Types

```
You: /coguard scan only Terraform files
Claude: [Scans only .tf files in the project]
```

### Focus on Specific Severity

```
You: /coguard show me only critical and high severity issues
Claude: [Filters and displays top priority findings]
```

### Explain a Specific Finding

```
You: /coguard explain why server tokens should be disabled
Claude: [Provides detailed explanation of the security principle]
```

### Generate Security Report

```
You: /coguard create a security report for my team
Claude: [Generates formatted report of all findings]
```

## Integration with Development Workflow

### Pre-Commit Scanning

Add CoGuard to your pre-commit workflow:

```bash
# In your project
coguard folder scan . --fail-on-critical
```

### CI/CD Integration

Generate pipeline configuration:

```bash
coguard pipeline github add .
```

This creates a GitHub Action that scans on every PR.

### Regular Audits

Use Claude Code with this skill for regular security reviews of your
infrastructure.

## Troubleshooting

### "CoGuard not found"

Install CoGuard CLI:

```bash
pip3 install coguard-cli
```

### "Authentication required"

On first scan, you'll be prompted to create a free CoGuard account. Follow the
instructions in the terminal.

### "Permission denied" (Windows)

Windows users need symbolic link permissions. Run PowerShell as Administrator or
enable Developer Mode.

### Scan taking too long

Cloud scans can take 2-5 minutes depending on infrastructure size. This is normal.

## Privacy & Security

- Scans run locally on your machine
- Configuration data is sent to CoGuard API for analysis
- Results stored in your CoGuard account at https://portal.coguard.io
- See [CoGuard Privacy Policy](https://coguard.io/privacy) for details

## Contributing

We welcome contributions! Here's how you can help:

1. **Report Issues**: Found a bug?
   [Open an issue](https://github.com/coguardio/coguard-skill/issues)
2. **Suggest Improvements**: Ideas for better interpretations? Share them!
3. **Submit PRs**: Improve the skill's prompts or documentation
4. **Share Examples**: Show us how you use this skill

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Support

- **Skill Issues**:
  [GitHub Issues](https://github.com/coguardio/coguard-skill/issues)
- **CoGuard CLI Issues**:
  [CoGuard CLI Repo](https://github.com/coguardio/coguard-cli/issues)
- **CoGuard Support**: [Contact CoGuard](https://coguard.io/contact)
- **Claude Code Help**:
  [Claude Code Documentation](https://claude.com/claude-code/docs)

## Resources

- [CoGuard Website](https://coguard.io)
- [CoGuard CLI Documentation](https://github.com/coguardio/coguard-cli)
- [CoGuard Blog](https://coguard.io/blog)
- [Claude Code](https://claude.com/claude-code)

## License

MIT License - See [LICENSE](LICENSE) for details

## About CoGuard

CoGuard is a comprehensive static analysis tool for IT infrastructure configurations.
It helps teams find and fix misconfigurations and security vulnerabilities in IaC,
containers, cloud settings, and applications.

Learn more at [coguard.io](https://coguard.io)

---

**Made with ❤️ by the CoGuard team to help developers build more secure
infrastructure**
