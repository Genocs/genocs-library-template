<!-- PROJECT SHIELDS -->

[![License][license-shield]][license-url]
[![Build][build-shield]][build-url]
[![Packages][package-shield]][package-url]
[![Downloads][downloads-shield]][downloads-url]
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![Discord][discord-shield]][discord-url]
[![Gitter][gitter-shield]][gitter-url]
[![Twitter][twitter-shield]][twitter-url]
[![Twitterx][twitterx-shield]][twitterx-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

[license-shield]: https://img.shields.io/github/license/Genocs/genocs-library-template?color=2da44e&style=flat-square
[license-url]: https://github.com/Genocs/genocs-library-template/blob/main/LICENSE
[build-shield]: https://github.com/Genocs/genocs-library-template/actions/workflows/build-and-test.yml/badge.svg?branch=main
[build-url]: https://github.com/Genocs/genocs-library-template/actions/workflows/build-and-test.yml
[package-shield]: https://img.shields.io/badge/nuget-v.3.0.0-blue?&label=latests&logo=nuget
[package-url]: https://www.nuget.org/packages/Genocs.Library.Template
[downloads-shield]: https://img.shields.io/nuget/dt/Genocs.Library.Template.svg?color=2da44e&label=downloads&logo=nuget
[downloads-url]: https://www.nuget.org/packages/Genocs.Library.Template
[contributors-shield]: https://img.shields.io/github/contributors/Genocs/genocs-library-template.svg?style=flat-square
[contributors-url]: https://github.com/Genocs/genocs-library-template/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/Genocs/genocs-library-template?style=flat-square
[forks-url]: https://github.com/Genocs/genocs-library-template/network/members
[stars-shield]: https://img.shields.io/github/stars/Genocs/genocs-library-template.svg?style=flat-square
[stars-url]: https://img.shields.io/github/stars/Genocs/genocs-library-template?style=flat-square
[issues-shield]: https://img.shields.io/github/issues/Genocs/genocs-library-template?style=flat-square
[issues-url]: https://github.com/Genocs/genocs-library-template/issues
[discord-shield]: https://img.shields.io/discord/1106846706512953385?color=%237289da&label=Discord&logo=discord&logoColor=%237289da&style=flat-square
[discord-url]: https://discord.com/invite/fWwArnkV
[gitter-shield]: https://img.shields.io/badge/chat-on%20gitter-blue.svg
[gitter-url]: https://gitter.im/genocs/
[twitter-shield]: https://img.shields.io/twitter/follow/genocs?color=1DA1F2&label=Twitter&logo=Twitter&style=flat-square
[twitter-url]: https://twitter.com/genocs
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=flat-square&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/giovanni-emanuele-nocco-b31a5169/
[twitterx-shield]: https://img.shields.io/twitter/url/https/twitter.com/genocs.svg?style=social
[twitterx-url]: https://twitter.com/genocs

<p align="center">
    <img src="./assets/genocs-library-logo.png" alt="Genocs Library Template Logo">
</p>

# Genocs Library Template

A comprehensive .NET template that incorporates Genocs packages and follows `Clean Architecture` principles. This template provides a solid foundation for building scalable web applications and services by using [Genocs Library](https://github.com/Genocs/genocs-library) Nuget packages.

## Overview

This repository provides a comprehensive .NET project template designed to accelerate web application development. It includes:

- **Clean Architecture**: Well-structured, maintainable codebase following industry best practices
- **Essential Packages**: Pre-configured with the most commonly needed NuGet packages
- **Ready-to-Use Components**: Built-in features and components to jumpstart development
- **Multiple Project Types**: Support for Web APIs, Worker services, and more

## What's Included

- Web API project with controllers and infrastructure
- Worker service for background processing
- Domain-driven design structure
- Unit, Integration and Acceptance test projects
- Docker support
- Kubernetes deployment manifests
- Azure DevOps pipeline

## Prerequisites

Before getting started, ensure you have the following installed:

- [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0)
- [Git](https://git-scm.com/downloads)

### Optional Development Tools
- [Visual Studio 2026](https://visualstudio.microsoft.com/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [JetBrains Rider](https://www.jetbrains.com/rider/)

## Installation

Install the template using the .NET CLI:

```bash
# Install the latest version
dotnet new install Genocs.Library.Template

# Install a specific version
dotnet new install Genocs.Library.Template::2.3.0
```

## Usage

Create a new project from the template:

```bash
# Create a new project
dotnet new gnx-librawebapi --name MyCompany.MyProject

# Get help and see all options
dotnet new gnx-librawebapi --help
```

> **Latest Version**: Current stable release is **2.3.0**. Visit [NuGet](https://www.nuget.org/packages/Genocs.Library.Template/) for the latest version.

## Documentation

For comprehensive documentation and advanced usage:

- [Genocs Library Documentation](https://genocs-blog.netlify.app/library/)
- [.NET Custom Templates Guide](https://docs.microsoft.com/en-us/dotnet/core/tools/custom-templates)
- [Visual Studio Project Templates](https://learn.microsoft.com/en-us/visualstudio/ide/how-to-locate-and-organize-project-and-item-templates?view=vs-2026)

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on how to submit pull requests, report issues, and contribute to the project.

## Changelog

View the complete [changelog](https://github.com/Genocs/genocs-library-template/blob/main/CHANGELOG.md) for detailed release notes and version history.

## Community

Join our community and stay connected:

- 💬 **Discord**: [@genocs](https://discord.com/invite/fWwArnkV)
- 📘 **Facebook**: [@genocs](https://facebook.com/Genocs)
- 📺 **YouTube**: [@genocs](https://youtube.com/c/genocs)

## Support This Project

If this project has helped you learn something new or assisted you in your work, consider supporting it:

- ⭐ **Star this repository** to show your appreciation
- 🔄 **Share** this project with your colleagues and networks
- 💼 **Endorse** on LinkedIn for ASP.NET Core - [Connect with the maintainer](https://www.linkedin.com/in/giovanni-emanuele-nocco-b31a5169/)
- ☕ **Buy me a coffee** to support long-term development - [Support via Buy Me a Coffee](https://www.buymeacoffee.com/genocs)

<p>
  <a href="https://www.buymeacoffee.com/genocs">
    <img src="./assets/buy-me-a-coffee.png" alt="Buy me a coffee" width="200"/>
  </a>
</p>

## Contributors

This project exists thanks to all the people who contribute. We welcome new contributors!

**Want to contribute?** Check out our [Contributing Guidelines](CONTRIBUTING.md) to get started.

### Financial Contributors

Become a financial contributor and help sustain this project's development.

**Support the project on [Open Collective](https://opencollective.com/genocs)**

<p align="center">
  <a href="https://opencollective.com/genocs">
    <img src="https://opencollective.com/genocs/individuals.svg?width=890" alt="Financial Contributors"/>
  </a>
</p>

---

<p align="center">
  Made with ❤️ by the <a href="https://github.com/Genocs">Genocs</a> team
</p>
