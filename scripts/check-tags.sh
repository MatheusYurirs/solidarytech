#!/usr/bin/env bash
# Evidência FinOps: lista, via Resource Groups Tagging API, todos os recursos com Project=SolidaryTech.
# Uso: bash scripts/check-tags.sh [regiao]
set -euo pipefail
REGION="${1:-us-east-1}"
aws resourcegroupstaggingapi get-resources --region "$REGION" \
  --tag-filters Key=Project,Values=SolidaryTech \
  --query 'ResourceTagMappingList[].{Recurso:ResourceARN,Environment:Tags[?Key==`Environment`]|[0].Value,CostCenter:Tags[?Key==`CostCenter`]|[0].Value}' \
  --output table
