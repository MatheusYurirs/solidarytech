#!/usr/bin/env bash
# Teste de fumaça do ambiente local: health + fluxo básico dos 3 serviços.
set -euo pipefail

step() { printf '\n== %s\n' "$1"; }

step "health"
for port in 8081 8082 8083; do curl -sS --fail-with-body "localhost:$port/health"; echo; done

step "listar ONGs (seed do init.sql)"
curl -sS --fail-with-body localhost:8081/ngos; echo

step "registrar doação"
curl -sS --fail-with-body -X POST localhost:8082/donations \
  -H 'Content-Type: application/json' \
  -d '{"ngo_id": 1, "amount": 50.00, "donor_name": "Teste Local"}'; echo

step "listar doações"
curl -sS --fail-with-body localhost:8082/donations; echo

step "registrar voluntário"
curl -sS --fail-with-body -X POST localhost:8083/volunteers \
  -H 'Content-Type: application/json' \
  -d '{"name": "Voluntario Teste", "email": "voluntario@teste.org", "ngo_id": 1}'; echo

step "listar voluntários da ONG 1"
curl -sS --fail-with-body localhost:8083/volunteers/1; echo

printf '\nOK: ambiente local respondendo.\n'
