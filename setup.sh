#!/usr/bin/env bash
set -Eeuo pipefail

CLUSTER_NAME="demo"
IMAGE_NAME="enterprise-bot-demo:1.0.0"
RELEASE_NAME="demo"
CHART_PATH="./chart"

echo "==> Checking required tools"

for cmd in docker kind kubectl helm; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: Required command not found: $cmd" >&2
    exit 1
  fi
done

docker info >/dev/null

if [[ ! -f service/Dockerfile ]]; then
  echo "ERROR: Dockerfile not found in service/" >&2
  exit 1
fi

if [[ ! -f "$CHART_PATH/Chart.yaml" ]]; then
  echo "ERROR: Helm chart not found at $CHART_PATH" >&2
  exit 1
fi

echo "==> Creating kind cluster if needed"

if kind get clusters | grep -Fxq "$CLUSTER_NAME"; then
  echo "Cluster '$CLUSTER_NAME' already exists; reusing it."
else
  kind create cluster 
    --name "$CLUSTER_NAME" 
    --config ./kind-config.yaml
fi

kubectl cluster-info --context "kind-$CLUSTER_NAME"

echo "==> Installing ingress-nginx"

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "==> Waiting for ingress-nginx"

kubectl wait \
  --namespace ingress-nginx \
  --for=jsonpath='{.status.readyReplicas}'=1 \
  deployment/ingress-nginx-controller \
  --timeout=180s

echo "==> Building Docker image"

docker build \
  -t "$IMAGE_NAME" \
  -f service/Dockerfile \
  ./service
  
echo "==> Loading image into kind"

kind load docker-image "$IMAGE_NAME" --name "$CLUSTER_NAME"

echo "==> Validating Helm chart"

helm lint "$CHART_PATH"

echo "==> Creating namespace if needed"

kubectl create namespace demo --dry-run=client -o yaml | kubectl apply -f -

echo "==> Installing or upgrading Helm release"

helm upgrade --install "$RELEASE_NAME" "$CHART_PATH" 
  --namespace demo 
  --wait 
  --timeout 180s

echo "==> Deployment status"

kubectl get deployments,pods,services,ingress -n demo

echo "==> Setup complete"