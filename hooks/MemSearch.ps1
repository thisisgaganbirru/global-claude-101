# MemSearch.ps1 - Search local memory files with metadata filtering (pure filesystem, no APIs)
# Usage: pwsh MemSearch.ps1 "oauth" [-Tag 'tagname'] [-Status 'completed'] [-Since 'YYYY-MM-DD'] [-File 'filename']

param(
    [string]$Query,
    [string]$MemDir = "./mem",
    [switch]$ShowContext = $false,
    [int]$ContextLines = 2,
    [string]$Tag,
    [string]$Status,
    [string]$Since,
    [string]$File
)

# Parse YAML frontmatter from a file
function Parse-YamlFrontmatter {
    param([string]$FilePath)

    $Content = Get-Content -Path $FilePath -Raw
    $Metadata = @{}

    # Check if file starts with ---
    if ($Content -match '^---\s*\r?\n') {
        # Extract frontmatter block
        $Match = [regex]::Match($Content, '^---\s*\r?\n(.*?)\r?\n---', [System.Text.RegularExpressions.RegexOptions]::Singleline)
        if ($Match.Success) {
            $FrontmatterText = $Match.Groups[1].Value

            # Parse each line as key: value
            $Lines = $FrontmatterText -split '\r?\n'
            foreach ($Line in $Lines) {
                if ($Line -match '^(\w+):\s*(.*)$') {
                    $Key = $Matches[1]
                    $Value = $Matches[2].Trim()

                    # Handle arrays in YAML (e.g., tags: [auth, oauth, security])
                    if ($Value -match '^\[(.*)\]$') {
                        $ArrayContent = $Matches[1]
                        $Metadata[$Key] = @($ArrayContent -split ',\s*' | ForEach-Object { $_.Trim() })
                    } else {
                        $Metadata[$Key] = $Value
                    }
                }
            }
        }
    }

    return $Metadata
}

# Check if a file matches all active filters
function Test-FiltersMatch {
    param(
        [hashtable]$Metadata,
        [string]$FileName,
        [string]$FileContent
    )

    # Tag filter
    if ($Tag) {
        $FileTags = $Metadata['tags']
        if (-not $FileTags -or $FileTags -notcontains $Tag) {
            return $false
        }
    }

    # Status filter
    if ($Status) {
        if ($Metadata['status'] -ne $Status) {
            return $false
        }
    }

    # Since filter (date comparison)
    if ($Since) {
        $SinceDate = try { [datetime]::ParseExact($Since, 'yyyy-MM-dd', $null) } catch { $null }
        if ($SinceDate) {
            $FileDate = $Metadata['date']
            if ($FileDate) {
                $FileDateObj = try { [datetime]::ParseExact($FileDate, 'yyyy-MM-dd', $null) } catch { $null }
                if ($FileDateObj -and $FileDateObj -lt $SinceDate) {
                    return $false
                }
            }
        }
    }

    # File filter (check files_touched in metadata)
    if ($File) {
        $FilesTouched = $Metadata['files_touched']
        if (-not $FilesTouched -or $FilesTouched -notcontains $File) {
            return $false
        }
    }

    return $true
}

if (-not $Query -and -not $Tag -and -not $Status -and -not $Since -and -not $File) {
    Write-Host "Usage: MemSearch.ps1 [-Query 'query'] [-Tag 'tagname'] [-Status 'status'] [-Since 'YYYY-MM-DD'] [-File 'filename'] [-ShowContext] [-ContextLines 2]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Cyan
    Write-Host "  MemSearch.ps1 'oauth'" -ForegroundColor Gray
    Write-Host "  MemSearch.ps1 'token' -ShowContext" -ForegroundColor Gray
    Write-Host "  MemSearch.ps1 -Tag 'pricing'" -ForegroundColor Gray
    Write-Host "  MemSearch.ps1 -Status 'in_progress'" -ForegroundColor Gray
    Write-Host "  MemSearch.ps1 -Since '2025-06-01'" -ForegroundColor Gray
    Write-Host "  MemSearch.ps1 -File 'PricingPage.tsx'" -ForegroundColor Gray
    Write-Host "  MemSearch.ps1 'oauth' -Tag 'auth' -ShowContext" -ForegroundColor Gray
    exit 1
}

if (-not (Test-Path $MemDir)) {
    Write-Host "❌ Memory directory not found: $MemDir" -ForegroundColor Red
    exit 1
}

