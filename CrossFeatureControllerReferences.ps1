Param(
    $ViewsRootPath = "Views",
    $featureRootPath = "src\Feature"
)

# ---------------- Functions ----------------

function Get-ViewsPath([System.IO.FileInfo]$file)
{
    $viewsPathIndex = $file.FullName.IndexOf($ViewsRootPath) + $ViewsRootPath.Length + 1
    return $file.FullName.Substring($viewsPathIndex,$file.FullName.Length - $viewsPathIndex)
}

function Get-FeatureName([System.IO.FileInfo]$file)
{
    $featurePathIndex = $file.FullName.IndexOf($featureRootPath) + $featureRootPath.Length + 1
    $featurePath = $file.FullName.Substring($featurePathIndex,$file.FullName.Length - $featurePathIndex)
    $currentFeatureFolderEndIndex = $featurePath.IndexOf("\")   
    return $featurePath.Substring(0,$currentFeatureFolderEndIndex)
}

function Get-CrossFeatureControllerReferences
{
    param ([System.IO.FileInfo]$viewFile, [System.IO.FileInfo[]]$controllers)

    $viewFeatureName =  Get-FeatureName($viewFile)
    $filecontent = Get-Content $viewFile.FullName -Raw

    $controllerFeatureNames =  $controllers | Select -Property Name,@{ Name="ControllerFeatureName"; Expression= {Get-FeatureName($_)}}

    $controllersInOtherFeatures = $controllerFeatureNames | Where { $_.ControllerFeatureName -ne $viewFeatureName }

    $candidateControllerReferences = $controllersInOtherFeatures | Select -Property Name,@{ Name="ReferenceString"; Expression= {"(`"" + (($_.Name).Replace("Controller.cs","")) + "`""} }

    $foundControllerReferences = $candidateControllerReferences  | Where { $filecontent.Contains($_.ReferenceString) } 

    return ($foundControllerReferences.Name) 
}

# ---------------- Execution ----------------

$currentLocation = (Get-Location).Path
$absoluteFeatureRootPath = $currentLocation + "\" + $featureRootPath

# Get all cshtml files that are within Feature modules 
$allViewFiles = Get-ChildItem -Path . -Filter "*.cshtml" -Recurse
$featureViewFiles = $allViewFiles | Where { $_.FullName -like $absoluteFeatureRootPath + "\*" }

# Get all controller files that are within Feature module 
$controllerFiles = Get-ChildItem -Path . -Filter "*Controller.cs" -Recurse | 
                   Where {  $_.FullName -like "*\Feature\*" }


$results= ($featureViewFiles | Select -Property  @{ Name="View"; Expression= { (Get-ViewsPath $_) }}, 
                                                 @{ Name="ReferencedControllers"; Expression= {  (Get-CrossFeatureControllerReferences $_ $controllerFiles) -join "," } } | 
                    Where { $_.ReferencedControllers -ne ""}) 

Write-Output $results 

