$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")


Describe "xAdfsRelyingPartyTrust" {
    
    Mock Export-ModuleMember {return $true}   
    . "$here\$sut"
    
    $Name = 'Outlook Web App'
    $TstRPTrst = Get-AdfsRelyingPartyTrust -Name $Name

    It "Test Test-TargetResource Parameter Ensure Present" {
        $TstEnsure = Test-TargetResource -Name $Name -Ensure 'Present'
        $TstEnsure | Should Be $true
    }
    It "Test Test-TargetResource Parameter Ensure Absent" {
        $TstEnsure = Test-TargetResource -Name $Name -Ensure 'absent'
        $TstEnsure | Should Be $false
    }
}
