<#
.Synopsis
   Template for creating DSC Resource Unit Tests
.DESCRIPTION
   To Use:
     1. Copy to \Tests\Unit\ folder and rename <ResourceName>.tests.ps1 (e.g. MSFT_xFirewall.tests.ps1)
     2. Customize TODO sections.

.NOTES
   Code in HEADER and FOOTER regions are standard and may be moved into DSCResource.Tools in
   Future and therefore should not be altered if possible.
#>


$Global:DSCModuleName   = 'xAdfs'
$Global:DSCResourceName = 'MSFT_xAdfsFarm'

#region HEADER

[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit 
#endregion HEADER

# Begin Testing
try
{ 
    InModuleScope 'MSFT_xAdfsFarm' {
        Describe "ADFS Farm does not exist but should" {
            $password = ConvertTo-SecureString -String password1 -AsPlainText -Force
            $adfsCred = New-Object System.Management.Automation.PSCredential ('contoso\admin',$password)
            $testParameters = @{
                FederationServiceName           = "sts.contoso.com"
                FederationServiceDisplayName    = "Contoso Users"
                CertificateThumbprint           = "6F7E9F5543505B943FEEA49E651EDDD8D9D45011"
                DecryptionCertificateThumbprint = "6F7E9F5543505B943FEEA49E651EDDD8D9D45012"
                SigningCertificateThumbprint    = "6F7E9F5543505B943FEEA49E651EDDD8D9D45013"
                ServiceAccountCredential        = $adfsCred
                Credential                      = $adfsCred
            }

            $mockAdfsCert = @(
                @{
                    CertificateType = 'Service-Communications'
                    Thumbprint      = '6F7E9F5543505B943FEEA49E651EDDD8D9D45011'
                }
                @{
                    CertificateType = 'Token-Decrypting'
                    Thumbprint      = '6F7E9F5543505B943FEEA49E651EDDD8D9D45012'        
                }
                @{
                    CertificateType = 'Token-Signing'
                    Thumbprint      = '6F7E9F5543505B943FEEA49E651EDDD8D9D45013'        
                }
            )

            $mockAdfsProperties = @{
                DisplayName = $testParameters.FederationServiceDisplayName
                HostName    = $testParameters.FederationServiceName            
            }
            $mockCimService = @{
                StartName = $adfsCred.UserName
            }        
            
            Mock -CommandName Get-AdfsCertificate -MockWith { $mockAdfsCert}
            Mock -CommandName Get-CimInstance     -MockWith {$mockCimService}
            Mock -CommandName Get-AdfsProperties  -MockWith {$mockAdfsProperties}
            Mock -CommandName Install-AdfsFarm    -MockWith {}

            $getResult = Get-TargetResource @testParameters
    
            foreach ($parameter in $testParameters.keys) 
            {
                if ($parameter -eq 'ServiceAccountCredential')
                {
                    $getResult[$parameter]| should be ($testParameters[$parameter]).UserName
                }
                elseIf ($parameter -ne 'Credential')
                {
                    It "Testing Get method parameter $parameter  match" {
                        $getResult[$parameter] | Should be $testParameters[$parameter]
                    } 
                }
            }
                
            It "Test method returns false" {
                Mock -CommandName Get-AdfsProperties -MockWith {}
                Test-TargetResource @testParameters | Should be $false
            }

            It "Set method calls Install-AdfsFarm" {
                Mock -CommandName Get-AdfsProperties  -MockWith {$mockAdfsProperties}
                Set-TargetResource @testParameters

                Assert-MockCalled Install-AdfsFarm -Exactly 1 
            }
        }
    }
    #endregion

    #region
    Describe "The system is in the desired state" {

        $password = ConvertTo-SecureString -String password1 -AsPlainText -Force
        $adfsCred = New-Object System.Management.Automation.PSCredential ('contoso\admin',$password)
        $testParameters = @{
            FederationServiceName           = "sts.contoso.com"
            FederationServiceDisplayName    = "Contoso Users"
            CertificateThumbprint           = "6F7E9F5543505B943FEEA49E651EDDD8D9D45011"
            DecryptionCertificateThumbprint = "6F7E9F5543505B943FEEA49E651EDDD8D9D45012"
            SigningCertificateThumbprint    = "6F7E9F5543505B943FEEA49E651EDDD8D9D45013"
            ServiceAccountCredential = $adfsCred
            Credential = $adfsCred
        }

        $mockAdfsProperties = @{
            DisplayName = $testParameters.FederationServiceDisplayName
            HostName    = $testParameters.FederationServiceName            
        }

        It "Test method returns true" {
            Mock -CommandName Get-AdfsProperties -MockWith {return $mockAdfsProperties}
            Test-TargetResource @testParameters | Should be $true
        }
    }
    #endregion

}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}

