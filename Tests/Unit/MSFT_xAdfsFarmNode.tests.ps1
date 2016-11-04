
$Global:DSCModuleName      = 'xAdfs'
$Global:DSCResourceName    = 'MSFT_xAdfsFarmNode'

#region HEADER
# Unit Test Template Version: 1.1.0
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
    #region Pester Test Initialization
            $password = ConvertTo-SecureString -String password1 -AsPlainText -Force
            $adfsCred = New-Object System.Management.Automation.PSCredential ('contoso\admin',$password)
            $testParameters = @{
                Name                     = "Add-Adfs2"
                CertificateThumbprint    = "6F7E9F5543505B943FEEA49E651EDDD8D9D45011"
                ServiceAccountCredential = $adfsCred
                PrimaryComputerName      = 'Adfs1'
            }
    InModuleScope $Global:DSCResourceName  {
        #region 

        Describe "ADFS Farm does not exist but should" {


            Context 'Testing Get-TargetResource' {
                It 'Get-TargetResource should return Ensure is Absent' {
                    Mock Get-Service -MockWith {}
                    (Get-TargetResource -Name $testParameters.Name -Ensure Present).Ensure | Should be 'Absent'
                }
                It 'Get-TargetResource should return Ensure is Present' {
                    Mock Get-Service -MockWith {@{Status = 'Running'}}
                    (Get-TargetResource -Name $testParameters.Name -Ensure Present).Ensure | Should be 'Present'
                }
            }
            Context 'Testing Test-TargetResource' {

                It 'Test-TargetResource returns False when Ensure is Present' {
                    $copiedParameters = $testParameters.Clone()
                    $copiedParameters.Add('Ensure','Present')
                    Mock Get-Service -MockWith {}
                    Test-TargetResource @copiedParameters | should be $false
                }
                It 'Test-TargetResource returns FALSE when Ensure is Absent' {
                    $copiedParameters = $testParameters.Clone()
                    $copiedParameters.Add('Ensure','Absent')
                    Mock Get-Service -MockWith {@{Status = 'Running'}}
                    Test-TargetResource @copiedParameters | should be $false
                }
            }
            Context 'Assert Set-TargetResource call expected mocks' {
                It 'Should call Add-AdfsFarmNode' {
                    $copiedParameters = $testParameters.Clone()
                    $copiedParameters.Add('Ensure','Present')
                    Mock Add-AdfsFarmNode -MockWith {@{Status = 'Success'}}
                    Set-TargetResource @copiedParameters

                    Assert-MockCalled Add-AdfsFarmNode -Exactly 1
                }
                It 'Should call Uninstall-WindowsFeature' {
                    $copiedParameters = $testParameters.Clone()
                    $copiedParameters.Add('Ensure','Absent')
                    Mock Uninstall-WindowsFeature -MockWith {}
                    Set-TargetResource @copiedParameters
                }

            }

        }
    
    #endregion

    #region
        Describe "The system is in the desired state" {
            It 'Test-TargetResource should return TRUE when Ensure is Present' {
                $copiedParameters = $testParameters.Clone()
                $copiedParameters.Add('Ensure','Present')
                Mock Get-Service -MockWith {@{Status = 'Running'}}
                Test-TargetResource @copiedParameters | should be $True
            }
            It 'Test-TargetResource should return TRUE when Ensure is Absent' {
                $copiedParameters = $testParameters.Clone()
                $copiedParameters.Add('Ensure','Absent')
                Mock Get-Service -MockWith {$null}
                Test-TargetResource @copiedParameters | should be $True
            }

    }
    #endregion
}
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}

