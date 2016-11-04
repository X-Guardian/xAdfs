function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )

    try
    {
        $AdfsSrv  = Get-Service -Name 'adfssrv' -ErrorAction Stop
    }
    catch
    {
        Write-Warning $_
    }

    if ($AdfsSrv.Status -eq 'Running')
    {
        $ensureResult = 'Present'
    }
    else
    {
        $ensureResult = 'Absent'
    }
    
    $returnValue = @{
        Name = $Name
        Ensure = $ensureResult        
    }


    $returnValue
    
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $CertificateThumbprint,

        [System.String]
        $GroupServiceAccountIdentifier,

        [System.Boolean]
        $OverwriteConfiguration,

        [System.String]
        $PrimaryComputerName,

        [System.Int32]
        $PrimaryComputerPort,

        [System.Management.Automation.PSCredential]
        $ServiceAccountCredential,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.String]
        $SQLConnectionString
    )

    $PSBoundParameters.Add('ErrorAction','Stop') | Out-Null
    $PSBoundParameters.Remove('Name')
    $PSBoundParameters.Remove('Ensure')

    if ($Ensure -eq 'Present')
    {
        try
        {
            Write-Verbose "Adding AdfsFarmNode"
            $AddNode = Add-AdfsFarmNode @PSBoundParameters

            if ($AddNode.Status -eq 'Success')
            {
                Write-Verbose "$($AddNode.Message)"
            }
            else
            {
                Write-Verbose "Installation failed"
                throw "$($AddNode.Message)"
            }
        }
        catch
        {
            throw $_
        }
    }
    else
    {
        Write-Verbose "Removing AdfsFarmNode"
        Uninstall-WindowsFeature -Name ADFS-Federation
    }

}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $CertificateThumbprint,

        [System.String]
        $GroupServiceAccountIdentifier,

        [System.Boolean]
        $OverwriteConfiguration,

        [System.String]
        $PrimaryComputerName,

        [System.Int32]
        $PrimaryComputerPort,

        [System.Management.Automation.PSCredential]
        $ServiceAccountCredential,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.String]
        $SQLConnectionString
    )

    try
    {
        $adfsService  = Get-Service -Name 'adfssrv' -ErrorAction Stop
    }
    catch
    {
        Write-Warning $_
    }

    if ($Ensure -eq 'Present')
    {
        if ($null -eq $adfsService  -or $adfsService.Status -ne 'Running')
        {
            Write-Verbose "ADFS service is not installed or not running"
            return $false
        }                
    }
    
    if ($null -ne $adfsService -and $Ensure -eq 'Absent')
    {
        Write-Verbose "Ensure: Present. Expected Absent"
        return $false
    }

    #If code made it this far node is in a desired state
    return $true
}


Export-ModuleMember -Function *-TargetResource

