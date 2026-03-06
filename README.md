# CoGuard Misconfiguration Detection Skill

A comprehensive skill that enables AI coding agents to automatically scan your
infrastructure configurations for security vulnerabilities and misconfigurations
using [CoGuard](https://coguard.io), then interpret and help fix the findings.

## What is This?

This is a custom skill for AI coding agents (such as
[Claude Code](https://claude.com/claude-code), Cursor, Windsurf, and others) that
brings infrastructure security scanning capabilities directly into your development
workflow. When you invoke this skill, the agent will:

1. Scan your project with CoGuard
2. Analyze and interpret security findings
3. Prioritize issues by severity and impact
4. Suggest concrete fixes with explanations
5. Optionally implement the fixes for you

## Why Use This Skill?

- **Shift Security Left**: Catch configuration issues before they reach production
- **Learn as You Go**: Understand *why* certain configurations are insecure
- **Save Time**: Let your coding agent interpret complex security reports and suggest fixes
- **Comprehensive Coverage**: Scan Docker images, IaC files, cloud configs, and more
- **Actionable Results**: Get specific, implementable fixes, not just warnings

## Prerequisites

1. **A coding agent that supports custom skills**: e.g.,
   [Claude Code](https://claude.com/claude-code), Cursor, Windsurf, or similar
2. **CoGuard CLI**: Install via pip
   ```bash
   pip3 install coguard-cli
   ```
3. **Docker**: Required for Docker image/container scanning
4. **CoGuard Account**: Free account created on first scan

## Installation

### Quick Start

Run this one-liner to install the skill for all your projects:

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/coguardio/misconfiguration-detection-skill/master/install.sh | bash
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/coguardio/misconfiguration-detection-skill/master/install.ps1 | iex
```

That's it — restart Claude Code and type `/misconfiguration-detection`.

---

For full details on how skills work, see the
[Claude Code Skills Documentation](https://code.claude.com/docs/en/skills).

### Option 1: Personal Skill (git clone)

Personal skills are available across all your projects:

```bash
git clone https://github.com/coguardio/misconfiguration-detection-skill.git \
  ~/.claude/skills/misconfiguration-detection
```

### Option 2: Project Skill (git clone)

Project skills apply only to a single project and can be committed to version
control:

```bash
cd /path/to/your/project
git clone https://github.com/coguardio/misconfiguration-detection-skill.git \
  .claude/skills/misconfiguration-detection
```

### Option 3: Download from Releases

Download `misconfiguration-detection.zip` from the
[latest release](https://github.com/coguardio/misconfiguration-detection-skill/releases/latest)
and extract it into your skills directory:

```bash
mkdir -p ~/.claude/skills
unzip misconfiguration-detection.zip -d ~/.claude/skills/
```

### Verify Installation

Ask Claude Code to confirm the skill is loaded:

```
What skills are available?
```

You should see `misconfiguration-detection` in the list. You can also invoke it
directly with `/misconfiguration-detection`.

### Automatic Update Notifications

The skill checks for newer versions approximately every two weeks. If an update is
available, you'll see a one-line notice with the update command when you next invoke
the skill. The check is non-blocking and silent when you're already up to date.

To update manually at any time, re-run the install command for your platform
(see [Quick Start](#quick-start)).

## Usage

Once installed, invoke the skill in any project directory:

```
/misconfiguration-detection
```

### Example Workflows

#### 1. Scan Your Current Project

```
You: /misconfiguration-detection
Agent: I'll scan your project for security issues...
[Runs scan, analyzes results, presents findings]
```

#### 2. Scan and Fix Issues

```
You: /misconfiguration-detection and fix any critical issues
Agent: I'll scan and fix critical security issues...
[Scans, identifies problems, applies fixes, verifies]
```

#### 3. Scan Specific Docker Image

```
You: /misconfiguration-detection scan the nginx:latest Docker image
Agent: I'll scan the nginx:latest image...
[Analyzes Docker image configuration]
```

#### 4. Scan Cloud Configuration

```
You: /misconfiguration-detection scan my AWS infrastructure
Agent: I'll scan your AWS configuration...
[Extracts and analyzes AWS settings]
```

## What Gets Scanned?

CoGuard analyzes configurations for:

### Infrastructure as Code
- Terraform
- Kubernetes & Helm
- CloudFormation
- Ansible
- Docker & Dockerfiles
- ...

### Applications & Databases
- NGINX, Apache, Tomcat
- PostgreSQL, MySQL, MongoDB
- Elasticsearch, Redis, Cassandra
- Apache Kafka
- Kerberos
- ...

### Cloud Platforms
- AWS
- Azure
- Google Cloud Platform
- ...

### CI/CD & DevOps
- Jenkins
- GitHub Actions
- BitBucket Pipelines
- OpenTelemetry Collector
- ...

### And much more!!!

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
You: /misconfiguration-detection scan only Terraform files
Agent: [Scans only .tf files in the project]
```

### Focus on Specific Severity

```
You: /misconfiguration-detection show me only critical and high severity issues
Agent: [Filters and displays top priority findings]
```

### Explain a Specific Finding

```
You: /misconfiguration-detection explain why server tokens should be disabled
Agent: [Provides detailed explanation of the security principle]
```

### Generate Security Report

```
You: /misconfiguration-detection create a security report for my team
Agent: [Generates formatted report of all findings]
```

## Integration with Development Workflow

### Pre-Commit Scanning

Add CoGuard to your pre-commit workflow:

```bash
coguard --output-format json folder .
```

### CI/CD Integration

Add CoGuard to your CI pipeline using the
[CoGuard GitHub Action](https://github.com/coguardio/coguard-scan-action)
or by running `coguard folder .` in your pipeline script.

If you need to process scan results in subsequent pipeline steps, use
`coguard --output-format json folder .` which writes results to a
`result.json` file (instead of printing to stdout). You can then parse this
file in later pipeline stages. If you don't need programmatic access to the
results, omit the `--output-format json` flag.

### Regular Audits

Use your coding agent with this skill for regular security reviews of your
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

Cloud scans can take 15-20 minutes depending on infrastructure size. This is normal.

## Privacy & Security

- Scans run locally on your machine
- Configuration data is sent to CoGuard API for analysis
- Results stored in your CoGuard account at https://portal.coguard.io
- See [CoGuard Privacy Policy](https://coguard.io/privacy) for details

## Contributing

We welcome contributions! Here's how you can help:

1. **Report Issues**: Found a bug?
   [Open an issue](https://github.com/coguardio/misconfiguration-detection-skill/issues)
2. **Suggest Improvements**: Ideas for better interpretations? Share them!
3. **Submit PRs**: Improve the skill's prompts or documentation
4. **Share Examples**: Show us how you use this skill

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Support

- **Skill Issues**:
  [GitHub Issues](https://github.com/coguardio/misconfiguration-detection-skill/issues)
- **CoGuard CLI Issues**:
  [CoGuard CLI Repo](https://github.com/coguardio/coguard-cli/issues)
- **CoGuard Support**: [Contact CoGuard](https://coguard.io/contact)
- **Claude Code Help**:
  [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- **General**: This skill works with any coding agent that supports custom skills

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
