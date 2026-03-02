# Contributing to the CoGuard Misconfiguration Detection Skill

Thank you for your interest in contributing to the CoGuard skill! This document
provides guidelines for contributing to the project.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion for improvement:

1. Check if the issue already exists in [GitHub Issues]
   (https://github.com/coguardio/coguard-skill/issues)
2. If not, create a new issue with:
   - Clear, descriptive title
   - Detailed description of the problem or suggestion
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Your environment (OS, coding agent and version, CoGuard CLI version)

### Improving the Skill

The skill is defined across two main files:

#### `SKILL.md`

The skill definition file consumed by coding agents (such as Claude Code, Cursor,
Windsurf, and others) during execution. The frontmatter contains the skill name
and description. The body contains all behavioral instructions. This is where most
improvements happen:

- Clarifying scanning workflows
- Improving remediation guidance
- Tightening agent behavioral directives

#### `EXAMPLES.md`

Contains detailed usage examples demonstrating various scanning scenarios, fix
workflows, and integration patterns. Improvements here help users understand what
the skill can do and serve as reference material for coding agents.

### Improvement Ideas

Here are areas where contributions are especially welcome:

#### Enhanced Remediation

- Better coverage of edge cases in findings and how to remediate them
- More detailed fix explanations for uncommon configuration scenarios
- Code examples for common fixes
- Links to relevant documentation

#### Expanded Use Cases

- Industry-specific scanning workflows
- Industry-specific justifications for security configurations (e.g., why
  financial services require stricter database encryption, or why healthcare
  environments need specific access logging)
- Compliance-focused interpretations (PCI-DSS, HIPAA, etc.)
- Integration with other security tools

#### Documentation

- More usage examples
- Video tutorials
- Blog posts about using the skill

### Pull Request Process

1. **Fork the repository**
   ```bash
   git clone https://github.com/coguardio/coguard-skill.git
   cd coguard-skill
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Edit `SKILL.md` or documentation files
   - Test your changes thoroughly
   - Ensure markdown formatting is correct

4. **Test the skill locally**

   The simplest way to test is directly on your machine using a coding agent
   that supports custom skills:

   ```bash
   # Option A: Point your coding agent at the local SKILL.md
   # For Claude Code, place SKILL.md in your project's .claude/ directory
   # and invoke the skill from within a test project.

   # Option B: Run CoGuard CLI directly to verify scan behavior
   coguard --output-format json folder /path/to/test-project

   # Option C: Package and upload (for final verification)
   ./package.sh
   # Upload misconfiguration-detection.zip to your coding agent's skill interface
   ```

   Test against a project directory on your machine that contains
   configuration files (Dockerfiles, Terraform, Kubernetes manifests, etc.)
   to verify your changes produce the expected results.

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "Description of your changes"
   ```

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request**
   - Go to the original repository on GitHub
   - Click "New Pull Request"
   - Select your feature branch
   - Provide a clear description of your changes
   - Reference any related issues

### Testing Guidelines

Before submitting a PR, test your changes with:

1. **Different project types**
   - Pure IaC projects (Terraform, Kubernetes)
   - Docker-based projects
   - Mixed projects with multiple technologies

2. **Different scan scenarios**
   - Projects with no issues
   - Projects with critical issues
   - Projects with many findings

3. **Various user intents**
   - Simple scans
   - Scan and fix workflows
   - Focused scans on specific files

4. **Edge cases**
   - Very large projects
   - Projects with unusual structures
   - Missing dependencies

### Code Style

#### For `SKILL.md`

- Use direct imperatives, not passive or suggestive language
- Break down workflows into numbered steps
- Use markdown tables for structured data
- Keep lines under 100 characters
- Do not duplicate information across sections
- Include code examples with proper syntax highlighting

#### For `README.md` and docs

- Use clear headings and structure
- Include practical examples
- Keep language accessible to developers of all levels
- Use emojis sparingly and meaningfully

### Commit Message Guidelines

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move file" not "Moves file")
- Limit first line to 72 characters
- Reference issues and PRs when relevant

Examples:
```
Improve critical issue prioritization logic

Add explanation for database authentication findings

Fix formatting in remediation output

Update installation instructions for Windows
```

## Community Guidelines

- Be respectful and constructive
- Welcome newcomers and help them get started
- Focus on the problem, not the person
- Assume good intentions
- Credit others for their contributions

## Recognition

Contributors will be:
- Listed in the project's contributors section
- Credited in release notes for significant contributions
- Mentioned in blog posts about major features

## Questions?

If you have questions about contributing:
- Open a discussion on GitHub
- Reach out to the maintainers
- Check existing issues and PRs for context

## License

By contributing, you agree that your contributions will be licensed under the MIT
License, the same license as the project.

---

Thank you for helping make infrastructure security more accessible to
developers! 🛡️
