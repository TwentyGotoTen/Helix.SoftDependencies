function Get-FeaturePath([System.IO.FileInfo]$file, [System.String]$featureRootPath)
{
    # Returns the path of the file relative to $featureRootPath
    $featurePathIndex = $file.FullName.IndexOf($featureRootPath) + $featureRootPath.Length + 1
    return $file.FullName.Substring($featurePathIndex,$file.FullName.Length - $featurePathIndex)
}

function Get-ViewsPath([System.IO.FileInfo]$file, [System.String]$viewsRootPath)
{
    # Returns the path of the file relative to $viewsRoothPath
    $viewsPathIndex = $file.FullName.IndexOf($viewsRootPath) + $viewsRootPath.Length + 1
    return $file.FullName.Substring($viewsPathIndex,$file.FullName.Length - $viewsPathIndex)
}

function Get-FeatureName([System.IO.FileInfo]$file, [System.String]$featureRootPath)
{
    # Returns feature folder Name
    $featurePath = Get-FeaturePath $file $featureRootPath
    $firstFolderEndIndex = $featurePath.IndexOf("\")   
    return $featurePath.Substring(0,$firstFolderEndIndex)
}