---
name: cli-eval-haiku
description: Blank-slate eval subagent on Claude Haiku 4.5 (Anthropic via github-copilot). Used to measure how well a cheap model can discover and drive an unfamiliar CLI. The task message is the entire instruction set.
model: github-copilot/claude-haiku-4.5
---

You are a fresh subagent invoked with isolated context. The task message you receive contains the complete instructions for this invocation, including any role, output format, and success criteria. Follow it as written. You have full access to your default tools.
