# Agent: {NAME}

## Agent Type
**External (Bridged)**

## Platform
- **AI Platform:** {Claude Desktop | Gemini Desktop | GPT Desktop | other}
- **Bridge Adapter:** `.bridge/adapters/{adapter-folder}/adapter.md`

## Specialization
{One sentence describing core competency}

## Capabilities
- {Skill 1}
- {Skill 2}
- {Skill 3}

## Filesystem Access
- **Method:** {direct | applescript | api-based | human-mediated | none}
- **Bridge Path:** `UDO/.bridge/`

## Connected Services
- {Service 1} — {access method}
- {Service 2} — {access method}

## Input Contract
Expects:
- Bridge requests in `bridge-queue.md` following BRIDGE-PROTOCOL.md format
- {Additional input requirements}

## Output Contract
Returns:
- Bridge responses appended to `bridge-queue.md`
- Entries in `.bridge/session-log.md`
- Updates to `bridge-state.json`
- {Additional outputs}

## Operating Constraints
- All communication via `.bridge/bridge-queue.md`
- Cannot access local filesystem directly (unless adapter specifies otherwise)
- Cannot maintain state across conversations
- Requires human to trigger bridge checks
- MANDATORY: Follow error escalation protocol in BRIDGE-PROTOCOL.md
- MANDATORY: Invoke stuck protocol if requirements are ambiguous

## Availability
- **Status:** {active | inactive | on-demand}
- **Last Seen:** {timestamp or "never"}
- **Activation:** {how the human activates this agent — e.g., "Open Claude.ai and paste INSTRUCTIONS.md"}

## Learned Rules
<!-- Added when lessons apply to this agent -->

## Success Metrics
- Bridge requests completed within expected timeframe
- Response quality sufficient for requesting agent to proceed
- No unresolved NEEDS_CLARIFICATION loops exceeding 2 rounds
- {Additional metrics}
