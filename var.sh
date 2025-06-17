kubectl create namespace var || true
kubectl apply -f config-configmap.yaml -n var
for file in configmaps/*; do kubectl apply -f $file -n var; done
kubectl apply -f vectra-automated-response-deployment.yaml -n var