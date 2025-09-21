#!/bin/bash

# {project} Container Deployment Script
# This script helps build and deploy Docker containers to Azure Container Registry

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="fiscanner"
ACR_NAME="acr${PROJECT_NAME}"
WEB_IMAGE="webapi"
WORKER_IMAGE="worker"

# Default values
ENVIRONMENT="dev"
BUILD_WEB=true
BUILD_WORKER=true
PUSH_IMAGES=true

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

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --environment ENV    Environment to deploy to (dev, test, stage, prod) [default: dev]"
    echo "  -w, --web-only          Build and push only web application"
    echo "  -k, --worker-only       Build and push only worker application"
    echo "  -b, --build-only        Build images only, don't push"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -e prod              # Deploy to production"
    echo "  $0 -w -e stage          # Deploy only web app to staging"
    echo "  $0 -b                   # Build images only"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -w|--web-only)
            BUILD_WEB=true
            BUILD_WORKER=false
            shift
            ;;
        -k|--worker-only)
            BUILD_WEB=false
            BUILD_WORKER=true
            shift
            ;;
        -b|--build-only)
            PUSH_IMAGES=false
            shift
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

# Set image tag based on environment
if [[ "$ENVIRONMENT" == "prod" ]]; then
    IMAGE_TAG="latest"
else
    IMAGE_TAG="$ENVIRONMENT"
fi

print_status "Starting container deployment for environment: $ENVIRONMENT"
print_status "Image tag: $IMAGE_TAG"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install it first."
    exit 1
fi

# Login to Azure Container Registry
print_status "Logging in to Azure Container Registry: $ACR_NAME"
if ! az acr login --name "$ACR_NAME"; then
    print_error "Failed to login to Azure Container Registry"
    exit 1
fi

# Build and push Web Application
if [[ "$BUILD_WEB" == true ]]; then
    print_status "Building Web Application image..."
    
    if [[ -d "../src/WebApi" ]]; then
        cd ../src/WebApi
        
        # Build the image
        docker build -t "${ACR_NAME}.azurecr.io/${WEB_IMAGE}:${IMAGE_TAG}" .
        
        if [[ "$PUSH_IMAGES" == true ]]; then
            print_status "Pushing Web Application image..."
            docker push "${ACR_NAME}.azurecr.io/${WEB_IMAGE}:${IMAGE_TAG}"
        fi
        
        cd ../../iac
    else
        print_warning "WebApi directory not found. Skipping web application build."
    fi
fi

# Build and push Worker Application
if [[ "$BUILD_WORKER" == true ]]; then
    print_status "Building Worker Application image..."
    
    if [[ -d "../src/Worker" ]]; then
        cd ../src/Worker
        
        # Build the image
        docker build -t "${ACR_NAME}.azurecr.io/${WORKER_IMAGE}:${IMAGE_TAG}" .
        
        if [[ "$PUSH_IMAGES" == true ]]; then
            print_status "Pushing Worker Application image..."
            docker push "${ACR_NAME}.azurecr.io/${WORKER_IMAGE}:${IMAGE_TAG}"
        fi
        
        cd ../../iac
    else
        print_warning "Worker directory not found. Skipping worker application build."
    fi
fi

# Show deployment summary
print_status "Deployment completed successfully!"
print_status "Container Registry: ${ACR_NAME}.azurecr.io"
print_status "Environment: $ENVIRONMENT"
print_status "Image Tag: $IMAGE_TAG"

if [[ "$BUILD_WEB" == true ]]; then
    print_status "Web Application: ${ACR_NAME}.azurecr.io/${WEB_IMAGE}:${IMAGE_TAG}"
fi

if [[ "$BUILD_WORKER" == true ]]; then
    print_status "Worker Application: ${ACR_NAME}.azurecr.io/${WORKER_IMAGE}:${IMAGE_TAG}"
fi

if [[ "$PUSH_IMAGES" == true ]]; then
    print_status "Images have been pushed to the registry."
    print_status "App Services will automatically pull the new images."
else
    print_status "Images have been built locally. Use -p flag to push them."
fi
