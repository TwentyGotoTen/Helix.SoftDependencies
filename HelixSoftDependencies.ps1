Param(
    [Parameter(Position=0,mandatory=$true)]
    [String]$applicationRootPath,

    $viewsRootPath = "Views",
    $featureRootPath = "src\Feature"
)

. $PSScriptRoot\Tasks\SharedFunctions.ps1
. $PSScriptRoot\Tasks\ViewsReferencingViews.ps1
. $PSScriptRoot\Tasks\ViewsReferencingControllers.ps1

# ---------------

if(!(Test-Path -Path $applicationRootPath))
{
    Write-Host ("Application root path is invalid: " + $applicationRootPath) -ForegroundColor Red
    Exit 1
}

if(!(Test-Path -Path ($applicationRootPath + "\" + $featureRootPath)))
{
    Write-Host ("Feature root path is invalid: " + $featureRootPath) -ForegroundColor Red
    Exit 1
}

# ---------------

$viewResults = Get-ViewsReferencingViews $applicationRootPath $viewsRootPath $featureRootPath

If(($viewResults | Measure-Object).Count -gt 0)
{
    Write-Host -ForegroundColor Red "Found views referencing views in other features."
    $viewResults | Format-Table | Out-String | Write-Host
}
Else
{
    Write-Host -ForegroundColor Green "No views reference views in other features."
}

# --------------------

$controllerResults = Get-ViewsReferencingControllers $applicationRootPath $viewsRootPath $featureRootPath

If(($controllerResults | Measure-Object).Count -gt 0)
{
    Write-Host -ForegroundColor Red "Found views referencing controllers in other features."
    $controllerResults | Format-Table | Out-String | Write-Host
}
Else
{
    Write-Host -ForegroundColor Green "No views reference controllers in other features."
}
