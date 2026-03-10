# Bridge Adapters

## What Adapters Are

An adapter defines how a specific AI platform connects to the bridge. The bridge protocol (in `BRIDGE-PROTOCOL.md`) is AI-agnostic — it works with any agent that can read and write files. Adapters fill in the platform-specific details: what it can do, how it accesses files, what services it connects to, and what trigger phrases activate it.

## How They Work

1. Each adapter is a **folder** inside `adapters/` named after the platform
2. Every adapter contains at minimum an `adapter.md` definition file
3. Adapters may also include an `INSTRUCTIONS.md` — text to paste or auto-load into the external platform so it knows how to use the bridge
4. The bridge protocol references adapters but does not depend on them — the protocol works even without any adapters configured

## Available Adapters

| Adapter | Platform | Status |
|---------|----------|--------|
| `claude-desktop/` | Claude Desktop (Claude.ai) | Available |

## Adapter Structure

```
adapters/
├── README.md                    # This file
├── _template/
│   └── adapter.md               # Blank adapter template
└── {platform-name}/
    ├── adapter.md               # Platform definition (required)
    └── INSTRUCTIONS.md          # Instructions for the platform (optional)
```

## Creating a New Adapter

1. Copy `_template/adapter.md` to a new folder: `adapters/{platform-name}/adapter.md`
2. Fill in all sections of the adapter definition
3. Optionally create `INSTRUCTIONS.md` with instructions the external platform should follow
4. Create an external agent definition in `.agents/` using `.templates/external-agent.md`
5. Update `CAPABILITIES.json` to list the new adapter in `bridge.adapters_available`

## How Adapters Are Used at Runtime

1. The local agent encounters a task outside its capabilities (per `CAPABILITIES.json`)
2. The local agent reads `adapters/` to find an adapter whose capabilities match the need
3. The local agent writes a bridge request to `bridge-queue.md`, addressed to that adapter's role
4. The local agent updates `bridge-state.json` with the pending request
5. The local agent tells the human to trigger the external agent
6. The external agent checks the bridge, handles the request, writes a response
7. The human tells the local agent to check the bridge response
