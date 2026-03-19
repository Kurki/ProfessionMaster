param(
    [string]$SourcePath = $PSScriptRoot
)

$addonName = "ProfessionMaster"
$basePath = "${env:ProgramFiles(x86)}\World of Warcraft"
$wowFolders = @("_anniversary_", "_classic_", "_classic_era_")

# Resolve target directories that actually exist
$targetDirs = @()
foreach ($folder in $wowFolders) {
    $target = Join-Path $basePath "$folder\Interface\AddOns\$addonName"
    $parentDir = Split-Path $target -Parent
    if (Test-Path $parentDir) {
        if (-not (Test-Path $target)) {
            New-Item -ItemType Directory -Path $target -Force | Out-Null
        }
        $targetDirs += $target
        Write-Host "  Watching target: $target" -ForegroundColor Green
    }
}

$targetDirs = $targetDirs | Select-Object -Unique

if ($targetDirs.Count -eq 0) {
    Write-Host "No WoW addon directories found. Exiting." -ForegroundColor Red
    exit 1
}

# Patterns to exclude from syncing
$excludePatterns = @(
    '(^|\\)\.git(\\|$)',
    '(^|\\)\.github(\\|$)',
    '(^|\\)\.vscode(\\|$)',
    '(^|\\)deploy.*\.bat$',
    '(^|\\)version\.txt$',
    '(^|\\)watch-addon\.ps1$'
)

function Test-Excluded {
    param([string]$RelativePath)
    foreach ($pattern in $excludePatterns) {
        if ($RelativePath -match $pattern) {
            return $true
        }
    }
    return $false
}

function Copy-ToTargets {
    param([string]$FullPath, [string]$ChangeType)

    $relativePath = $FullPath.Substring($SourcePath.Length).TrimStart('\', '/')
    if (Test-Excluded $relativePath) { return }

    $timestamp = Get-Date -Format "HH:mm:ss"

    foreach ($targetDir in $targetDirs) {
        $destination = Join-Path $targetDir $relativePath
        if ($ChangeType -eq "Deleted") {
            if (Test-Path $destination) {
                Remove-Item -Path $destination -Force -Recurse -ErrorAction SilentlyContinue
                Write-Host "[$timestamp] Deleted: $relativePath -> $targetDir" -ForegroundColor Red
            }
        } else {
            $destinationDir = Split-Path $destination -Parent
            if (-not (Test-Path $destinationDir)) {
                New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
            }
            Copy-Item -Path $FullPath -Destination $destination -Force
            Write-Host "[$timestamp] $ChangeType`: $relativePath -> $targetDir" -ForegroundColor Cyan
        }
    }
}

Write-Host ""
Write-Host "=== ProfessionMaster File Watcher ===" -ForegroundColor Yellow
Write-Host "Source: $SourcePath" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop." -ForegroundColor Yellow
Write-Host ""

# Initial sync: copy all non-excluded files to targets
Write-Host "Performing initial sync..." -ForegroundColor Yellow
Get-ChildItem -Path $SourcePath -Recurse -File | ForEach-Object {
    Copy-ToTargets $_.FullName "Synced"
}
Write-Host "Initial sync complete." -ForegroundColor Green
Write-Host ""

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $SourcePath
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true
$watcher.NotifyFilter = [System.IO.NotifyFilters]::FileName -bor
                         [System.IO.NotifyFilters]::DirectoryName -bor
                         [System.IO.NotifyFilters]::LastWrite

$onChange = Register-ObjectEvent $watcher "Changed" -Action { Copy-ToTargets $Event.SourceEventArgs.FullPath "Changed" }
$onCreate = Register-ObjectEvent $watcher "Created" -Action { Copy-ToTargets $Event.SourceEventArgs.FullPath "Created" }
$onDelete = Register-ObjectEvent $watcher "Deleted" -Action { Copy-ToTargets $Event.SourceEventArgs.FullPath "Deleted" }
$onRenamed = Register-ObjectEvent $watcher "Renamed" -Action { Copy-ToTargets $Event.SourceEventArgs.FullPath "Renamed" }

try {
    while ($true) { Start-Sleep -Seconds 1 }
} finally {
    $watcher.EnableRaisingEvents = $false
    Unregister-Event -SourceIdentifier $onChange.Name
    Unregister-Event -SourceIdentifier $onCreate.Name
    Unregister-Event -SourceIdentifier $onDelete.Name
    Unregister-Event -SourceIdentifier $onRenamed.Name
    $watcher.Dispose()
    Write-Host "Watcher stopped." -ForegroundColor Yellow
}
