#!/usr/bin/env bash
# Provisiona um ambiente: backend S3 -> terraform init -> plan -> (confirmação) -> apply.
# Uso: bash scripts/infra-up.sh primary|standby
# Senha dos bancos: TF_VAR_db_password (se ausente, gera uma e guarda em .secrets/db_password, fora do Git).
set -euo pipefail

ENV_NAME="${1:?Uso: infra-up.sh primary|standby}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="$ROOT/infra/terraform/envs/$ENV_NAME"

bash "$ROOT/scripts/setup-backend.sh" "$ENV_NAME"

mkdir -p "$ROOT/.secrets"
if [ -z "${TF_VAR_db_password:-}" ]; then
  if [ ! -s "$ROOT/.secrets/db_password" ]; then
    # Sem caracteres que o RDS rejeita (/ @ " espaço).
    LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 24 > "$ROOT/.secrets/db_password"
  fi
  export TF_VAR_db_password="$(cat "$ROOT/.secrets/db_password")"
fi

# Standby: pega o ARN do banco primário (réplica cross-region) a partir do state do primary.
if [ "$ENV_NAME" = "standby" ] && [ -z "${TF_VAR_donation_db_source_arn:-}" ]; then
  ARN="$(cd "$ROOT/infra/terraform/envs/primary" && terraform output -raw donation_db_arn 2>/dev/null || true)"
  [ -n "$ARN" ] && export TF_VAR_donation_db_source_arn="$ARN" && echo "✓ Réplica do donation-db a partir de $ARN" \
    || echo "!!! Primary não encontrado: standby subirá com banco vazio (sem réplica)."
fi

cd "$TF_DIR"
terraform init -input=false
terraform validate
terraform plan -out=tfplan -input=false

if [ "${AUTO_APPROVE:-no}" != "yes" ]; then
  read -r -p ">>> ENTER para aplicar em '$ENV_NAME' (Ctrl+C cancela)..."
fi
terraform apply -input=false tfplan
