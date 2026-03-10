# Adapter: {PLATFORM_NAME}

## Platform
- **Name:** {Human-readable platform name}
- **Type:** {desktop-ai | cli-ai | api-agent | custom}
- **Version:** {Platform version or "any"}

## Capabilities

What this platform CAN do via the bridge:
- {Capability 1}
- {Capability 2}
- {Capability 3}

## Limitations

What this platform CANNOT do:
- {Limitation 1}
- {Limitation 2}
- {Limitation 3}

## Filesystem Access
- **Method:** {direct | applescript | api-based | human-mediated | none}
- **Read:** {yes/no — and how}
- **Write:** {yes/no — and how}
- **Path to bridge files:** {absolute path or "relative to project root"}

## Connected Services

Services this platform can access that the local agent may not have:
- {Service 1} — {access method}
- {Service 2} — {access method}

## Bridge Participation
- **Polling:** {human-triggered | file-watch | interval | webhook}
- **Response format:** {standard | extended}
- **Request categories handled:** {list from taxonomy, or "all"}

## Auto-Detection Rules

When the local agent should automatically create a bridge request for this adapter:
1. {Rule 1 — e.g., "Task requires web browsing"}
2. {Rule 2 — e.g., "Task requires desktop application control"}
3. {Rule 3}

## Trigger Phrases

Phrases the human uses to activate this adapter:
- **To check for requests:** "{phrase}"
- **To get status:** "{phrase}"
- **To sync context:** "{phrase}"

## Setup Instructions

How to configure this adapter for first use:
1. {Step 1}
2. {Step 2}
3. {Step 3}
