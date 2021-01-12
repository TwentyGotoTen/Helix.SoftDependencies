
function Get-Namespace
{
    Param(
        [System.IO.FileInfo]$csprojFile
    )   

    $fileContent = Get-Content $csprojFile.FullName -Raw

    $xml = [Xml]$fileContent 
    return $xml.Project.PropertyGroup.RootNameSpace[0]
}

function Get-NamespacesReferencedByConfigInDifferentFeature
{
    param (
        [System.IO.FileInfo]$configFile, 
        [System.IO.FileInfo[]]$csprojFiles, 
        [String] $featureRootPath
    )

    $configFeatureName =  Get-FeatureName $configFile $featureRootPath

    $configFilecontent = Get-Content $configFile.FullName -Raw

    $namespaceFeatureNames =  $csprojFiles | Select -Property @{ Name="NameSpace"; Expression= { (Get-NameSpace $_) }},
                                                              @{ Name="NamespaceFeatureName"; Expression= { (Get-FeatureName $_ $featureRootPath)}}
    $namespacesInOtherFeatures = $namespaceFeatureNames | Where { $_.NamespaceFeatureName -ne $configFeatureName }

    $foundNamespaceReferences = $namespacesInOtherFeatures  | Where { $configFilecontent.Contains($_.Namespace) } 

    return ($foundNamespaceReferences.Namespace)
}

function Get-ConfigsReferencingNamespaces
{
    Param(
        [String]$applicationRootPath,
        [String]$featureRootPath,
        [String]$configPath
    )

    $csprojFiles = Get-ChildItem -Path $applicationRootPath -Filter "*.csproj" -Recurse |
                   Where { $_.FullName -like ($applicationRootPath + "\" + $featureRootPath + "\*") }

    $featureConfigFiles = Get-ChildItem -Path $applicationRootPath -Filter "*.config" -Recurse | 
                          Where { $_.FullName -like ($applicationRootPath + "\" + $featureRootPath + "\*\" + $configPath + "\*") }

    $results = $featureConfigFiles | Select -Property  Name, 
                                                       @{ Name="ReferencedNamespace"; Expression= {  (Get-NamespacesReferencedByConfigInDifferentFeature $_ $csprojFiles $featureRootPath) -join "," } }  | 
                                     Where { $_.ReferencedNamespace -ne ""} 

    return $results;
}