# Get current Azure client configuration
data "azurerm_client_config" "current" {}

# AGIC will be installed manually using Helm after cluster creation
# The following resources prepare the cluster for AGIC installation

# Create a local file with AGIC installation instructions
resource "local_file" "agic_installation_guide" {
  content = <<-EOT
# AGIC Installation Guide

After the AKS cluster is created, install AGIC using the following commands:

1. Add the AGIC Helm repository:
   helm repo add application-gateway-kubernetes-ingress https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/
   helm repo update

2. Install AGIC:
   helm install agic application-gateway-kubernetes-ingress/ingress-azure \\
     --namespace agic-system \\
     --create-namespace \\
     --set appgw.applicationGatewayID="${azurerm_application_gateway.main.id}" \\
     --set appgw.subscriptionId="${var.subscription_id}" \\
     --set appgw.resourceGroup="${azurerm_resource_group.main.name}" \\
     --set appgw.usePrivateIP=false \\
     --set appgw.shared=false \\
     --set armAuth.type=aadPodIdentity \\
     --set armAuth.identityResourceID="${azurerm_user_assigned_identity.aks.id}" \\
     --set armAuth.identityClientID="${azurerm_user_assigned_identity.aks.client_id}" \\
     --set rbac.enabled=true \\
     --set kubernetes.watchNamespace="" \\
     --set kubernetes.ingressClass="azure/application-gateway"

3. Verify the installation:
   kubectl get pods -n agic-system

4. Check AGIC logs:
   kubectl logs -n agic-system -l app=ingress-azure

5. Create a sample ingress to test AGIC:
   kubectl apply -f - <<EOF
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: sample-app-ingress
     namespace: default
     annotations:
       kubernetes.io/ingress.class: "azure/application-gateway"
       appgw.ingress.kubernetes.io/ssl-redirect: "true"
   spec:
     rules:
     - host: sample.${var.project_name}-${var.environment}.local
       http:
         paths:
         - path: /
           pathType: Prefix
           backend:
             service:
               name: sample-app-service
               port:
                 number: 80
   EOF
EOT

  filename = "${path.module}/agic-installation-guide.md"
}

# Create a sample Kubernetes manifest file for the sample ingress
resource "local_file" "sample_ingress_manifest" {
  content = <<-EOT
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sample-app-ingress
  namespace: default
  annotations:
    kubernetes.io/ingress.class: "azure/application-gateway"
    appgw.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  rules:
  - host: sample.${var.project_name}-${var.environment}.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: sample-app-service
            port:
              number: 80
---
apiVersion: v1
kind: Service
metadata:
  name: sample-app-service
  namespace: default
spec:
  selector:
    app: sample-app
  ports:
  - port: 80
    targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
      - name: sample-app
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
EOT

  filename = "${path.module}/sample-app-manifest.yaml"
}