# Check if all phases in task_plan.md are complete
# Exit 0 when all phases complete, exit 1 when incomplete (Stop hook can block)
# Used by Stop hook to gate session termination

param(
    [string]$PlanFile = "task_plan.md"
)

if (-not (Test-Path $PlanFile)) {
    Write-Host '[plan] No task_plan.md found -- no active planning session.'
    exit 0
}

# Read file content
$content = Get-Content $PlanFile -Raw

# Count total phases
$TOTAL = ([regex]::Matches($content, "### Phase")).Count

# Check for **Status:** format first
$COMPLETE = ([regex]::Matches($content, "\*\*Status:\*\* complete")).Count
$IN_PROGRESS = ([regex]::Matches($content, "\*\*Status:\*\* in_progress")).Count
$PENDING = ([regex]::Matches($content, "\*\*Status:\*\* pending")).Count

# Fallback: check for [complete] inline format if **Status:** not found
if ($COMPLETE -eq 0 -and $IN_PROGRESS -eq 0 -and $PENDING -eq 0) {
    $COMPLETE = ([regex]::Matches($content, "\[complete\]")).Count
    $IN_PROGRESS = ([regex]::Matches($content, "\[in_progress\]")).Count
    $PENDING = ([regex]::Matches($content, "\[pending\]")).Count
}

# Report status and exit with appropriate code
if ($COMPLETE -eq $TOTAL -and $TOTAL -gt 0) {
    Write-Host ('[plan] ALL PHASES COMPLETE (' + $COMPLETE + '/' + $TOTAL + ')')
    exit 0
} else {
    Write-Host ('[plan] Task in progress (' + $COMPLETE + '/' + $TOTAL + ' phases complete)')
    if ($IN_PROGRESS -gt 0) {
        Write-Host ('[plan] ' + $IN_PROGRESS + ' phase(s) still in progress.')
    }
    if ($PENDING -gt 0) {
        Write-Host ('[plan] ' + $PENDING + ' phase(s) pending.')
    }
    Write-Host '[plan] WARNING: Not all phases complete — session should not end yet.'
    exit 1
}
