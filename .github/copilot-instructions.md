# Genocs Library Template - Copilot Instructions

## Project Overview
This is a .NET 9 project template repository that packages a complete Clean Architecture solution as a NuGet template (`Genocs.Library.Template`). Users install this template via `dotnet new install` and generate new microservices projects with `dotnet new gnx-librawebapi`.

## Architecture & Structure

### Repository Structure
- **Template Source**: `src/template/` contains the actual template that gets packaged and distributed
- **Package Definition**: `src/Package.Template.nuspec` defines the NuGet template package configuration
- **Generated Projects**: Follow Clean Architecture with Domain, Infrastructure, WebApi, Worker, and test projects

### Template Components
The generated project includes:
- **WebApi**: ASP.NET Core Web API with controllers and middleware
- **Worker**: Background service for message processing
- **Domain**: Domain entities and business logic (DDD)
- **Infrastructure**: Data persistence, external integrations
- **Contracts**: DTOs, commands, events, queries (CQRS)
- **Tests**: Unit, Integration, and Acceptance test projects

### Clean Architecture Layers
- **Domain**: Core business logic, independent of frameworks
- **Infrastructure**: Database, message brokers, external services
- **WebApi/Worker**: Application entry points and API controllers
- **Contracts**: Cross-cutting data contracts and messaging

## Development Workflows

### Template Development & Testing
```bash
# Build and pack the template
nuget pack ./src/Package.Template.nuspec -NoDefaultExcludes -OutputDirectory ./out -Version 2.3.0

# Install template locally for testing
dotnet new uninstall Genocs.Library.Template  # Remove previous version
dotnet new install ./out/Genocs.Library.Template.2.3.0.nupkg

# Generate test project
dotnet new gnx-librawebapi --name TestCompany.TestProject.TestService
```

### Generated Project Workflows
```bash
# In generated project directory
dotnet build
dotnet test
dotnet run --project ./src/TestCompany.TestProject.TestService.WebApi
dotnet run --project ./src/TestCompany.TestProject.TestService.Worker
```

### Template Validation
```bash
# Test template parameters and help
dotnet new gnx-librawebapi --help

# Validate generated project builds and tests pass
cd TestCompany.TestProject.TestService
dotnet build --verbosity normal
dotnet test --verbosity normal
```

## Build Configuration

### Template Structure
- **Template Source**: `src/template/` contains the complete solution template
- **NuGet Spec**: `src/Package.Template.nuspec` defines template packaging with metadata and file exclusions
- **Global Configuration**: `Directory.Build.props` enforces StyleCop, Roslynator, nullable reference types

### Generated Project Features
- **Genocs Library Integration**: Uses Genocs.* packages for CQRS, messaging, persistence
- **MongoDB + Redis**: Pre-configured data persistence and caching
- **RabbitMQ + MassTransit**: Message broker integration for event-driven architecture
- **OpenTelemetry**: Distributed tracing and observability
- **Consul + Fabio**: Service discovery and load balancing

### Code Quality Standards
- **StyleCop + Roslynator**: Enforced via `Directory.Build.props` with custom `stylecop.json` rules
- **Nullable enabled**: All projects use `<Nullable>enable</Nullable>`
- **Documentation**: `GenerateDocumentationFile` enabled for XML docs
- **EditorConfig**: Consistent formatting rules across projects

## Key Patterns

### CQRS Implementation
Generated projects use command/query separation with MediatR-style handlers:
```csharp
// In Program.cs bootstrap
gnxBuilder
    .AddCommandHandlers()
    .AddEventHandlers()  
    .AddQueryHandlers()
    .AddInMemoryCommandDispatcher()
    .AddInMemoryEventDispatcher()
    .AddInMemoryQueryDispatcher()
```

### Genocs Library Integration
Core services initialization pattern from `Program.cs`:
```csharp
var gnxBuilder = builder.AddGenocs().AddOpenTelemetry();
gnxBuilder
    .AddErrorHandler<ExceptionToResponseMapper>()
    .AddMongoWithRegistration()
    .AddRedis();
await gnxBuilder.AddRabbitMQAsync();
```

### Infrastructure Organization
- **DevOps**: Azure pipeline YAML files in `devops/azure/`
- **Kubernetes**: Deployment manifests in `infrastructure/k8s/`
- **Bicep**: Azure infrastructure as code in `infrastructure/bicep/`
- **Docker**: Multi-stage Dockerfiles for WebApi and Worker

## CI/CD Pipeline
- **GitHub Actions**: `build_and_test.yml` runs on .NET 9 with restore, build, test, pack
- **NuGet publishing**: Separate workflow for package deployment
- **Version management**: `PackageVersion` in csproj, uses SemVer

## Dependencies & External Integration
- **Genocs Library**: Core framework packages (version 7.4.*) for CQRS, messaging, persistence
- **MassTransit + RabbitMQ**: Message broker for event-driven communication
- **MongoDB**: Primary data store with Genocs persistence layer
- **Redis**: Caching and session storage
- **OpenTelemetry**: Distributed tracing and metrics collection