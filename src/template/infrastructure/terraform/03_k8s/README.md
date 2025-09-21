# AKS Infrastructure with AGIC

This Terraform configuration creates a complete Azure Kubernetes Service (AKS) infrastructure with Application Gateway Ingress Controller (AGIC), including networking, NAT Gateway, and monitoring components.

## Architecture Overview

The infrastructure includes:

- **Virtual Network (VNet)** with multiple subnets
- **AKS Cluster** with multiple node pools (system, user, spot)
- **Application Gateway** for ingress traffic
- **NAT Gateway** for outbound internet connectivity
- **AGIC (Application Gateway Ingress Controller)** for Kubernetes ingress management
- **Key Vault** for secrets, certificates, and keys management
- **Log Analytics Workspace** for monitoring
- **Network Security Groups** for security
- **Managed Identities** for authentication

## Components

### Network Infrastructure
- **VNet**: `10.0.0.0/16` address space
- **AKS Subnet**: `10.0.1.0/24` for AKS nodes
- **Application Gateway Subnet**: `10.0.2.0/24` for Application Gateway
- **NAT Gateway Subnet**: `10.0.3.0/24` for NAT Gateway
- **NAT Gateway**: Provides outbound internet connectivity for AKS nodes

### AKS Cluster
- **Kubernetes Version**: 1.33.0
- **Network Plugin**: Azure CNI
- **Network Policy**: Azure
- **Auto-scaling**: Disabled (fixed node counts)
- **Node Pools**:
  - **System Pool**: Standard_D2s_v3, fixed count (2 nodes)
  - **User Pool**: Standard_D4s_v3, fixed count (2 nodes)
  - **Spot Pool**: Standard_D2s_v3, fixed count (1 node), spot instances for cost optimization

### Application Gateway
- **SKU**: Standard_v2
- **Capacity**: 2 instances
- **WAF**: Enabled with OWASP 3.2 ruleset
- **SSL**: Self-signed certificate for initial setup
- **Health Probes**: Configured for backend health checks

### AGIC (Application Gateway Ingress Controller)
- **Version**: 1.6.0
- **Namespace**: agic-system
- **Authentication**: Azure Pod Identity
- **Features**: SSL termination, path-based routing, health probes

### Key Vault
- **SKU**: Standard
- **RBAC**: Enabled for modern access control
- **Soft Delete**: Enabled with 90-day retention
- **Purge Protection**: Enabled for security
- **Secrets**: Pre-configured secrets for common use cases
- **Certificates**: SSL certificate for Application Gateway
- **Keys**: Encryption key for data protection

## Prerequisites

1. **Azure CLI** installed and configured
2. **Terraform** >= 1.12.2
3. **kubectl** for Kubernetes management
4. **Helm** for AGIC installation
5. **Azure Subscription** with appropriate permissions

## Quick Start

1. **Clone and navigate to the directory**:
   ```bash
   cd infrastructure/terraform/02_k8s
   ```

2. **Copy and customize variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Plan the deployment**:
   ```bash
   terraform plan
   ```

5. **Apply the configuration**:
   ```bash
   terraform apply
   ```

6. **Get AKS credentials**:
   ```bash
   az aks get-credentials --resource-group <resource-group-name> --name <aks-cluster-name>
   ```

## Configuration

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `project_name` | Name of the project | `aks-cluster` |
| `environment` | Environment name | `dev` |
| `location` | Azure region | `West Europe` |
| `kubernetes_version` | Kubernetes version | `1.33.0` |
| `node_vm_size` | VM size for nodes | `Standard_D2s_v3` |
| `enable_auto_scaling` | Enable auto scaling | `false` |
| `network_plugin` | Network plugin | `azure` |
| `appgw_sku_name` | Application Gateway SKU name | `Standard_v2` |
| `appgw_sku_tier` | Application Gateway SKU tier | `Standard_v2` |
| `key_vault_sku_name` | Key Vault SKU | `standard` |
| `key_vault_enable_rbac_authorization` | Enable RBAC for Key Vault | `true` |

### Network Configuration

