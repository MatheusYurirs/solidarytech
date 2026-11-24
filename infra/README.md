# Infraestrutura (Terraform)

```
infra/terraform/
├── modules/
│   ├── network/    VPC, 2 subnets públicas + 2 privadas, IGW, 1 NAT
│   ├── eks/        cluster + node group (LabRole do Academy, IMDSv2)
│   ├── rds/        PostgreSQL (SG próprio, criptografado, suporta réplica cross-region)
│   ├── dynamodb/   SolidaryTechVolunteers (PITR ligado)
│   ├── sqs/        fila de doações + DLQ
│   ├── ecr/        3 repositórios + lifecycle + replicação p/ DR
│   └── platform/   COMPOSIÇÃO: junta tudo. Primary e standby usam o mesmo módulo.
└── envs/
    ├── primary/    us-east-1
    └── standby/    us-west-2 (Warm Standby, capacidade mínima)
```

## Comandos
```bash
bash scripts/infra-up.sh primary     # backend S3 + init + plan + (ENTER) apply
bash scripts/dr-standby-up.sh        # DR: sobe o espelho em us-west-2 com 1 comando
bash scripts/check-tags.sh           # evidência FinOps: recursos com Project=SolidaryTech
```

## Decisões
| Decisão | Motivo |
|---|---|
| Tags via `default_tags` + validação em `platform/variables.tf` | Impossível aplicar sem `Project/Environment/CostCenter` corretos (FinOps, PDF p.4) |
| Tags também no launch template | `default_tags` não chegam nas EC2 do node group |
| LabRole via `data "aws_iam_role"` | Academy não permite criar IAM |
| 1 RDS por serviço, SG liberado só p/ o SG do cluster | Isolamento do hot path; sem CIDR aberto como na Fase 4 |
| donation-db: backup 7d + réplica cross-region no standby | RPO de segundos para o dado crítico |
| Bucket de state por região | O state do standby não depende da região primária |
| ECR com lifecycle (10 imagens) e replicação | FinOps + imagens disponíveis no standby |
| SQS com DLQ | Doação não é perdida em falha de consumo |

## Limitações conhecidas (honestas)
- Failover do banco é manual: promover a réplica (`aws rds promote-read-replica`) e apontar o app. Entra no runbook do PCN.
- NAT único (não HA por AZ) e donation-db sem Multi-AZ por custo; variável `donation_multi_az` existe e está no forecast.
- `kubernetes_version = 1.33`: conferir que está em standard support no dia do apply.
- DynamoDB do standby nasce vazio (dado de voluntários é Tier 2; PITR cobre corrupção, não perda de região).
- Nada foi aplicado: validado com `terraform validate` e fmt. `plan`/`apply` exigem sessão AWS Academy ativa.
