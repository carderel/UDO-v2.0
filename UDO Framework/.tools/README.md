# .tools/

## What It Is

This folder contains tool adapters, configurations, and integrations that extend UDO's capabilities.

## What It Does

Tools connect UDO to external services and capabilities:
- Search adapters (web search, internal search)
- Storage adapters (databases, file systems)
- Data adapters (APIs, data sources)
- Communication adapters (email, Slack, notifications)
- Execution adapters (code runners, CI/CD)

Each adapter defines how to interact with a specific tool or service.

## Why It's Included

**Problem:** Different AI platforms have different tool access. What works in Claude Code doesn't work in ChatGPT. Tool availability changes between environments. Without abstraction, tool usage is fragile and inconsistent.

**Solution:** Define tool adapters that describe capabilities abstractly. AI checks what's available and uses appropriate methods. Same logic works across platforms.

## Structure

```
.tools/
├── adapters/               # Tool type definitions
│   ├── search.md           # Search tool adapter
│   ├── storage.md          # Storage tool adapter
│   ├── data.md             # Data access adapter
│   ├── communication.md    # Communication adapter
│   └── execution.md        # Code execution adapter
├── installed/              # Project-specific tool configs
│   └── {tool-config}.json
├── templates/
│   └── tool-config.md      # Template for new tool configs
└── README.md               # This file
```

## Adapter Structure

Each adapter defines:
- **Capability** — What the tool type does
- **Methods** — How to invoke it
- **Fallbacks** — What to do if unavailable
- **Outputs** — What it returns

Example (`adapters/search.md`):
```markdown
# Search Adapter

## Capability
Search for information from various sources

## Methods
1. Web search (if available)
2. File search (local files)
3. Memory search (.memory/ folder)

## Fallback
If no search tool available, check .memory/ and .inputs/

## Outputs
- Search results with sources
- Relevance ranking
- Source citations
```

## Tool Configuration

For project-specific tools, add configs to `installed/`:

```json
{
  "tool": "internal-api",
  "type": "data",
  "endpoint": "https://api.internal.com",
  "auth": "See secrets manager",
  "methods": ["GET", "POST"],
  "rate_limit": "100/hour"
}
```

## How Tools Are Used

1. AI identifies need for tool capability
2. AI reads relevant adapter in `.tools/adapters/`
3. AI checks CAPABILITIES.json for availability
4. AI uses available method or fallback
5. Results incorporated into workflow

## Environment Detection

CAPABILITIES.json (in project root) declares what's available:

```json
{
  "tools_available": {
    "web_search": true,
    "file_read": true,
    "file_write": true,
    "code_execution": true,
    "bash_commands": false
  }
}
```

AI checks this before attempting tool use.

## Adding New Tools

1. Determine tool type (search, storage, data, communication, execution)
2. Add config to `installed/` if project-specific
3. Update CAPABILITIES.json if new capability
4. Document usage in relevant adapter file
