# AGIC Installation Guide

After the AKS cluster is created, install AGIC using the following commands:

1. Add the AGIC Helm repository:
   helm repo add application-gateway-kubernetes-ingress https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/
   helm repo update

2. Install AGIC:
   helm install agic application-gateway-kubernetes-ingress/ingress-azure \\
     --namespace agic-system \\
     --create-namespace \\
     --set appgw.applicationGatewayID="/subscriptions/f20b0dac-53ce-44d4-a673-eb1fd36ee03b/resourceGroups/rg-aks-cluster-dev/providers/Microsoft.Network/applicationGateways/appgw-aks-cluster-dev" \\
     --set appgw.subscriptionId="f20b0dac-53ce-44d4-a673-eb1fd36ee03b" \\
     --set appgw.resourceGroup="rg-aks-cluster-dev" \\
     --set appgw.usePrivateIP=false \\
     --set appgw.shared=false \\
     --set armAuth.type=aadPodIdentity \\
     --set armAuth.identityResourceID="/subscriptions/f20b0dac-53ce-44d4-a673-eb1fd36ee03b/resourceGroups/rg-aks-cluster-dev/providers/Microsoft.ManagedIdentity/userAssignedIdentities/identity-aks-aks-cluster-dev" \\
     --set armAuth.identityClientID="00dcc175-8011-47ba-9a29-5142c3e389ca" \\
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
     - host: sample.aks-cluster-dev.local
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
