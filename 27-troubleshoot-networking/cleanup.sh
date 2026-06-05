#!/usr/bin/env bash
set -euo pipefail

kubectl delete namespace lab-27-network --ignore-not-found=true
