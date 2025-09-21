# {project} Infrastructure as Code (IaC)

This folder contains the Infrastructure as Code (IaC) project settings using Terraform.

## Overview

The infrastructure creates a complete Azure environment for the project across multiple environments:

- **Development (dev)**
- **Testing (test)**
- **Staging (stage)**
- **Production (prod)**

## Resources Created

For each environment, the following resources are created:

### Core Resources

- **Resource Groups**: `rg-{project}-{env}`
- **App Service Plans**: `asp-{project}-{env}`
- **WebApi Apps**: `webapi-{project}-{env}` (Docker containers for API/Web services)
- **Worker Apps**: `worker-{project}-{env}` (Docker containers for background services)

### Container Infrastructure

- **Azure Container Registry**: `acr{project}` (shared across environments)
- **Managed Identities**: `identity{project}{env}` (for secure access)
- **Container Webhooks**: For automatic deployment on image push

### Supporting Services

- **Storage Accounts**: `st{project}{env}` (with blob containers for logs, artifacts, uploads)
- **Key Vaults**: `kv{project}{env}` (for secrets management)
- **Redis Caches**: `redis{project}{env}` (for caching)

### Monitoring & Observability

- **Log Analytics Workspace**: `analytics-ws{project}` (centralized logging)
- **Application Insights**: `appinsights-{project}{env}` (application monitoring)
- **Container Insights**: For container performance monitoring
- **Service Map**: For service dependency visualization
- **Diagnostic Settings**: Comprehensive logging for all services
- **Availability Tests**: Health checks for web applications
- **Action Groups**: Alerting and notification management

## Prerequisites

Before running the IaC code, ensure you have:

- **Terraform** installed (version >= 1.12.2)
- **Azure CLI** installed and authenticated
- **Azure subscription** with appropriate permissions
- **Git** for version control

## Configuration

1. **Copy the example configuration**:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Modify the configuration** in `terraform.tfvars`:
   - Update the Azure region if needed
   - Adjust App Service Plan SKUs for cost optimization
   - Add custom tags for your organization

## Usage

### Initial Setup

1. **Clone the repository** and navigate to the iac folder:

   ```bash
   cd infrastructure/terraform
   ```

2. **Initialize Terraform**:

   ```bash
   terraform init
   ```

3. **Plan the changes**:

   ```bash
   terraform plan
   ```

4. **Apply the infrastructure**:
   ```bash
   terraform apply
   ```

### Environment-Specific Operations

To work with specific environments, you can use Terraform workspaces:

```bash
# Create and switch to a specific environment workspace
terraform workspace new dev
terraform workspace select dev

# Or use the default workspace for all environments
terraform workspace select default
```

### Updating Infrastructure

1. **Plan changes**:

   ```bash
   terraform plan
   ```

2. **Apply changes**:
   ```bash
   terraform apply
   ```

### Cleanup

To destroy all resources (use with caution):

```bash
terraform destroy
```

## Outputs

After successful deployment, Terraform will output:

- Resource group names for each environment
- App Service names and URLs
- Container Registry details (login server, credentials)
- Managed Identity information for each environment
- Storage account names and container names
- Log Analytics Workspace details (workspace ID, shared keys)
- Application Insights details (instrumentation keys, connection strings)
- Key Vault names
- Redis cache names
- Action Group information for alerting

## Cost Optimization

The infrastructure is designed with cost optimization in mind:

- **Development/Test**: Basic tier App Service Plans (B1)
- **Staging**: Standard tier App Service Plans (S1)
- **Production**: Premium tier App Service Plans (P1v2)
- **Storage**: LRS for non-production, GRS for production
- **Redis**: Basic tier for non-production, Standard for production

## Security

- All resources are tagged with environment and project information
- Key Vaults are created for secure secret management
- TLS 1.2 is enforced on storage accounts
- Soft delete is enabled on Key Vaults
- Managed Identities provide secure access to ACR and Key Vault
- Container images are stored in private Azure Container Registry
- Role-based access control (RBAC) is configured for all services

## Monitoring & Observability

### Centralized Logging

- **Log Analytics Workspace** provides centralized log collection and analysis
- **Diagnostic Settings** configured via setup script for all Azure services
- **Retention Policies** optimized for cost and compliance

### Application Performance Monitoring

- **Application Insights** with environment-specific sampling
- **Availability Tests** for web application health monitoring
- **Container Insights** for container performance monitoring
- **Service Map** for service dependency visualization

### Alerting & Notifications

- **Action Groups** for alert management
- **Email notifications** for critical issues
- **Customizable alert rules** for different environments

### Cost Optimization

- **Sampling percentages** optimized per environment (50% dev/test, 75% stage, 100% prod)
- **Retention periods** configured for cost efficiency
- **Log Analytics solutions** for enhanced monitoring capabilities

## Container Deployment

### Building and Pushing Images

After the infrastructure is deployed, you can build and push your Docker images:

```bash
# Login to Azure Container Registry
az acr login --name acr{project}

# Build and tag images
docker build -t acr{project}.azurecr.io/webapi:dev ./src/WebApi
docker build -t acr{project}.azurecr.io/worker:dev ./src/Worker

# Push images to registry
docker push acr{project}.azurecr.io/webapi:dev
docker push acr{project}.azurecr.io/worker:dev
```

### Environment-Specific Deployments

For different environments, use appropriate tags:

- **Development**: `dev`
- **Testing**: `test`
- **Staging**: `stage`
- **Production**: `latest`

### Automatic Deployment

The infrastructure includes webhooks that automatically deploy new container images when pushed to the registry.

## Monitoring Queries & Dashboards

### Useful Log Analytics Queries

After deployment, you can use these queries in the Log Analytics Workspace:

#### Container Performance

```kusto
// Container CPU and Memory usage
Perf
| where ObjectName == "Container"
| where CounterName in ("% Processor Time", "Memory Usage")
| summarize avg(CounterValue) by CounterName, bin(TimeGenerated, 5m)
```

#### Application Errors

```kusto
// Application errors by environment
exceptions
| where timestamp > ago(24h)
| summarize count() by cloud_RoleName, bin(timestamp, 1h)
```

#### App Service Performance

```kusto
// App Service response times
requests
| where timestamp > ago(1h)
| summarize avg(duration) by cloud_RoleName, bin(timestamp, 5m)
```

#### Storage Account Activity

```kusto
// Storage account operations
AzureDiagnostics
| where ResourceType == "STORAGEACCOUNTS"
| where OperationName in ("GetBlob", "PutBlob", "DeleteBlob")
| summarize count() by OperationName, bin(TimeGenerated, 1h)
```

### Creating Custom Dashboards

1. Navigate to the Log Analytics Workspace in Azure Portal
2. Use the queries above to create custom dashboards
3. Pin charts to Azure Dashboards for team visibility
4. Set up alerts based on custom metrics and thresholds

## Support

For issues or questions regarding the infrastructure:

1. Check the Terraform documentation
2. Review Azure resource provider documentation
3. Contact the DevOps team
