$here = Split-Path -Parent $MyInvocation.MyCommand.Path

# should check for the server OS
if($env:APPVEYOR_BUILD_VERSION)
{
  Add-WindowsFeature Web-Server -Verbose
}

Import-Module (Join-Path $here -ChildPath "..\DSCResources\MSFT_xWebsite\MSFT_xWebsite.psm1")

Describe "MSFT_xWebBindingInformation" {
    It 'Should be able to get xWebsite' -test {
        # Force Cim Classes to register
        $tempModulePath = (Resolve-Path (join-path $here '..\..')).ProviderPath
        $env:PSModulePath = "$env:PSModulePath;$tempModulePath"
        Write-Verbose -message "newPsModulePath: $env:PSModulePath"  -Verbose
        
        $resources = Get-DscResource -Name xWebsite
        $resources.count | should be 1
    }
    
    $storeNames = (Get-CimClass -Namespace "root/microsoft/Windows/DesiredStateConfiguration" -ClassName "MSFT_xWebBindingInformation").CimClassProperties['CertificateStoreName'].Qualifiers['Values'].Value
    foreach ($storeName in $storeNames){
        It "Uses valid credential store: $storeName" {
            (Join-Path -Path Cert:\LocalMachine -ChildPath $storeName) | Should Exist
        }
    }
}
