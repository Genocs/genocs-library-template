#!/bin/bash

# AKS Infrastructure Deployment Script
# This script deploys the complete AKS infrastructure with AGIC

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    print_error "terraform.tfvars file not found!"
    print_status "Please copy terraform.tfvars.example to terraform.tfvars and customize the values"
    exit 1
fi

# Check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform >= 1.12.2"
        exit 1
    fi
    
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed. Please install Azure CLI"
        exit 1
    fi
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl"
        exit 1
    fi
    
    if ! command -v helm &> /dev/null; then
        print_error "Helm is not installed. Please install Helm"
        exit 1
    fi
    
    print_success "All prerequisites are installed"
}

# Check Azure CLI login
check_azure_login() {
    print_status "Checking Azure CLI login..."
    
    if ! az account show &> /dev/null; then
        print_error "Not logged in to Azure CLI. Please run 'az login'"
        exit 1
    fi
    
    print_success "Azure CLI is logged in"
}

# Initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    terraform init
    print_success "Terraform initialized"
}

# Plan Terraform deployment
plan_terraform() {
    print_status "Planning Terraform deployment..."
    terraform plan -out=tfplan
    print_success "Terraform plan completed"
}

# Apply Terraform deployment
apply_terraform() {
    print_status "Applying Terraform deployment..."
    terraform apply tfplan
    print_success "Terraform deployment completed"
}

# Get AKS credentials
get_aks_credentials() {
    print_status "Getting AKS credentials..."
    
    # Get resource group and cluster name from terraform output
    RG_NAME=$(terraform output -raw resource_group_name 2>/dev/null || echo "")
    CLUSTER_NAME=$(terraform output -raw aks_cluster_name 2>/dev/null || echo "")
    
    if [ -z "$RG_NAME" ] || [ -z "$CLUSTER_NAME" ]; then
        print_warning "Could not get resource group or cluster name from terraform output"
        print_status "Please run: az aks get-credentials --resource-group <rg-name> --name <cluster-name>"
    else
        az aks get-credentials --resource-group "$RG_NAME" --name "$CLUSTER_NAME" --overwrite-existing
        print_success "AKS credentials configured"
    fi
}

# Verify deployment
verify_deployment() {
    print_status "Verifying deployment..."
    
    # Check if kubectl can connect to the cluster
    if kubectl cluster-info &> /dev/null; then
        print_success "Kubernetes cluster is accessible"
        
        # Check AGIC pods
        print_status "Checking AGIC pods..."
        if kubectl get pods -n agic-system &> /dev/null; then
            print_success "AGIC namespace exists"
            kubectl get pods -n agic-system
        else
            print_warning "AGIC namespace not found or no pods running"
        fi
        
        # Check node pools
        print_status "Checking node pools..."
        kubectl get nodes --show-labels
        
    else
        print_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
}

# Display connection information
display_connection_info() {
    print_status "Deployment completed successfully!"
    echo ""
    print_status "Connection Information:"
    echo "=========================="
    
    # Get outputs
    APP_GW_IP=$(terraform output -raw application_gateway_public_ip 2>/dev/null || echo "N/A")
    APP_GW_FQDN=$(terraform output -raw application_gateway_fqdn 2>/dev/null || echo "N/A")
    KEY_VAULT_URI=$(terraform output -raw key_vault_uri 2>/dev/null || echo "N/A")
    
    echo "Application Gateway Public IP: $APP_GW_IP"
    echo "Application Gateway FQDN: $APP_GW_FQDN"
    echo "Key Vault URI: $KEY_VAULT_URI"
    echo ""
    
    print_status "Next Steps:"
    echo "1. Install AGIC using the instructions in agic-installation-guide.md"
    echo "2. Deploy your applications to the cluster"
    echo "3. Create ingress resources with the annotation: kubernetes.io/ingress.class: 'azure/application-gateway'"
    echo "4. Configure DNS to point to the Application Gateway public IP"
    echo "5. Upload SSL certificates to Application Gateway for HTTPS"
    echo "6. Access Key Vault secrets from your applications using Workload Identity"
    echo ""
    
    print_status "Useful Commands:"
    echo "kubectl get pods -n agic-system  # Check AGIC status"
    echo "kubectl get ingress              # List ingress resources"
    echo "az network application-gateway show --name <appgw-name> --resource-group <rg-name>  # Check App Gateway"
    echo "az keyvault secret list --vault-name <key-vault-name>  # List Key Vault secrets"
}

# Main execution
main() {
    print_status "Starting AKS infrastructure deployment..."
    echo ""
    
    check_prerequisites
    check_azure_login
    init_terraform
    plan_terraform
    
    # Ask for confirmation before applying
    echo ""
    print_warning "This will create Azure resources that may incur costs."
    read -p "Do you want to continue with the deployment? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        apply_terraform
        get_aks_credentials
        verify_deployment
        display_connection_info
    else
        print_status "Deployment cancelled by user"
        exit 0
    fi
}

# Run main function
main "$@"
