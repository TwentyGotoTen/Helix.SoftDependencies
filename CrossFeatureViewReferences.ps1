Param(
    $ViewsRootPath = "Views",
    $featureRootPath = "src\Feature"
)

# ---------------- Functions ----------------

function Get-FeaturePath([System.IO.FileInfo]$file)
{
    # Returns the path of the file relative to $featureRootPath
    $featurePathIndex = $file.FullName.IndexOf($featureRootPath) + $featureRootPath.Length + 1
    return $file.FullName.Substring($featurePathIndex,$file.FullName.Length - $featurePathIndex)
}

function Get-ViewsPath([System.IO.FileInfo]$file)
{
    # Returns the path of the file relative to $viewsRoothPath
    $viewsPathIndex = $file.FullName.IndexOf($ViewsRootPath) + $ViewsRootPath.Length + 1
    return $file.FullName.Substring($viewsPathIndex,$file.FullName.Length - $viewsPathIndex)
}

function Get-FeatureName([System.IO.FileInfo]$file)
{
    # Returns feature folder Name
    $featurePath = Get-FeaturePath $file
    $firstFolderEndIndex = $featurePath.IndexOf("\")   
    return $featurePath.Substring(0,$firstFolderEndIndex)
}

function Get-CrossFeatureViewReferences([System.IO.FileInfo]$viewFileToRead,  [System.IO.FileInfo[]]$featureViewFiles)
{
    $fileContent = Get-Content $viewFileToRead.FullName -Raw
    $normalizedFilecontent = $fileContent.Replace("/","\")
    $currentFeatureName = Get-FeatureName $viewFileToRead

    $viewFilesInOtherFeatures = $featureViewFiles | Where { (Get-FeatureName $_) -ne $currentFeatureName }

    $pathsToLookFor = $viewFilesInOtherFeatures | Select -Property @{ Name="ViewsPath"; Expression= { Get-ViewsPath $_ }} 

    $foundPaths = $pathsToLookFor | Where { $normalizedFilecontent.Contains( $_.ViewsPath ) } 

    return ($foundPaths.ViewsPath) 
}


# ---------------- Execution ----------------

$currentLocation = (Get-Location).Path
$absoluteFeatureRootPath = $currentLocation + "\" + $featureRootPath

# Get all cshtml files that are within Feature modules 

$allViewFiles = Get-ChildItem -Path . -Filter "*.cshtml" -Recurse

$featureViewFiles = $allViewFiles | Where { $_.FullName -like $absoluteFeatureRootPath+ "\*" }

$results = $featureViewFiles | Select-Object -Property  @{ Name="View"; Expression= { (Get-ViewsPath $_) }}, 
                                                @{ Name="ReferencedViews"; Expression= {  (Get-CrossFeatureViewReferences $_ $viewFiles) -join "," }  }

$naughtyResults = $results | Where { $_.ReferencedViews -ne ""} 


Write-Output $naughtyResults
