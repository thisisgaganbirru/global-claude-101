# SessionEnd.ps1 - Create daily session summary (local filesystem only)
# No external calls, no APIs, just markdown files
# Usage: pwsh SessionEnd.ps1

param(
    [string]$MemDir = "./mem"
)

$SessionDate = Get-Date -Format "yyyyMMdd"
$SessionTime = Get-Date -Format "HH:mm"
$SessionLogFile = Join-Path $MemDir "${SessionDate}-session.md"

# Ensure mem directory exists
if (-not (Test-Path $MemDir)) {
    New-Item -ItemType Directory -Force -Path $MemDir | Out-Null
}

# Create file if it doesn't exist
if (-not (Test-Path $SessionLogFile)) {
    @"
# Session Log - $SessionDate

Daily journal of work sessions. Each entry is a task worked on.

---
"@ | Out-File -FilePath $SessionLogFile -Encoding utf8 -NoNewline
}

# Append session entry
@"
### $SessionTime - [Task Name]

**Status:** In progress | Completed | Blocked
**Changes:** List files modified or features added
**Next steps:** What comes next?

---
"@ | Add-Content -FilePath $SessionLogFile -Encoding utf8

Write-Host "✓ Session logged to $SessionLogFile" -ForegroundColor Green
Write-Host "  Edit the entry with your task details" -ForegroundColor Gray
