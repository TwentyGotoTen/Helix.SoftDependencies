Param(
    [Parameter(Position=0,mandatory=$true)]
    [String]$projectRoothPath,

    $viewsRootPath = "Views",
    $featureRootPath = "src\Feature"
)

. $PSScriptRoot\CrossFeatureViewReferences.ps1
. $PSScriptRoot\CrossFeatureControllerReferences.ps1

Set-Location $projectRoothPath

# ---------------

$absoluteFeatureRootPath = $projectRoothPath + "\" + $featureRootPath

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


