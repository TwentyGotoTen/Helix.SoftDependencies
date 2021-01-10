function Get-CrossFeatureViewReferences
{
    Param (
        [System.IO.FileInfo]$viewFileToRead,  
        [System.IO.FileInfo[]]$featureViewFiles, 
        [String]$featureRootPath
    )

    $fileContent = Get-Content $viewFileToRead.FullName -Raw
    $normalizedFilecontent = $fileContent.Replace("/","\")
    $currentFeatureName = Get-FeatureName $viewFileToRead $featureRootPath

    $viewFilesInOtherFeatures = $featureViewFiles | Where { (Get-FeatureName $_ $featureRootPath) -ne $currentFeatureName }

    $pathsToLookFor = $viewFilesInOtherFeatures | Select -Property @{ Name="ViewsPath"; Expression= { Get-ViewsPath $_ $ViewsRootPath }} 

    $foundPaths = $pathsToLookFor | Where { $normalizedFilecontent.Contains( $_.ViewsPath ) } 

    return ($foundPaths.ViewsPath) 
}

function Get-ViewsReferencedByViewsInOtherFeatures
{
    param (
        [System.IO.FileInfo[]]$viewFiles, 
        [String] $viewsRootPath,
        [String] $featureRootPath
    )

    $results = $viewFiles | Select -Property  @{ Name="View"; Expression= { (Get-ViewsPath $_ $viewsRootPath) }}, 
                                              @{ Name="ReferencedViews"; Expression= {  (Get-CrossFeatureViewReferences $_ $viewFiles $featureRootPath) -join "," }  } |
                            Where { $_.ReferencedViews -ne ""} 

    return $results
}
