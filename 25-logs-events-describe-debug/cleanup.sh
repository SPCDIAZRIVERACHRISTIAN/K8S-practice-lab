#!/usr/bin/env bash
set -euo pipefail

kubectl delete namespace lab-25-observe --ignore-not-found=true