# Display active filters
$ActiveFilters = @()
if ($Query) { $ActiveFilters += "Query: '$Query'" }
if ($Tag) { $ActiveFilters += "Tag: '$Tag'" }
if ($Status) { $ActiveFilters += "Status: '$Status'" }
if ($Since) { $ActiveFilters += "Since: '$Since'" }
if ($File) { $ActiveFilters += "File: '$File'" }

Write-Host "🔍 Searching with filters:" -ForegroundColor Cyan
foreach ($Filter in $ActiveFilters) {
    Write-Host "   • $Filter" -ForegroundColor Gray
}
Write-Host "📂 In: $MemDir" -ForegroundColor Gray
Write-Host ""

$MemFiles = Get-ChildItem -Path $MemDir -Filter "*.md" -File | Sort-Object Name -Descending

if ($MemFiles.Count -eq 0) {
    Write-Host "No memory files found." -ForegroundColor Yellow
    exit 0
}

$Results = @()
$FilesChecked = 0
$FilesMatched = 0

foreach ($File in $MemFiles) {
    $Content = Get-Content -Path $File.FullName -Raw
    $Metadata = Parse-YamlFrontmatter -FilePath $File.FullName
    $FilesChecked++

    # Check if file matches all metadata filters
    if (-not (Test-FiltersMatch -Metadata $Metadata -FileName $File.Name -FileContent $Content)) {
        continue
    }

    $FilesMatched++

    # If Query is specified, search for it. If only filters are specified, include the whole file.
    if ($Query) {
        # Case-insensitive search
        if ($Content -match [regex]::Escape($Query)) {
            $Lines = Get-Content -Path $File.FullName

            for ($i = 0; $i -lt $Lines.Count; $i++) {
                if ($Lines[$i] -match [regex]::Escape($Query)) {
                    $Result = @{
                        File = $File.Name
                        LineNumber = $i + 1
                        Line = $Lines[$i]
                        Metadata = $Metadata
                    }

                    if ($ShowContext) {
                        $ContextStart = [Math]::Max(0, $i - $ContextLines)
                        $ContextEnd = [Math]::Min($Lines.Count - 1, $i + $ContextLines)
                        $Result.Context = $Lines[$ContextStart..$ContextEnd]
                    }

                    $Results += $Result
                }
            }
        }
    } else {
        # No query specified, just return file match with metadata
        $Result = @{
            File = $File.Name
            LineNumber = 0
            Line = "Matched by filters"
            Metadata = $Metadata
            IsFileMatch = $true
        }
        $Results += $Result
    }
}

if ($Results.Count -eq 0) {
    if ($Query) {
        Write-Host "No results found matching all criteria." -ForegroundColor Yellow
    } else {
        Write-Host "No files matched the filters." -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "Files checked: $FilesChecked | Files matched filters: $FilesMatched" -ForegroundColor Gray
    exit 0
}

Write-Host "Found $($Results.Count) match(es):" -ForegroundColor Green
Write-Host ""

foreach ($Result in $Results) {
    if ($Result.IsFileMatch) {
        # File-level match (filters only, no query)
        Write-Host "📄 $($Result.File)" -ForegroundColor Cyan
    } else {
        # Line-level match (has query)
        Write-Host "📄 $($Result.File) : Line $($Result.LineNumber)" -ForegroundColor Cyan
        Write-Host "   $($Result.Line.Trim())" -ForegroundColor Gray
    }

    # Display metadata if available
    if ($Result.Metadata -and $Result.Metadata.Count -gt 0) {
        Write-Host "   Metadata:" -ForegroundColor DarkGray
        if ($Result.Metadata['date']) {
            Write-Host "      date: $($Result.Metadata['date'])" -ForegroundColor DarkGray
        }
        if ($Result.Metadata['status']) {
            Write-Host "      status: $($Result.Metadata['status'])" -ForegroundColor DarkGray
        }
        if ($Result.Metadata['tags']) {
            $TagList = $Result.Metadata['tags'] -join ', '
            Write-Host "      tags: [$TagList]" -ForegroundColor DarkGray
        }
        if ($Result.Metadata['files_touched']) {
            $FileList = $Result.Metadata['files_touched'] -join ', '
            Write-Host "      files_touched: [$FileList]" -ForegroundColor DarkGray
        }
    }

    if ($ShowContext -and $Result.Context) {
        Write-Host ""
        Write-Host "   Context:" -ForegroundColor Gray
        foreach ($ContextLine in $Result.Context) {
            Write-Host "   | $ContextLine" -ForegroundColor DarkGray
        }
    }

    Write-Host ""
}

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "$($Results.Count) match(es) | Files checked: $FilesChecked | Files matched filters: $FilesMatched" -ForegroundColor Green
