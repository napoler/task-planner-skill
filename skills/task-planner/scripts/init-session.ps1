# Initialize planning files for a new session
# Usage: .\init-session.ps1 [project-name]
#
# Template priority (per-file):
#   1. {project}\.claude\plan-templates\{filename}  (project-level, optional)
#   2. $HOME\.claude\skills\plan\templates\{filename} (built-in fallback)
#
# Path resolution: look for .claude/plan-templates/ by traversing upward from CWD

param(
    [string]$ProjectName = "project"
)

$DATE = Get-Date -Format "yyyy-MM-dd"

# Find project-level templates: traverse upward from CWD to find .claude\plan-templates
function Find-ProjectTemplates {
    $dir = Get-Location
    while ($dir -and $dir.Path -ne "/") {
        $testPath = Join-Path $dir ".claude\plan-templates"
        if (Test-Path $testPath -PathType Container) {
            return $testPath
        }
        $dir = $dir.Parent
    }
    return $null
}

# Copy a template file: project-level if exists, else built-in
function Copy-Template {
    param([string]$Filename)

    $projectTemplates = Find-ProjectTemplates
    $builtinPath = Join-Path $HOME ".claude\skills\plan\templates\$Filename"

    if ($projectTemplates) {
        $projectPath = Join-Path $projectTemplates $Filename
        if (Test-Path $projectPath) {
            Copy-Item $projectPath $Filename
            Write-Host "  $Filename (project-level)"
            return $true
        }
    }

    if (Test-Path $builtinPath) {
        Copy-Item $builtinPath $Filename
        Write-Host "  $Filename (built-in)"
        return $true
    }

    Write-Host "  $Filename : no template found, skipping"
    return $false
}

Write-Host "Initializing planning files for: $ProjectName"

# Check for project-level templates
$projectTemplates = Find-ProjectTemplates
if ($projectTemplates) {
    Write-Host "Using project templates: $projectTemplates"
} else {
    Write-Host "No project-level templates found, using built-in defaults"
    Write-Host "  (Add .claude\plan-templates\ to your project for custom templates)"
}
Write-Host ""

# Initialize each template file (only if it doesn't exist)
foreach ($file in @("task_plan.md", "findings.md", "progress.md", "notepad-learnings.md")) {
    if (Test-Path $file) {
        Write-Host "$file already exists, skipping"
    } else {
        if (Copy-Template $file) {
            Write-Host "    Created $file"
        }
    }
}

Write-Host ""
Write-Host "Planning files initialized!"
