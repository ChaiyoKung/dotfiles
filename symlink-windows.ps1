# Requires administrator privileges.
# Symbolic links on Windows need admin rights, so run PowerShell as Administrator first.
# If the link already exists, remove it first.

# ~\.agents
New-Item -ItemType SymbolicLink -Path "$HOME\.agents" -Target "$HOME\dotfiles\agents"
Get-Item "$HOME\.agents" | Select-Object FullName, LinkType, Target
