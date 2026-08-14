#!/usr/bin/env pwsh
<#
.SYNOPSIS
Scans task memory files in ./mem/ and auto-generates FILES.md with file change history.

.DESCRIPTION
Parses "Changes Made" and "Files Changed" sections from task logs (YYYYMMDD-*.md),
extracts file references, and builds a master index showing which tasks touched which files.

Supports:
- Backtick-wrapped paths: `src/path/file.ext`
- Line number references: (lines 12-45)
- Multiple files per task
- Sorting by file frequency

.EXAMPLE
pwsh FileImpactMap.ps1

# Output:
# Scanning ./mem for task files...
# Found 8 task files
# Extracted 23 file references
# Updated FILES.md: 23 files tracked across 8 tasks
#>

param(
    [string]$MemDir = "./mem",
    [string]$OutputFile = "./mem/FILES.md"
)

# Color output
function Write-Success {
    Write-Host $args -ForegroundColor Green
}

function Write-Info {
    Write-Host $args -ForegroundColor Cyan
}

function Write-Warning {
    Write-Host $args -ForegroundColor Yellow
}

# Check if mem directory exists
if (-not (Test-Path $MemDir)) {
    Write-Warning "Directory not found: $MemDir"
    Write-Info "Creating $MemDir..."
    New-Item -ItemType Directory -Path $MemDir -Force | Out-Null
}

# Find all task files (YYYYMMDD-*.md, excluding FILES.md and DECISIONS.md)
$TaskFiles = @(Get-ChildItem -Path $MemDir -Filter "????????-*.md" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notmatch "^(FILES|DECISIONS|session)" })

if ($TaskFiles.Count -eq 0) {
    Write-Warning "No task files found in $MemDir"
    Write-Info "Create task files named YYYYMMDD-taskname.md to get started."
    exit 0
}

Write-Info "Scanning $MemDir for task files..."
Write-Success "Found $($TaskFiles.Count) task file(s)"

# Parse file references from each task
$FileMap = @{}  # path -> @{tasks: []; lineRanges: []}
$TaskCount = 0

foreach ($File in $TaskFiles) {
    $TaskName = $File.Name -replace "\.md$", ""
    $Content = Get-Content -Path $File.FullName -Raw -ErrorAction SilentlyContinue

    if (-not $Content) { continue }

    # Extract section: "Changes Made" or "## Changes Made"
    $ChangesSectionRegex = '(?:##\s*)?Changes Made[^#]*?(?=##|$)'
    $ChangesMatch = [regex]::Match($Content, $ChangesSectionRegex, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    if ($ChangesMatch.Success) {
        $ChangesSection = $ChangesMatch.Value

        # Find all backtick-wrapped file paths with optional line ranges
        # Pattern: `path/to/file.ext` with optional (lines XX-YY) or (NEW, lines XX-YY)
        $FileRegex = '`([^`]+)`(?:\s*\((?:NEW,\s*)?lines?\s*(\d+[-–]\d+)\))?'
        $Matches = [regex]::Matches($ChangesSection, $FileRegex)

        foreach ($Match in $Matches) {
            $FilePath = $Match.Groups[1].Value
            $LineRange = $Match.Groups[2].Value

            # Normalize file path (trim whitespace)
            $FilePath = $FilePath.Trim()

            if (-not $FileMap.ContainsKey($FilePath)) {
                $FileMap[$FilePath] = @{
                    Tasks = @()
                    LineRanges = @()
                }
            }

            # Add task reference if not already present
            if ($FileMap[$FilePath].Tasks -notcontains $TaskName) {
                $FileMap[$FilePath].Tasks += $TaskName
            }

            # Add line range if present
            if ($LineRange) {
                $FileMap[$FilePath].LineRanges += $LineRange
            }
        }
    }

    $TaskCount++
}

Write-Success "Extracted $($FileMap.Count) file reference(s)"

# Build FILES.md content
$FileIndex = ""
$SortedFiles = $FileMap.Keys | Sort-Object

foreach ($FilePath in $SortedFiles) {
    $FileData = $FileMap[$FilePath]
    $TaskRefs = $FileData.Tasks | Sort-Object

    $FileIndex += "`n## ``$FilePath``"

    foreach ($Task in $TaskRefs) {
        # Find corresponding line range if available
        $LineInfo = ""
        if ($FileData.LineRanges.Count -gt 0) {
            $LineInfo = " (lines $($FileData.LineRanges[0]))"
        }

        $FileIndex += "`n- $Task$LineInfo — File modified"
    }

    $FileIndex += "`n"
}

# Read the current FILES.md template to preserve manual notes
$TemplateContent = ""
if (Test-Path $OutputFile) {
    $TemplateContent = Get-Content -Path $OutputFile -Raw

    # Extract the "Manual Notes" section
    $ManualNotesRegex = '(?<=## Manual Notes\s*\n)([\s\S]*?)(?=## Quick Search)'
    $ManualMatch = [regex]::Match($TemplateContent, $ManualNotesRegex)
    $ManualNotes = if ($ManualMatch.Success) { $ManualMatch.Value } else { "" }
} else {
    $ManualNotes = ""
}

# Build final content
$FinalContent = @"
# File Change History

Master index of all files modified across tasks. Auto-populated by ``FileImpactMap.ps1``.

## How to Read This

Each file entry shows:
- **File path** — Absolute or relative (backtick-wrapped in task logs)
- **Task references** — Which task files touched this file
- **Line ranges** (when available) — Location of changes within the task log
- **Change type** (when available) — NEW, MODIFIED, DELETED, REFACTORED

## File Index
$FileIndex

## Manual Notes

Use this section to record file changes that weren't captured in task logs:

$ManualNotes

## Quick Search

To find all tasks that touched a specific file:
``````powershell
grep -r "src/pages/PricingPage.tsx" ./mem --include="*.md"
``````

To find all files modified on a specific date:
``````powershell
grep -l "^## \`src/" ./mem/20250601-*.md
``````

## Statistics (Auto-Updated)

- **Total files tracked:** $($FileMap.Count)
- **Tasks with file changes:** $TaskCount
- **Most-modified file:** $(if ($SortedFiles.Count -gt 0) { $SortedFiles[0] } else { "N/A" })
- **Last update:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

---

*Generated by FileImpactMap.ps1*
"@

# Write the updated FILES.md
Set-Content -Path $OutputFile -Value $FinalContent -Encoding UTF8

Write-Success "Updated FILES.md: $($FileMap.Count) files tracked across $TaskCount task(s)"
Write-Info "Location: $OutputFile"
