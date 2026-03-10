# .bridge/

## What It Is

The Bridge is a cross-agent communication system that lets two or more AI instances coordinate work through shared files. It enables AI agents that cannot directly talk to each other to pass requests, responses, and context through a structured file-based protocol.

## What It Does

- Provides a **communication channel** (`bridge-queue.md`) for structured requests and responses between agents
- Tracks **bridge status** (`bridge-state.json`) so agents know what's pending
- Maintains a **running log** (`session-log.md`) of all cross-agent activity
- Defines **adapters** for specific AI platforms (capabilities, limitations, how they connect)
- Supports **error escalation** from self-resolve to bridge request to human intervention
- Scores **request complexity** via pre-flight audit to prevent overloaded single-prompt execution
- Enforces **browser execution ladder** — cheapest-first escalation for all browser-based reads

## Why It's Included

**Problem:** Users often work with multiple AI instances simultaneously — one in the CLI (editing files, running code) and another on the desktop (browsing the web, controlling apps, accessing cloud services). These instances cannot communicate with each other. The only option is manual copy/paste, which is slow, lossy, and breaks flow.

**Solution:** Both AI instances can read and write to the local filesystem. A shared directory with structured files becomes the communication channel. The protocol is AI-agnostic — any agent that can read and write files can participate. Platform-specific details live in adapter definitions, not the protocol.

## Structure

```
.bridge/
├── README.md                           # This file
├── BRIDGE-PROTOCOL.md                  # AI-agnostic protocol specification
├── PRE-FLIGHT-AUDIT.md                 # Complexity scoring for bridge requests
├── BROWSER-LADDER.md                   # Escalation order for browser reads
├── bridge-queue.md                     # Request/response communication channel
├── bridge-state.json                   # Machine-readable status flags
├── session-log.md                      # Running log of all bridge activity
├── templates/
│   ├── bridge-request.md               # Request format template
│   └── bridge-response.md              # Response format template
└── adapters/
    ├── README.md                       # How adapters work
    ├── _template/
    │   └── adapter.md                  # Blank adapter template
    └── claude-desktop/                 # Claude Desktop adapter
        ├── adapter.md                  # Capabilities and configuration
        └── INSTRUCTIONS.md             # Instructions to paste into Claude.ai
```

## How It Works

1. **Local Agent** (CLI AI) encounters a task outside its capabilities
2. Local Agent writes a structured request to `bridge-queue.md` with full context
3. Local Agent updates `bridge-state.json` and logs to `session-log.md`
4. Local Agent tells the human: "Tell the Remote Agent to check the bridge"
5. Human triggers the **Remote Agent** (Desktop AI): "Check the bridge"
6. Remote Agent reads the request, handles it, writes a response
7. Remote Agent updates state and logs
8. Human tells Local Agent: "Check the bridge"
9. Local Agent reads the response and continues work

## When to Use

- A task requires capabilities the current agent doesn't have
- You need web research but only have CLI access
- You need to control a Mac application but only have file access
- You need to access Google Drive, Slack, email, or other cloud services
- An error persists after 2 attempts and the other agent might help
- The human asks you to coordinate with another AI

## Integration with UDO

| UDO System | How Bridge Integrates |
|------------|----------------------|
| `ORCHESTRATOR.md` | Bridge commands, directives, circuit breakers |
| `HARD_STOPS.md` | HS-UDO-009: bridge files are append-only |
| `COMMANDS.md` | Bridge command section with shortcuts |
| `CAPABILITIES.json` | Bridge enabled/disabled, adapter list |
| `PROJECT_STATE.json` | Bridge status tracking |
| `.agents/` | External agents use `external-agent.md` template |
| `.project-catalog/communications/` | Archive for completed bridge entries |
