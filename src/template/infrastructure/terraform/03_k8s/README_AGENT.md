## 🎉 Complete AKS Infrastructure with AGIC

I've created a comprehensive Terraform infrastructure that includes all the components you requested:

### 📁 **Files Created/Updated:**

1. **`variables.tf`** - Complete variable definitions for all components
2. **`network.tf`** - VNET, subnets, NAT Gateway, and Network Security Groups
3. **`aks.tf`** - AKS cluster with multiple node pools (system, user, spot)
4. **`application_gateway.tf`** - Application Gateway with WAF and SSL
5. **`agic.tf`** - AGIC (Application Gateway Ingress Controller) configuration
6. **`output.tf`** - Comprehensive outputs for all resources
7. **`providers.tf`** - Updated with required providers (Kubernetes, Helm, TLS)
8. **`terraform.tfvars.example`** - Example configuration file
9. **`README.md`** - Complete documentation
10. **`deploy.sh`** - Automated deployment script

### 🏗️ **Infrastructure Components:**

#### **Network Infrastructure:**

- **Virtual Network**: `10.0.0.0/16` address space
- **AKS Subnet**: `10.0.1.0/24` for AKS nodes
- **Application Gateway Subnet**: `10.0.2.0/24` for App Gateway
- **NAT Gateway Subnet**: `10.0.3.0/24` for outbound connectivity
- **NAT Gateway**: Provides secure outbound internet access
- **Network Security Groups**: Proper traffic filtering rules

#### **AKS Cluster:**

- **Kubernetes Version**: 1.33.0
- **Network Plugin**: Azure CNI
- **Network Policy**: Azure
- **Node Pools**:
  - **System Pool**: Standard_D2s_v3, auto-scaling (1-5 nodes)
  - **User Pool**: Standard_D4s_v3, auto-scaling (1-10 nodes)
  - **Spot Pool**: Standard_D2s_v3, spot instances for cost optimization
- **Security Features**: RBAC, Azure Policy, Workload Identity, OIDC Issuer

#### **Application Gateway:**

- **SKU**: Standard_v2
- **Capacity**: 2 instances with auto-scaling
- **WAF**: Enabled with OWASP 3.2 ruleset
- **SSL**: Self-signed certificate for initial setup
- **Health Probes**: Configured for backend health checks

#### **AGIC (Application Gateway Ingress Controller):**

- **Version**: 1.6.0
- **Namespace**: agic-system
- **Authentication**: Azure Pod Identity
- **Features**: SSL termination, path-based routing, health probes
- **Sample Ingress**: Included for testing

#### **Monitoring & Security:**

- **Log Analytics Workspace**: For AKS monitoring
- **Managed Identities**: For secure authentication
- **Role Assignments**: Proper permissions for AGIC
- **Network Security Groups**: Traffic filtering

### �� **Quick Start:**

1. **Navigate to the directory:**

   ```bash
   cd infrastructure/terraform/02_k8s
   ```

2. **Copy and customize variables:**

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Deploy **

   ```bash
   # using the script:
   ./deploy.sh
   # Or manually:
   terraform init
   terraform plan
   terraform apply
   ```

4. **Get AKS credentials:**
   ```bash
   az aks get-credentials --resource-group <rg-name> --name <cluster-name>
   ```

### 🔧 **Key Features:**

- **Production-Ready**: Includes security, monitoring, and best practices
- **Cost-Optimized**: Spot instances and auto-scaling
- **Secure**: NAT Gateway, NSGs, RBAC, and proper authentication
- **Scalable**: Multiple node pools with auto-scaling
- **Well-Documented**: Comprehensive README and inline comments
- **Automated**: Deployment script with validation

### 📊 **Outputs Available:**

The infrastructure provides detailed outputs for:

- Resource Group information
- Virtual Network and subnet details
- AKS cluster configuration
- Application Gateway details
- Managed Identity information
- Connection information for kubectl and Application Gateway

### �� **Next Steps:**

1. **Deploy applications** using the AGIC ingress class
2. **Configure DNS** to point to the Application Gateway public IP
3. **Upload SSL certificates** for HTTPS
4. **Monitor** using the Log Analytics workspace

