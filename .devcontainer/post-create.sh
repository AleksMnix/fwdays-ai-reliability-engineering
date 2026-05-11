#!/usr/bin/env bash
set -euo pipefail

ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ARCH=amd64 ;;
  aarch64|arm64) ARCH=arm64 ;;
  *) echo "Unsupported arch: $ARCH"; exit 1 ;;
esac

# KinD
if ! command -v kind >/dev/null; then
  curl -fsSLo /tmp/kind "https://kind.sigs.k8s.io/dl/latest/kind-linux-${ARCH}"
  sudo install -m 0755 /tmp/kind /usr/local/bin/kind
  rm /tmp/kind
fi

# k9s
if ! command -v k9s >/dev/null; then
  K9S_VERSION=$(curl -fsSL https://api.github.com/repos/derailed/k9s/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
  curl -fsSLo /tmp/k9s.tar.gz "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_${ARCH}.tar.gz"
  tar -xzf /tmp/k9s.tar.gz -C /tmp k9s
  sudo install -m 0755 /tmp/k9s /usr/local/bin/k9s
  rm /tmp/k9s.tar.gz /tmp/k9s
fi

# Flux CLI
if ! command -v flux >/dev/null; then
  curl -fsSL https://fluxcd.io/install.sh | sudo bash
fi

# OpenTofu
if ! command -v tofu >/dev/null; then
  TOFU_VERSION=$(curl -fsSL https://api.github.com/repos/opentofu/opentofu/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | tr -d v)
  curl -fsSLo /tmp/tofu.tar.gz "https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_linux_${ARCH}.tar.gz"
  tar -xzf /tmp/tofu.tar.gz -C /tmp tofu
  sudo install -m 0755 /tmp/tofu /usr/local/bin/tofu
  rm /tmp/tofu.tar.gz /tmp/tofu
fi

# cloud-provider-kind (Go is provided by the devcontainer feature)
if ! command -v cloud-provider-kind >/dev/null; then
  go install sigs.k8s.io/cloud-provider-kind@latest
fi

echo "✓ Dev environment ready: $(kind version 2>/dev/null | head -1), k9s $(k9s version -s 2>/dev/null | head -1), tofu $(tofu version 2>/dev/null | head -1), flux $(flux --version 2>/dev/null)"
