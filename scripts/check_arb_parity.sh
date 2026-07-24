#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
L10N_DIR="$ROOT/packages/app_l10n/lib/l10n"

keys_from_arb() {
  python3 - "$1" <<'PY'
import json, sys
with open(sys.argv[1], encoding='utf-8') as f:
    data = json.load(f)
print('\n'.join(sorted(k for k in data if not k.startswith('@'))))
PY
}

template="$L10N_DIR/app_zh.arb"
template_keys="$(keys_from_arb "$template")"

status=0
for arb in app_en.arb app_zh_TW.arb app_ar.arb; do
  path="$L10N_DIR/$arb"
  keys="$(keys_from_arb "$path")"
  missing="$(comm -23 <(printf '%s\n' "$template_keys") <(printf '%s\n' "$keys") || true)"
  extra="$(comm -13 <(printf '%s\n' "$template_keys") <(printf '%s\n' "$keys") || true)"
  if [[ -n "$missing" || -n "$extra" ]]; then
    echo "ARB parity failed for $arb"
    [[ -n "$missing" ]] && echo "  missing: $missing"
    [[ -n "$extra" ]] && echo "  extra: $extra"
    status=1
  else
    echo "OK: $arb"
  fi
done

exit $status
