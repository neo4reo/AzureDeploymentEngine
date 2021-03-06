Function Assert-azdePostDeploymentScript
{
    Param (
        [AzureDeploymentEngine.Project]$Project,
        $AffinityGroupName,
        $vms,
        $storageaccount
    )

    #Get the projectname
    $projectname = $project.ProjectName

    #Get the post deployment scripts
    $PDscripts = $Project.PostDeploymentScripts
    $pdscripts = $PDscripts | Sort-Object Order

    #Foreach Script, get the VMs
    foreach ($pdscript in $PDscripts)
    {
        $pdscriptname = $pdscript.PostDeploymentScriptName
        Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "Executing Post-Deployment script $pdscriptname"
        
        #get the vmlist
        $pdscriptvms = $pdscript.VmNames
        foreach ($pdscriptvm in $pdscriptvms)
        {
            #If the VMs were already existing, check if the script is set to always rerun 
            
            #Case-insensitive string replace
            $vmrealname = [AzureDeploymentEngine.StringExtensions]::Replace($pdscriptvm,"projectname",$projectname,"OrdinalIgnoreCase")
            
            $vm = $null
            foreach ($LookupVm in $project.vms)
            {
                $LookupVmName = $LookupVm.VmName
                $RealLookupVmName = [AzureDeploymentEngine.StringExtensions]::Replace($pdscriptvm,"projectname",$projectname,"OrdinalIgnoreCase")
                if ($RealLookupVmName -eq $vmrealname)
                {
                    $vm = $LookupVm
                }

            }

            #Replaced with the code above for case-insensitivity
            #$vm = $Project.Vms | where {($_.VmName.replace("projectname",$project.ProjectName)) -eq $vmrealname}
            
            $jsonvm = $vm | ConvertTo-Json -Depth 10
            $vmobject = Import-AzdeVMConfiguration -string $jsonvm
            $vmobject.VmName = $vmrealname
            $deployedvm = $vms | where {$_.Name -eq $vmrealname}
            $scriptReRunsetting = $vmobject.VmSettings.AlwaysRerunScripts

            if (!($vmobject.VmSettings))
            {
                $vmobject.VmSettings = New-Object AzureDeploymentEngine.VmSetting
            }

            #If credentials arent set on the vm, get them from cascading project settings
            if (!($vmobject.VmSettings.DomainJoinCredential))
            {
                $vmobject.VmSettings.DomainJoinCredential = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "DomainJoinCredential" -SettingsType "VmSettings" -TargetObject "Project"
            }

            if (!($vmobject.VmSettings.LocalAdminCredential))
            {
                $vmobject.VmSettings.LocalAdminCredential = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "LocalAdminCredential" -SettingsType "VmSettings" -TargetObject "Project"
            }

            #If credentials are still empty, use the project's domain admin credentials
            if (!($vmobject.VmSettings.DomainJoinCredential))
            {
                $vmobject.VmSettings.DomainJoinCredential = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "DomainAdminCredential" -SettingsType "ProjectSettings" -TargetObject "Project"
            }

            if (!($vmobject.VmSettings.LocalAdminCredential))
            {
                $vmobject.VmSettings.LocalAdminCredential = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "DomainAdminCredential" -SettingsType "ProjectSettings" -TargetObject "Project"
            }



            #If this setting isnt set (not true, not false), look in cascading settings
            if ($scriptReRunsetting -eq $null)
            {
                $scriptReRunsetting = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "AlwaysRerunScripts" -SettingsType "VmSettings" -TargetObject "Project"
                if ($scriptReRunsetting -eq $null)
                {
                    $scriptReRunsetting = $false
                }
            }

            $DoRunScript = $false

            if (($deployedvm.AlreadyExistingVm) -and ($pdscript.AlwaysRerun -eq $true))
            {
                #If the postdeploymentscript alwaysrerun setting is true, always re-run the script even if the vm already existed.
                $DoRunScript = $true  
            }
            Elseif ($deployedvm.AlreadyExistingVm)
            {
                if ($scriptReRunsetting -eq $false)
                {
                    #VM was existing, and vm not set to always rerun scripts. Skipping
                    Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "VM $vmrealname was already existing, and not set to always rerun scripts. Skipping script execution"
                }
                Else
                {
                    $DoRunScript = $true
                }
            }
            Else
            {
                $DoRunScript = $true  
            }

            #fireup all the things
            if ($DoRunScript)
            {
                #Invoke script execution
                $thispds = New-Object AzureDeploymentEngine.PostDeploymentScript
                $thispds.PostDeploymentScriptName = $pdscriptname
                $thispds.VMs = $vmobject
                $thispds.Path = $pdscript.Path
                $thispds.PathType = $pdscript.PathType
                $thispds.RebootOnCompletion = $pdscript.RebootOnCompletion
                $thispds.CloudServiceName = $Deployedvm.ServiceName
                
                #Get the domain name for credentials
                $Addomainname = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "AdDomainName" -SettingsType "ProjectSettings" -TargetObject "Project"

                Invoke-PostDeploymentScript -PostDeploymentScript $thispds -storageaccount $storageaccount -artifactpath "$ArtifactPath\$($Project.ProjectName)\scripts" -adDomainName $Addomainname
            }

            
        }
    
    }



    

    



}