$ErrorActionPreference = "Stop"

add-type -Path "$psscriptroot\Dlls\newtonsoft.json.dll"
add-type -Path "$psscriptroot\Dlls\AzureDeploymentEngine.dll"

#gci $psscriptroot\StructFunctions\*.ps1 | % { . $_.FullName }
#gci $psscriptroot\StructDefinitions\*.ps1 | % { . $_.FullName }

#gci $psscriptroot\PostInstallScripts\*.ps1 | % { . $_.FullName }

gci $psscriptroot\Nikolic-AzureHelpers\*.ps1 | % { . $_.FullName }
gci $psscriptroot\ObjectFunctions2.ps1 | % { . $_.FullName }
gci $psscriptroot\JsonFunctions.ps1 | % { . $_.FullName }
gci $psscriptroot\Invoke-AzdeEnvironment.ps1 | % { . $_.FullName }
gci $psscriptroot\Get-AzdeIntResultingSetting.ps1 | % { . $_.FullName }
gci $psscriptroot\Enable-AzdeAzureSubscription.ps1 | % { . $_.FullName }
gci $psscriptroot\iaas\*.ps1 | % { . $_.FullName }
gci $psscriptroot\helperfunctions\*.ps1 | % { . $_.FullName }
gci $psscriptroot\AssertFunctions\*.ps1 | % { . $_.FullName }
#Write-Output "This is the Azure Deployment Engine. Some code kindly borrowed from Aleksandar Nikolic"