# Requires administrator privileges.
# Symbolic links on Windows need admin rights, so run PowerShell as Administrator first.
# If the link already exists, remove it first.

# ~\.agents
New-Item -ItemType SymbolicLink -Target "$HOME\dotfiles\agents" -Path "$HOME\.agents"
Get-Item "$HOME\.agents" | Select-Object Target, LinkType, FullName

# ~\.copilot\agents\miku.agent.md
New-Item -ItemType Directory -Path "$HOME\.copilot\agents"
New-Item -ItemType SymbolicLink -Target "$HOME\dotfiles\agents\AGENTS.md" -Path "$HOME\.copilot\agents\miku.agent.md"
Get-Item "$HOME\.copilot\agents\miku.agent.md" | Select-Object Target, LinkType, FullName
