<!-- This repo is a demo of the agent privileged-action gate. PRs change the agent's actions
     (agent/actions.jsonl) and the approved governance (governance/policy.yaml); the gate decides. -->

## What this PR changes

<!-- One or two sentences. -->

## Expected gate outcome

- [ ] 🔴 red — an action here is not declared, scoped, and approved
- [ ] 🟢 green — every action is declared, scoped, and approved

## Checklist

- [ ] I ran `./scripts/run-gate.sh` locally (or I expect CI to show the outcome above)
- [ ] No real credentials or real provider calls are involved (this demo is offline)
