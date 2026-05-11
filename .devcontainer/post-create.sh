#!/usr/bin/env bash
set -euo pipefail

# KinD
curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x /usr/local/bin/kind

# k9s
K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d'"' -f4)
curl -Lo /tmp/k9s.tar.gz "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
tar -xzf /tmp/k9s.tar.gz -C /usr/local/bin k9s
chmod +x /usr/local/bin/k9s

# Flux CLI
curl -s https://fluxcd.io/install.sh | bash

# OpenTofu
TOFU_VERSION=$(curl -s https://api.github.com/repos/opentofu/opentofu/releases/latest | grep tag_name | cut -d'"' -f4 | tr -d v)
curl -Lo /tmp/tofu.tar.gz "https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_linux_amd64.tar.gz"
tar -xzf /tmp/tofu.tar.gz -C /usr/local/bin tofu
chmod +x /usr/local/bin/tofu

# cloud-provider-kind
go install sigs.k8s.io/cloud-provider-kind@latest

echo "Dev environment ready."
