#!/usr/bin/env bash
# Run each agent action in agent/actions.jsonl through the enforcing proxy against the approved
# governance, project the decisions to SARIF, and fail if any privileged action was denied.
# Offline: the upstream is a local mock, no real credentials, no real GitHub call.
set -euo pipefail
cd "$(dirname "$0")/.."

ASSAY="${ASSAY:-assay-mcp-server}"
PY="${PYTHON:-python3}"
SARIF="${1:-enforcement.sarif}"
DEC="decisions.ndjson"
: >"$DEC"

INIT='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"gate","version":"1"}}}'

while IFS= read -r params; do
  [ -z "$(printf '%s' "$params" | tr -d '[:space:]')" ] && continue
  call="$("$PY" -c 'import json,sys; print(json.dumps({"jsonrpc":"2.0","id":9,"method":"tools/call","params":json.loads(sys.argv[1])}))' "$params")"
  printf '%s\n%s\n' "$INIT" "$call" \
    | MOCK_MODE=approved "$ASSAY" proxy-enforce \
        --upstream-command "$PY" --upstream-arg -u --upstream-arg tools/mock_github_mcp.py \
        --enforce-policy governance/policy.yaml \
        --declared-mcp-manifest governance/baseline.json \
        --enforcement-decision-out "$DEC" \
        >/dev/null 2>&1 || true
done < agent/actions.jsonl

if [ ! -s "$DEC" ]; then
  echo "ERROR: no enforcement_decision records produced (is assay-mcp-server installed? python3 present?)" >&2
  exit 1
fi

"$ASSAY" enforcement-sarif --input "$DEC" --output "$SARIF"
n="$("$PY" -c 'import json,sys; print(len(json.load(open(sys.argv[1]))["runs"][0]["results"]))' "$SARIF")"
echo "$n privileged action(s) denied; SARIF -> $SARIF"
if [ "$n" != "0" ]; then
  echo "::error::$n privileged tool action(s) denied before forward — see the Security tab"
  exit 1
fi
echo "gate passed: every agent action was declared, scoped, and approved"
