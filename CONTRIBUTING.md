# Contributing

Thanks for taking a look. This repo is a small, runnable demo of the agent privileged-action gate
built on [assay](https://github.com/Rul1an/assay). It is meant to stay tiny and easy to read, so the
best contributions keep it that way.

## Run it locally

You need `python3` and an `assay-mcp-server` binary. The `enforcement-sarif` projector is newer than
the latest tagged assay release, so for now build it from assay main:

```bash
git clone --depth 1 https://github.com/Rul1an/assay
cargo build --release --locked -p assay-mcp-server --manifest-path assay/Cargo.toml
ASSAY=assay/target/release/assay-mcp-server ./scripts/run-gate.sh
```

The gate runs each action in `agent/actions.jsonl` through the enforcing proxy against the approved
`governance/policy.yaml` and `governance/baseline.json`, using the local mock MCP server in `tools/`.
No real credentials, no real GitHub call.

## How the pieces fit

- `agent/actions.jsonl` is what the agent tries to do, one `tools/call` per line.
- `governance/policy.yaml` is the approved allowance: which action classes and targets are permitted.
- `governance/baseline.json` is the approved tool surface the drift gate compares against.
- `scripts/run-gate.sh` drives the proxy and projects the denies to SARIF.
- `.github/workflows/agent-gate.yml` runs the gate on every PR and uploads the SARIF.

Change the action or the policy, open a PR, and watch the check go red or green.

## Proposing a change

Open an issue first if it is more than a typo, so we can agree on scope before you write it. Keep the
demo offline and free of real secrets. Please sign off your commits with the Developer Certificate of
Origin:

```bash
git commit -s -m "your message"
```

Bugs or feature requests for assay itself belong in the [assay tracker](https://github.com/Rul1an/assay/issues).
