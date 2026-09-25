#!/usr/bin/env bash

# If the link already exists, remove it first.

# ~/.agents
ln -s "$HOME/dotfiles/agents" "$HOME/.agents"
ls -l "$HOME/.agents"

# ~/.claude
ln -s "$HOME/dotfiles/claude" "$HOME/.claude"
ls -l "$HOME/.claude"

# ~/.copilot/agents/miku.agent.md
mkdir -p "$HOME/.copilot/agents"
ln -s "$HOME/dotfiles/agents/AGENTS.md" "$HOME/.copilot/agents/miku.agent.md"
ls -l "$HOME/.copilot/agents/miku.agent.md"
