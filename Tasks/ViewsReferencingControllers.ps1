function Get-CrossFeatureControllerReferences
{
    param (
        [System.IO.FileInfo]$viewFile, 
        [System.IO.FileInfo[]]$controllers, 
        [String] $featureRootPath
    )

    $viewFeatureName =  Get-FeatureName $viewFile $featureRootPath

    $filecontent = Get-Content $viewFile.FullName -Raw

    $controllerFeatureNames =  $controllers | Select -Property Name,@{ Name="ControllerFeatureName"; Expression= { (Get-FeatureName $_ $featureRootPath)}}

    $controllersInOtherFeatures = $controllerFeatureNames | Where { $_.ControllerFeatureName -ne $viewFeatureName }


    $candidateControllerReferences = $controllersInOtherFeatures | Select -Property Name,@{ Name="ReferenceString"; Expression= {"(`"" + (($_.Name).Replace("Controller.cs","")) + "`""} }

    $foundControllerReferences = $candidateControllerReferences  | Where { $filecontent.Contains($_.ReferenceString) } 

    return ($foundControllerReferences.Name) 
}

function Get-ControllersReferencedByViewsInOtherFeatures
{
    param (
        [System.IO.FileInfo[]]$viewFiles, 
        [System.IO.FileInfo[]]$controllers, 
        [String]$viewsRootPath, 
        [String]$featureRootPath
    )

    $results = $featureViewFiles | Select -Property  @{ Name="View"; Expression= { (Get-ViewsPath $_ $viewsRootPath) }}, 
                                                     @{ Name="ReferencedControllers"; Expression= {  (Get-CrossFeatureControllerReferences $_ $controllerFiles $featureRootPath) -join "," } }  | 
                                            Where { $_.ReferencedControllers -ne ""} 

    return $results;
}