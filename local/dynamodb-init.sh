#!/bin/sh
# Espera o DynamoDB Local responder e cria a tabela do volunteer-service.
set -e
ENDPOINT=http://dynamodb:8000
until aws dynamodb list-tables --endpoint-url "$ENDPOINT" >/dev/null 2>&1; do
  echo "aguardando DynamoDB Local..."; sleep 1
done
aws dynamodb create-table \
  --endpoint-url "$ENDPOINT" \
  --table-name SolidaryTechVolunteers \
  --attribute-definitions AttributeName=volunteer_id,AttributeType=S \
  --key-schema AttributeName=volunteer_id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST >/dev/null 2>&1 || echo "tabela já existe"
echo "tabela SolidaryTechVolunteers pronta"
