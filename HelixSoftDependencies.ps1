Param(
    [Parameter(Position=0,mandatory=$true)]
    [String]$applicationRootPath,

    [String]$featureRootPath = "src\Feature",
    [String]$projectViewsPath = "Views",
    [String]$projectConfigPath = "App_Config\Include\Feature"
)

. $PSScriptRoot\Tasks\SharedFunctions.ps1
. $PSScriptRoot\Tasks\ViewsReferencingViews.ps1
. $PSScriptRoot\Tasks\ViewsReferencingControllers.ps1
. $PSScriptRoot\Tasks\ConfigsReferencingNamespaces.ps1

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

$viewResults = Get-ViewsReferencingViews $applicationRootPath $projectViewsPath $featureRootPath

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

$controllerResults = Get-ViewsReferencingControllers $applicationRootPath $projectViewsPath $featureRootPath

If(($controllerResults | Measure-Object).Count -gt 0)
{
    Write-Host -ForegroundColor Red "Found views referencing controllers in other features."
    $controllerResults | Format-Table | Out-String | Write-Host
}
Else
{
    Write-Host -ForegroundColor Green "No views reference controllers in other features."
}

# --------------------

$configResults = Get-ConfigsReferencingNamespaces $applicationRootPath $featureRootPath $projectConfigPath 

If(($configResults | Measure-Object).Count -gt 0)
{
    Write-Host -ForegroundColor Red "Found configs referencing namespaces in other features."
    $configResults | Format-Table | Out-String | Write-Host
}
Else
{
    Write-Host -ForegroundColor Green "No configs reference namespaces in other features."
}