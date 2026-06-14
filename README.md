# Agent privileged-action gate (demo)

[![lint](https://github.com/Rul1an/assay-agent-gate-demo/actions/workflows/lint.yml/badge.svg)](https://github.com/Rul1an/assay-agent-gate-demo/actions/workflows/lint.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A tiny, runnable demo. When an AI agent opens a PR that tries a privileged tool action it was not
granted, a CI gate denies it **before it runs**, writes a replayable evidence record, and surfaces it
in the Security tab. When the same action is properly declared, scoped, and approved, the gate passes.

Built on [assay](https://github.com/Rul1an/assay), policy-as-code for MCP agents.

![agent gate demo](docs/gate-demo.gif)

## The two pull requests

- 🔴 **agent adds a deploy key it was not granted** — the agent's action targets a repo outside its
  approved policy. The gate denies it (`no_declared_allowance`), the check goes red, and the result
  appears in the Security tab.
- 🟢 **declare and scope the action** — the same action, now declared in `governance/policy.yaml`. The
  gate passes and the check is green.

See it live: [the red PR (#1)](https://github.com/Rul1an/assay-agent-gate-demo/pull/1) and
[the green PR (#2)](https://github.com/Rul1an/assay-agent-gate-demo/pull/2). Both stay open so the
red vs green contrast is visible in the PR checks and the Security tab.

## Run it locally (offline)

```bash
# needs python3 and an assay-mcp-server with `enforcement-sarif` (newer than the latest release),
# so build it from assay main:
git clone --depth 1 https://github.com/Rul1an/assay
cargo build --release --locked -p assay-mcp-server --manifest-path assay/Cargo.toml
ASSAY=assay/target/release/assay-mcp-server ./scripts/run-gate.sh
```

The gate runs each action in `agent/actions.jsonl` through the enforcing proxy against the approved
`governance/policy.yaml` and `governance/baseline.json`, using a local mock MCP server in `tools/`.
No real credentials, no real GitHub call.

## How it works

`scripts/run-gate.sh` sends each agent action through `assay-mcp-server proxy-enforce`, which decides
per call before forwarding and writes an `assay.enforcement_decision.v0` record. `enforcement-sarif`
projects the denies to SARIF 2.1.0; `.github/workflows/agent-gate.yml` uploads it to the Security tab
and fails the PR on any deny.

## Bounded non-claims

- a deny is fail-closed caution, not a verdict on intent;
- an allow is the decision to forward, never proof the action happened;
- this demo runs against a local mock, so there is no real provider and no real side effect.

## License

MIT
