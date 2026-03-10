# Agents

External agent definitions and adapters for this project.

## Purpose

This directory defines agents that can interact with the project:
- External AI systems
- Automation tools
- Integrations
- Third-party services

## Structure

Each agent has a configuration file with:
- Agent identity
- Capabilities
- Protocol compliance requirements
- Integration points

## Agent File Format

`{agent-name}.md` following the `.templates/external-agent.md` template.

## Bridge Protocol

Agents interact with the project via the bridge protocol (see `.bridge/`):
- Asynchronous messaging
- State isolation
- Command queue
- Response tracking

## Examples

Standard agents may include:
- `claude-desktop.md` - Claude Desktop adapter
- `github-actions.md` - CI/CD automation
- `monitoring.md` - System monitoring agents

## See Also

- `.bridge/README.md` - Bridge protocol documentation
- `.bridge/adapters/` - Framework adapters
- `.templates/external-agent.md` - Agent template