The infrastructure uses a hub-spoke network model with:
- Dedicated subnets for different components
- Network Security Groups for traffic filtering
- NAT Gateway for secure outbound connectivity
- Application Gateway for ingress traffic

### Security Features

- **RBAC**: Enabled for Kubernetes
- **Azure Policy**: Enabled for compliance
- **Workload Identity**: Enabled for secure pod authentication
- **OIDC Issuer**: Enabled for external integrations
- **WAF**: Web Application Firewall enabled
- **Network Security Groups**: Traffic filtering rules
- **Key Vault**: Secure secrets and certificate management

## Post-Deployment

### Verify AGIC Installation

```bash
# Check AGIC pods
kubectl get pods -n agic-system

# Check AGIC logs
kubectl logs -n agic-system -l app=ingress-azure

# Check Application Gateway configuration
az network application-gateway show --name <appgw-name> --resource-group <rg-name>
```

### Deploy Sample Application

A sample ingress is created for testing. You can deploy additional applications using:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  annotations:
    kubernetes.io/ingress.class: "azure/application-gateway"
    appgw.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app-service
            port:
              number: 80
```

### SSL Certificate Management

The initial setup includes a self-signed certificate. For production:

1. **Upload your SSL certificate** to Application Gateway
2. **Update the ingress** to use the new certificate
3. **Configure DNS** to point to the Application Gateway public IP

### Key Vault Management

The Key Vault is pre-configured with:

1. **Secrets**: Common application secrets (database connection, API keys)
2. **Certificates**: SSL certificate for Application Gateway
3. **Keys**: Encryption key for data protection
4. **Access Control**: RBAC enabled with proper permissions for AKS and Application Gateway

To access Key Vault secrets from your applications:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: key-vault-secret
  annotations:
    azure.workload.identity/client-id: <aks-identity-client-id>
type: Opaque
stringData:
  key-vault-url: "https://kv-<project>-<env>.vault.azure.net/"
  secret-name: "database-connection-string"
```

## Monitoring

### Log Analytics
- **Workspace**: Created for AKS monitoring
- **Retention**: Configurable (default 30 days)
- **Metrics**: Cluster and node metrics collected

### Application Gateway Monitoring
- **Health Probes**: Backend health monitoring
- **WAF Logs**: Security event logging
- **Performance Metrics**: Throughput and latency

## Cost Optimization

### Spot Instances
- **Spot Node Pool**: For non-critical workloads
- **Cost Savings**: Up to 90% compared to regular instances
- **Taints**: Applied to prevent critical workloads

### Fixed Node Configuration
- **System Pool**: Fixed at 2 nodes for system workloads
- **User Pool**: Fixed at 2 nodes for application workloads  
- **Spot Pool**: Fixed at 1 node for cost-optimized workloads
- **Manual Scaling**: Node counts can be adjusted via Terraform variables

## Troubleshooting

### Common Issues

1. **AGIC not working**:
   - Check pod identity configuration
   - Verify Application Gateway permissions
   - Check network connectivity

2. **SSL certificate issues**:
   - Verify certificate format
   - Check certificate binding
   - Validate domain configuration

3. **Network connectivity**:
   - Check NSG rules
   - Verify subnet configuration
   - Test NAT Gateway connectivity

### Useful Commands

```bash
# Check AKS cluster status
az aks show --name <cluster-name> --resource-group <rg-name>

# Check Application Gateway status
az network application-gateway show --name <appgw-name> --resource-group <rg-name>

# Check AGIC logs
kubectl logs -n agic-system -l app=ingress-azure

# Check Key Vault status
az keyvault show --name <key-vault-name> --resource-group <rg-name>

# List Key Vault secrets
az keyvault secret list --vault-name <key-vault-name>

# Test connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default
```

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

**Warning**: This will delete all resources. Make sure to backup any important data.

## Support

For issues and questions:
- Check the [Azure AKS documentation](https://docs.microsoft.com/en-us/azure/aks/)
- Review [AGIC documentation](https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview)
- Check Terraform logs for detailed error information