This infrastructure follows Azure best practices and provides a solid foundation for running containerized applications with proper ingress management through AGIC.

I'll add a Key Vault setup to the AKS infrastructure. This will be useful for storing secrets, certificates, and other sensitive information that the AKS cluster and applications might need.

Perfect! Now let me create a summary of what we've accomplished with the Key Vault integration:

## 🎉 Key Vault Integration Complete!

I've successfully added a comprehensive Key Vault setup to your AKS infrastructure. Here's what has been added:

### 🔐 **Key Vault Features Added:**

#### **1. Key Vault Configuration (`key_vault.tf`):**

- **Standard SKU** Key Vault with RBAC authorization
- **Soft Delete** enabled with 90-day retention
- **Purge Protection** enabled for security
- **Network ACLs** configurable for access control
- **Access Policies** for both RBAC and traditional access control modes

#### **2. Pre-configured Secrets:**

- **AKS Kubeconfig** - Cluster configuration
- **Application Gateway Public IP** - Gateway endpoint
- **Log Analytics Workspace ID** - Monitoring workspace
- **Database Connection String** - Sample database connection
- **API Key** - Sample API key for external services

#### **3. Certificates & Keys:**

- **SSL Certificate** for Application Gateway with auto-renewal
- **Encryption Key** for data protection
- **Certificate Management** with proper subject alternative names

#### **4. Access Control:**

- **RBAC Integration** with AKS and Application Gateway identities
- **Key Vault Secrets User** role for managed identities
- **Key Vault Administrator** role for current user
- **Fallback Access Policies** when RBAC is disabled

#### **5. Updated Configuration Files:**

- **`variables.tf`** - Added Key Vault configuration variables
- **`output.tf`** - Added comprehensive Key Vault outputs
- **`terraform.tfvars.example`** - Added Key Vault variables
- **`README.md`** - Updated documentation with Key Vault information
- **`deploy.sh`** - Updated deployment script with Key Vault commands

### 🔧 **Key Vault Variables Available:**

| Variable                               | Description             | Default      |
| -------------------------------------- | ----------------------- | ------------ |
| `key_vault_sku_name`                   | Key Vault SKU           | `standard`   |
| `key_vault_enable_rbac_authorization`  | Enable RBAC             | `true`       |
| `key_vault_enable_soft_delete`         | Enable soft delete      | `true`       |
| `key_vault_soft_delete_retention_days` | Retention period        | `90`         |
| `key_vault_enable_purge_protection`    | Enable purge protection | `true`       |
| `key_vault_network_acls`               | Network access control  | Configurable |

### �� **Key Vault Outputs Available:**

- **Key Vault Details**: Name, ID, URI, location, configuration
- **Secrets Information**: All pre-configured secrets with IDs
- **Certificates Information**: SSL certificate details and thumbprint
- **Keys Information**: Encryption key details and configuration

### 🚀 **Usage Examples:**

#### **Access Key Vault from Applications:**

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

#### **Use Key Vault Secrets in Pods:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
  labels:
    azure.workload.identity/use: "true"
spec:
  serviceAccountName: my-app-sa
  containers:
    - name: my-app
      image: my-app:latest
      env:
        - name: DATABASE_CONNECTION_STRING
          value: "https://kv-<project>-<env>.vault.azure.net/secrets/database-connection-string"
