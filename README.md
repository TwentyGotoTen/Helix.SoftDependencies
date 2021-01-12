# Helix.SoftDependencies
Script to find soft dependencies in Sitecore Helix implementations

The script currently checks for:

- Feature views referencing views in other features. This could either be via a partial or a statically bound view rendering.
- Feature views referencing controllers in other features via a statically bound controller rendering.
- Feature config files referencing type namespaces belonging to other features. 


Run **HelixSoftDependencies.ps1** passing the absolute root path of the Helix application as a parameter

**Optional additional parameters**
- *featureRootPath* (Default 'src\Feature') 
- *projectViewsPath* (Default 'Views') 
- *projectConfigPath* (Default 'App_Config\Include\Feature') 

## Notes
- The script assumes you have a ["standard" Helix solution structure](https://github.com/Sitecore/Helix.Examples/tree/master/examples/helix-basic-tds) using a project per module.
- The config/namespace check assumes that all the types within a module use the default namespace.
