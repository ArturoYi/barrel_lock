#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

chmod +x .githooks/pre-commit
git config core.hooksPath .githooks

echo "Installed git hooks: core.hooksPath=.githooks"
echo "pre-commit will run 'dart format' on staged .dart files before each commit."
