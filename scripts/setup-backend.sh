#!/usr/bin/env bash
# Cria (se não existir) o bucket S3 do state Terraform e gera infra/terraform/envs/<env>/backend.tf.
# Cada região tem o SEU bucket: o state do standby não fica refém da região primária (DR).
#
# Uso: bash scripts/setup-backend.sh primary|standby
set -euo pipefail

ENV_NAME="${1:?Uso: setup-backend.sh primary|standby}"
case "$ENV_NAME" in
  primary) REGION="us-east-1" ;;
  standby) REGION="us-west-2" ;;
  *) echo "!!! Ambiente inválido: $ENV_NAME"; exit 1 ;;
esac

aws sts get-caller-identity >/dev/null 2>&1 || { echo "!!! Sessão AWS inválida. Renove o AWS Academy (aws configure)."; exit 1; }
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
BUCKET="solidarytech-tfstate-${ACCOUNT_ID}-${REGION}"

if aws s3api head-bucket --bucket "$BUCKET" >/dev/null 2>&1; then
  echo "✓ Bucket já existe: $BUCKET"
else
  echo ">>> Criando bucket $BUCKET ($REGION)"
  if [ "$REGION" = "us-east-1" ]; then
    aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" >/dev/null
  else
    aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" \
      --create-bucket-configuration LocationConstraint="$REGION" >/dev/null
  fi
fi

aws s3api put-bucket-versioning --bucket "$BUCKET" --versioning-configuration Status=Enabled
aws s3api put-public-access-block --bucket "$BUCKET" --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
# Tags FinOps também no bucket criado fora do Terraform.
aws s3api put-bucket-tagging --bucket "$BUCKET" --tagging \
  'TagSet=[{Key=Project,Value=SolidaryTech},{Key=Environment,Value=Production},{Key=CostCenter,Value=NGO-Core},{Key=Purpose,Value=terraform-state}]'

DIR="$(cd "$(dirname "$0")/.." && pwd)/infra/terraform/envs/${ENV_NAME}"
cat > "$DIR/backend.tf" <<EOF
terraform {
  backend "s3" {
    bucket       = "${BUCKET}"
    key          = "${ENV_NAME}/terraform.tfstate"
    region       = "${REGION}"
    use_lockfile = true
  }
}
EOF
echo "✓ backend.tf gerado em $DIR"
