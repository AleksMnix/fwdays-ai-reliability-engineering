# Lab 02 — Experienced: agentgateway + kagent in Kubernetes

Deploy agentgateway via Helm with `Secret` + `ConfigMap`, then deploy `kagent`
and route a model through agentgateway.

## Prerequisites (inside the Codespace)

```bash
# Create a KinD cluster
kind create cluster --name lab02

# Verify
kubectl cluster-info --context kind-lab02
```

## Step 1 — Install agentgateway via Helm

```bash
cd lab02

# API key from your shell env (never committed)
export GEMINI_API_KEY=<your_key>

helm install agentgateway ./agentgateway-chart \
  --namespace agentgateway --create-namespace \
  --set geminiApiKey=$GEMINI_API_KEY

kubectl -n agentgateway get pods,svc,cm,secret
```

## Step 2 — Verify LLM access

```bash
kubectl -n agentgateway port-forward svc/agentgateway 3000:3000 15000:15000 &

curl http://localhost:3000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemini-flash-latest",
    "messages": [{"role":"user","content":"Hello from Kubernetes!"}]
  }'
```

UI: <http://localhost:15000/ui/>

## Step 3 — Install kagent

```bash
# CLI install
curl https://raw.githubusercontent.com/kagent-dev/kagent/refs/heads/main/scripts/get-kagent | bash

# Deploy kagent with demo profile (includes preloaded agents)
kagent install --profile demo

# Open dashboard
kagent dashboard  # http://localhost:8082
```

## Step 4 — Route kagent through agentgateway

In the kagent UI, configure a model provider pointing at the agentgateway
service (`http://agentgateway.agentgateway.svc.cluster.local:3000`) using
the OpenAI-compatible chat completions endpoint.

## Step 5 — Run a built-in agent

```bash
kagent get agent
kagent invoke -t "What pods are running in the kagent namespace?" --agent k8s-agent
```

## Cleanup

```bash
helm uninstall agentgateway -n agentgateway
kagent uninstall
kind delete cluster --name lab02
```
