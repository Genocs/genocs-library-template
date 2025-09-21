#!/bin/bash

# Fiscanner Monitoring Setup Script
# This script helps configure monitoring and alerting after infrastructure deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="fiscanner"
ENVIRONMENT="dev"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}[SETUP]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --environment ENV    Environment to configure (dev, test, stage, prod) [default: dev]"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "This script helps configure monitoring and alerting for the Fiscanner infrastructure."
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|test|stage|prod)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT"
    print_error "Valid environments: dev, test, stage, prod"
    exit 1
fi

print_header "Setting up monitoring for Fiscanner - $ENVIRONMENT environment"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if user is logged in
if ! az account show &> /dev/null; then
    print_error "Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

print_status "Getting resource information..."

# Get resource group name
RESOURCE_GROUP="gnx-${PROJECT_NAME}-${ENVIRONMENT}-rg"
print_status "Resource Group: $RESOURCE_GROUP"

# Get Log Analytics Workspace name
LAW_NAME="gnx-${PROJECT_NAME}-law"
print_status "Log Analytics Workspace: $LAW_NAME"

# Get Application Insights name
APP_INSIGHTS_NAME="gnx-${PROJECT_NAME}-${ENVIRONMENT}-ai"
print_status "Application Insights: $APP_INSIGHTS_NAME"

# Verify resources exist
print_status "Verifying resources exist..."

if ! az group show --name "$RESOURCE_GROUP" &> /dev/null; then
    print_error "Resource group $RESOURCE_GROUP not found. Please deploy the infrastructure first."
    exit 1
fi

if ! az monitor log-analytics workspace show --resource-group "$RESOURCE_GROUP" --workspace-name "$LAW_NAME" &> /dev/null; then
    print_error "Log Analytics Workspace $LAW_NAME not found. Please deploy the infrastructure first."
    exit 1
fi

if ! az monitor app-insights component show --resource-group "$RESOURCE_GROUP" --app "$APP_INSIGHTS_NAME" &> /dev/null; then
    print_error "Application Insights $APP_INSIGHTS_NAME not found. Please deploy the infrastructure first."
    exit 1
fi

print_status "All resources verified successfully!"

# Get workspace ID
WORKSPACE_ID=$(az monitor log-analytics workspace show --resource-group "$RESOURCE_GROUP" --workspace-name "$LAW_NAME" --query "customerId" -o tsv)
print_status "Log Analytics Workspace ID: $WORKSPACE_ID"

# Get Application Insights instrumentation key
INSTRUMENTATION_KEY=$(az monitor app-insights component show --resource-group "$RESOURCE_GROUP" --app "$APP_INSIGHTS_NAME" --query "instrumentationKey" -o tsv)
print_status "Application Insights Instrumentation Key: $INSTRUMENTATION_KEY"

print_header "Creating sample monitoring queries..."

# Create a queries file
QUERIES_FILE="monitoring-queries-${ENVIRONMENT}.kusto"
cat > "$QUERIES_FILE" << 'EOF'
// Fiscanner Monitoring Queries for ENVIRONMENT
// Replace ENVIRONMENT with your actual environment name

// 1. Container Performance Monitoring
ContainerInsights
| where TimeGenerated > ago(1h)
| where Computer contains "gnx-fiscanner-ENVIRONMENT"
| summarize avg(CPUUsagePercent) by Computer, bin(TimeGenerated, 5m)
| render timechart

// 2. Application Errors
exceptions
| where timestamp > ago(24h)
| where cloud_RoleName contains "gnx-fiscanner-ENVIRONMENT"
| summarize count() by type, bin(timestamp, 1h)
| render timechart

// 3. App Service Response Times
requests
| where timestamp > ago(1h)
| where cloud_RoleName contains "gnx-fiscanner-ENVIRONMENT"
| summarize avg(duration) by cloud_RoleName, bin(timestamp, 5m)
| render timechart

// 4. Storage Account Operations
AzureDiagnostics
| where ResourceType == "STORAGEACCOUNTS"
| where Resource contains "gnxfiscannerENVIRONMENTst"
| where OperationName in ("GetBlob", "PutBlob", "DeleteBlob")
| summarize count() by OperationName, bin(TimeGenerated, 1h)
| render timechart

// 5. Service Bus Activity
AzureDiagnostics
| where ResourceType == "SERVICEBUS"
| where Resource contains "gnxfiscannerENVIRONMENTservicebus"
| summarize count() by OperationName, bin(TimeGenerated, 1h)
| render timechart

