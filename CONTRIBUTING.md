# Contributing to Genocs Library Template

Thank you for helping improve the Genocs Library Template. Contributions are welcome in the form of bug reports, feature proposals, documentation, tests, and code changes.

Please read the [Code of Conduct](CODE_OF_CONDUCT.md) before participating. By contributing to this project, you agree to follow it.

## Before You Start

- Search existing [issues](https://github.com/Genocs/enterprise-app/issues) and pull requests before opening a new one.
- For bugs, include a minimal reproduction and the environment details requested by the [bug report template](.github/ISSUE_TEMPLATE/bug_report.yml).
- For enhancements, describe the problem, proposed solution, benefit, and alternatives using the [enhancement template](.github/ISSUE_TEMPLATE/enhancement.yml).
- For larger changes, open an issue first so the approach can be discussed before implementation begins.

## Development Setup

Install the following tools:

- [.NET SDK 10.0.403](https://dotnet.microsoft.com/download/dotnet/10.0), or a compatible SDK allowed by `global.json`
- [Git](https://git-scm.com/)
- [Docker](https://docs.docker.com/get-docker/) when working on integrations that require local infrastructure
- A supported editor such as [Visual Studio](https://visualstudio.microsoft.com/) or [Visual Studio Code](https://code.visualstudio.com/)

Clone the repository and create a feature branch:

```bash
git clone https://github.com/Genocs/genocs-library-template.git
cd genocs-library-template
git switch -c <short-description>
```

The repository includes local tool configuration in `dotnet-tools.json`. Restore tools when a task requires them:

```bash
dotnet tool restore
```

Some integration and container tests require services such as MongoDB, Redis, RabbitMQ, or SQL Server. See the infrastructure documentation and the relevant test project before running those tests.

## Build and Test

Run the standard validation commands from the repository root:

```bash
dotnet restore
dotnet build --no-restore
dotnet test --no-build
dotnet pack --no-build
```

Before opening a pull request:

- Confirm the solution builds without errors.
- Run the tests relevant to your change and record any required infrastructure.
- Check that new or changed behavior has appropriate unit, integration, or end-to-end coverage.
- Review the diff for accidental formatting, generated files, secrets, or unrelated changes.
- Update documentation and changelog content when the public behavior changes.

## Coding Guidelines

- Follow the existing C# conventions and repository analyzers.
- Keep changes focused and preserve existing public APIs unless a breaking change is intentional and discussed.
- Prefer clear names and self-documenting code. Comments should explain business context or architectural decisions, not restate code.
- Use the existing dependency injection, repository, validation, messaging, and telemetry patterns in the affected area.
- Do not commit credentials, connection strings containing secrets, local settings, build output, or test artifacts.

## Commits and Branches

Use a short-lived branch based on the current `main` branch. Keep commits focused, with clear messages written in the imperative mood, for example:

```text
Add validation for product creation
Fix retry handling for order messages
```

Avoid mixing unrelated refactoring with a feature or bug fix. If a change is large, split it into reviewable commits where practical.

## Pull Requests

Open a pull request against `main` after the change is ready for review. The [pull request template](.github/pull_request_template.md) describes the information reviewers need.

A pull request should:

- Explain what changed and why it is needed.
- Link related issues using closing keywords where appropriate, such as `Closes #123`.
- Describe how the change was tested, including any Docker or external service requirements.
- Include documentation or tests when they are part of the change.
- Keep the scope small enough to review confidently.

Maintainers may request revisions, tests, documentation, or design discussion before merging. Please respond to review feedback constructively and keep the conversation focused on improving the project.

## Questions and Support

Use GitHub issues for reproducible bugs and feature requests. For general questions, consult the [project README](README.md) and the [project documentation](https://genocs-blog.netlify.app) before opening an issue.