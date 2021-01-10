Param(
    [Parameter(Position=0,mandatory=$true)]
    [String]$applicationRoothPath,

    $viewsRootPath = "Views",
    $featureRootPath = "src\Feature"
)

. $PSScriptRoot\Tasks\SharedFunctions.ps1
. $PSScriptRoot\Tasks\ViewsReferencingViews.ps1
. $PSScriptRoot\Tasks\ViewsReferencingControllers.ps1

# ---------------

$absoluteFeatureRootPath = $applicationRoothPath + "\" + $featureRootPath

if(!(Test-Path -Path $applicationRoothPath))
{
    Write-Host ("Application root path is invalid: " + $applicationRootPath) -ForegroundColor Red
    Exit 1
}

if(!(Test-Path -Path $absoluteFeatureRootPath))
{
    Write-Host ("Feature root path is invalid: " + $absoluteFeatureRootPath) -ForegroundColor Red
    Exit 1
}

# ---------------

Set-Location $applicationRoothPath

$featureViewFiles = Get-ChildItem -Path . -Filter "*.cshtml" -Recurse | 
                    Where { $_.FullName -like $absoluteFeatureRootPath+ "\*" }

$viewResults = Get-ViewsReferencedByViewsInOtherFeatures $featureViewFiles $viewsRootPath $featureRootPath


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

$controllerFiles = Get-ChildItem -Path . -Filter "*Controller.cs" -Recurse | 
                   Where {  $_.FullName -like "*\Feature\*" }


$controllerResults = Get-ControllersReferencedByViewsInOtherFeatures $featureViewFiles $controllerFiles $viewsRootPath $featureRootPath

If(($controllerResults | Measure-Object).Count -gt 0)
{
    Write-Host -ForegroundColor Red "Found views referencing controllers in other features."
    $controllerResults | Format-Table | Out-String | Write-Host
}
Else
{
    Write-Host -ForegroundColor Green "No views reference controllers in other features."
}