```

### 🔒 **Security Features:**

- **RBAC Authorization** for modern access control
- **Soft Delete** with configurable retention
- **Purge Protection** to prevent accidental deletion
- **Network ACLs** for IP and subnet-based access control
- **Managed Identity Integration** for secure pod access
- **Certificate Auto-renewal** for SSL certificates

### �� **Next Steps:**

1. **Deploy the infrastructure** using `./deploy.sh`
2. **Install AGIC** using the generated installation guide
3. **Access Key Vault secrets** from your applications using Workload Identity
4. **Upload production SSL certificates** to replace the self-signed ones
5. **Configure network ACLs** if you need restricted access

The Key Vault is now fully integrated with your AKS infrastructure and provides a secure, scalable solution for managing secrets, certificates, and keys for your applications!

## 📋 **Current Network Configuration (No Overlaps)**

| Component          | CIDR Range      | IP Range                    |
| ------------------ | --------------- | --------------------------- |
| VNet               | `10.0.0.0/16`   | 10.0.0.0 - 10.0.255.255     |
| AKS Subnet         | `10.0.1.0/24`   | 10.0.1.0 - 10.0.1.255       |
| App Gateway Subnet | `10.0.2.0/24`   | 10.0.2.0 - 10.0.2.255       |
| NAT Gateway Subnet | `10.0.3.0/24`   | 10.0.3.0 - 10.0.3.255       |
| **Service CIDR**   | `10.1.0.0/16`   | 10.1.0.0 - 10.1.255.255     |
| **DNS Service IP** | `10.1.0.10`     | Within service CIDR         |
| Pod CIDR           | `10.244.0.0/16` | 10.244.0.0 - 10.244.255.255 |

Now I can calculate the current vCPU usage:

**Current vCPU Usage:**

- **System node pool:** 2 nodes × 2 vCPUs (Standard_D2s_v3) = **4 vCPUs**
- **User node pool:** 2 nodes × 4 vCPUs (Standard_D4s_v3) = **8 vCPUs** ← **This exceeds quota!**
- **Spot node pool:** 1 node × 2 vCPUs (Standard_D2s_v3) = **2 vCPUs**
- **Total:** 4 + 8 + 2 = **14 vCPUs** (but only 6 available)

## ✅ **Updated vCPU Configuration (Within Quota)**

**New vCPU Usage:**

- **System node pool:** 2 nodes × 2 vCPUs (Standard_B2s) = **4 vCPUs**
- **User node pool:** 1 node × 2 vCPUs (Standard_B2s) = **2 vCPUs**
- **Spot node pool:** 0 nodes × 1 vCPU (Standard_B1s) = **0 vCPUs**
- **Total:** 4 + 2 + 0 = **6 vCPUs** ✅ **Exactly within quota limit!**

### **VM Size Comparison:**

| VM Size         | vCPUs | RAM  | Previous Usage | New Usage            |
| --------------- | ----- | ---- | -------------- | -------------------- |
| Standard_D2s_v3 | 2     | 8GB  | System pool    | -                    |
| Standard_D4s_v3 | 4     | 16GB | User pool      | -                    |
| Standard_B2s    | 2     | 4GB  | -              | System + User pools  |
| Standard_B1s    | 1     | 2GB  | -              | Spot pool (disabled) |

### **Total vCPU Usage: 6 vCPUs** ✅ **Within quota limit**

### **Updated Configuration:**

```hcl
# Spot node pool upgrade settings
upgrade_settings {
  max_surge = "0"  # ← Changed from "33%" to "0"
}
```

### **Current Node Pool Configuration Summary:**

| Node Pool  | VM Size      | Node Count | Upgrade Strategy    |
| ---------- | ------------ | ---------- | ------------------- |
| **System** | Standard_B2s | 2 nodes    | `max_surge = "33%"` |
| **User**   | Standard_B2s | 1 node     | `max_surge = "33%"` |
| **Spot**   | Standard_B1s | 0 nodes    | `max_surge = "0"`   |

### **Updated Spot Node Pool Configuration:**

```hcl
resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name                  = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_B1s"
  node_count            = var.enable_auto_scaling ? null : 0
  min_count             = var.enable_auto_scaling ? 0 : null
  max_count             = var.enable_auto_scaling ? 2 : null
  vnet_subnet_id        = azurerm_subnet.aks.id
  os_disk_size_gb       = 128
  os_disk_type          = "Managed"
  os_type               = "Linux"
  zones                 = ["1", "2", "3"]
  priority              = "Spot"
  eviction_policy       = "Delete"
  spot_max_price        = 0.1

  node_labels = {
    "node-type" = "spot"
  }

  node_taints = [
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ]

  # No upgrade_settings block - spot pools don't support it
  tags = var.tags
}
```

### **Current Node Pool Configuration Summary:**

| Node Pool  | VM Size      | Node Count | Upgrade Settings    |
| ---------- | ------------ | ---------- | ------------------- |
| **System** | Standard_B2s | 2 nodes    | `max_surge = "33%"` |
| **User**   | Standard_B2s | 1 node     | `max_surge = "33%"` |
| **Spot**   | Standard_B1s | 0 nodes    | **None (default)**  |

**Updated vCPU Usage:**

- **System node pool:** 2 nodes × 2 vCPUs (Standard_B2s) = **4 vCPUs**
- **User node pool:** 1 node × 2 vCPUs (Standard_B2s) = **2 vCPUs**
- **Spot node pool:** 0 nodes × 2 vCPUs (Standard_B2s) = **0 vCPUs**
- **Total:** 4 + 2 + 0 = **6 vCPUs** ✅ **Still within quota limit!**

### **Updated vCPU Configuration:**

| Node Pool  | VM Size      | Node Count | vCPUs per Node | Total vCPUs    |
| ---------- | ------------ | ---------- | -------------- | -------------- |
| **System** | Standard_B2s | 2 nodes    | 2 vCPUs        | **4 vCPUs**    |
| **User**   | Standard_B2s | 1 node     | 2 vCPUs        | **2 vCPUs**    |
| **Spot**   | Standard_B2s | 0 nodes    | 2 vCPUs        | **0 vCPUs**    |
| **Total**  |              |            |                | **6 vCPUs** ✅ |

### **Current Spot Node Pool Configuration:**

```hcl
resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name                  = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_B2s"  # ← Changed from Standard_B1s
  node_count            = var.enable_auto_scaling ? null : 0
  min_count             = var.enable_auto_scaling ? 0 : null
  max_count             = var.enable_auto_scaling ? 2 : null
  # ... rest of configuration
}
```

### **SKU Comparison:**

| Feature                      | Standard_v2 | WAF_v2 |
| ---------------------------- | ----------- | ------ |
| **Load Balancing**           | ✅          | ✅     |
| **SSL Termination**          | ✅          | ✅     |
| **URL-based Routing**        | ✅          | ✅     |
| **Web Application Firewall** | ❌          | ✅     |
| **DDoS Protection**          | ✅          | ✅     |
| **Autoscaling**              | ✅          | ✅     |

### **Current Application Gateway Configuration:**

- **SKU:** WAF_v2 (supports WAF)
- **WAF:** Enabled with OWASP 3.2 rules
- **Scaling:** Autoscale (min: 2, max: 10 instances)
- **Firewall Mode:** Detection
- **Listeners:** HTTP (port 80) and HTTPS (port 443) ready

### **WAF Configuration:**

```hcl
waf_configuration {
  enabled                  = true
  firewall_mode            = "Detection"
  rule_set_type            = "OWASP"
  rule_set_version         = "3.2"
  request_body_check       = true
  max_request_body_size_kb = 128
  file_upload_limit_mb     = 100
}
```

### **Current Application Gateway NSG Rules:**

| Rule Name                     | Priority | Direction | Ports       | Source     | Purpose                 |
| ----------------------------- | -------- | --------- | ----------- | ---------- | ----------------------- |
| **AllowHTTPInbound**          | 100      | Inbound   | 80          | Internet   | HTTP traffic            |
| **AllowHTTPSInbound**         | 110      | Inbound   | 443         | Internet   | HTTPS traffic           |
| **AllowAKSInbound**           | 120      | Inbound   | 65200-65535 | AKS Subnet | AKS communication       |
| **AllowInternetHealthProbes** | 130      | Inbound   | 65200-65535 | Internet   | **AG v2 health probes** |
| **AllowAKSOutbound**          | 100      | Outbound  | \*          | AKS Subnet | Backend communication   |

### **Why This Fix Works:**

- **Application Gateway v2 Requirements:** AG v2 SKU requires ports 65200-65535 to be accessible from the internet for health probes
- **Health Probe Communication:** These ports are used by Azure's load balancer to perform health checks on backend services
- **Backend Communication:** Required for proper communication between Application Gateway and AKS backend services
