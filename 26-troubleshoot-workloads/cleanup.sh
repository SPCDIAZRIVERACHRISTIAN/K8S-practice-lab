#!/usr/bin/env bash
set -euo pipefail

kubectl delete namespace lab-26-broken --ignore-not-found=true
