#!/usr/bin/env bash
# DR opção B: levanta o ambiente espelho (Warm Standby) em us-west-2 com UM comando.
# Uso: bash scripts/dr-standby-up.sh
exec bash "$(dirname "$0")/infra-up.sh" standby
