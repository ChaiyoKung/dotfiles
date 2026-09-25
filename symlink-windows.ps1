# Requires administrator privileges.
# Symbolic links on Windows need admin rights, so run PowerShell as Administrator first.
# If the link already exists, remove it first.

# ~\.agents
New-Item -ItemType SymbolicLink -Path "$HOME\.agents" -Target "$HOME\dotfiles\agents"
Get-Item "$HOME\.agents" | Select-Object FullName, LinkType, Target

# ~\.copilot\agents\miku.agent.md
New-Item -ItemType Directory -Path "$HOME\.copilot\agents"
New-Item -ItemType SymbolicLink -Path "$HOME\.copilot\agents\miku.agent.md" -Target "$HOME\dotfiles\agents\AGENTS.md"
Get-Item "$HOME\.copilot\agents\miku.agent.md" | Select-Object FullName, LinkType, Target