// 6. Key Vault Access
AzureDiagnostics
| where ResourceType == "VAULTS"
| where Resource contains "gnx-fiscanner-ENVIRONMENT-kv"
| where OperationName == "SecretGet"
| summarize count() by bin(TimeGenerated, 1h)
| render timechart

// 7. Redis Cache Performance
AzureDiagnostics
| where ResourceType == "REDIS"
| where Resource contains "gnx-fiscanner-ENVIRONMENT-redis"
| summarize count() by OperationName, bin(TimeGenerated, 1h)
| render timechart
EOF

# Replace ENVIRONMENT placeholder
sed -i "s/ENVIRONMENT/$ENVIRONMENT/g" "$QUERIES_FILE"

print_status "Created monitoring queries file: $QUERIES_FILE"

print_header "Setting up diagnostic settings..."

# Configure diagnostic settings for App Services
print_status "Configuring diagnostic settings for App Services..."

# Web App diagnostic settings
az monitor diagnostic-settings create \
    --name "gnx-${PROJECT_NAME}-${ENVIRONMENT}-web-diagnostics" \
    --resource "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/gnx-${PROJECT_NAME}-${ENVIRONMENT}-app" \
    --workspace "$WORKSPACE_ID" \
    --logs '[{"category": "AppServiceHTTPLogs", "enabled": true}, {"category": "AppServiceConsoleLogs", "enabled": true}, {"category": "AppServiceAppLogs", "enabled": true}, {"category": "AppServiceAuditLogs", "enabled": true}, {"category": "AppServiceIPSecAuditLogs", "enabled": true}, {"category": "AppServicePlatformLogs", "enabled": true}]' \
    --metrics '[{"category": "AllMetrics", "enabled": true}]'

# Worker App diagnostic settings
az monitor diagnostic-settings create \
    --name "gnx-${PROJECT_NAME}-${ENVIRONMENT}-worker-diagnostics" \
    --resource "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/gnx-${PROJECT_NAME}-${ENVIRONMENT}-worker" \
    --workspace "$WORKSPACE_ID" \
    --logs '[{"category": "AppServiceHTTPLogs", "enabled": true}, {"category": "AppServiceConsoleLogs", "enabled": true}, {"category": "AppServiceAppLogs", "enabled": true}, {"category": "AppServiceAuditLogs", "enabled": true}, {"category": "AppServiceIPSecAuditLogs", "enabled": true}, {"category": "AppServicePlatformLogs", "enabled": true}]' \
    --metrics '[{"category": "AllMetrics", "enabled": true}]'

print_header "Setting up basic alert rules..."

# Create a basic alert rule for high CPU usage
print_status "Creating CPU usage alert rule..."
az monitor metrics alert create \
    --name "gnx-${PROJECT_NAME}-${ENVIRONMENT}-high-cpu" \
    --resource-group "$RESOURCE_GROUP" \
    --scopes "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/gnx-${PROJECT_NAME}-${ENVIRONMENT}-app" \
    --condition "avg Percentage CPU > 80" \
    --window-size "PT5M" \
    --evaluation-frequency "PT1M" \
    --action "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Insights/actionGroups/gnx-${PROJECT_NAME}-action-group" \
    --description "Alert when CPU usage exceeds 80% for 5 minutes" \
    --severity 2

# Create a basic alert rule for high memory usage
print_status "Creating memory usage alert rule..."
az monitor metrics alert create \
    --name "gnx-${PROJECT_NAME}-${ENVIRONMENT}-high-memory" \
    --resource-group "$RESOURCE_GROUP" \
    --scopes "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/gnx-${PROJECT_NAME}-${ENVIRONMENT}-app" \
    --condition "avg Memory Percentage > 80" \
    --window-size "PT5M" \
    --evaluation-frequency "PT1M" \
    --action "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Insights/actionGroups/gnx-${PROJECT_NAME}-action-group" \
    --description "Alert when memory usage exceeds 80% for 5 minutes" \
    --severity 2

print_header "Monitoring setup completed successfully!"

print_status "Next steps:"
echo "1. Open the Log Analytics Workspace in Azure Portal:"
echo "   https://portal.azure.com/#@$(az account show --query tenantId -o tsv)/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/$LAW_NAME"
echo ""
echo "2. Use the queries in $QUERIES_FILE to create custom dashboards"
echo ""
echo "3. Open Application Insights:"
echo "   https://portal.azure.com/#@$(az account show --query tenantId -o tsv)/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Insights/components/$APP_INSIGHTS_NAME"
echo ""
echo "4. Configure additional alert rules based on your requirements"
echo ""
echo "5. Set up custom dashboards for team visibility"

print_status "Monitoring setup for $ENVIRONMENT environment completed!"
