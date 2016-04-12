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

    Try
    {
        $AdfsSrv  = Get-Service -Name 'adfssrv' -ErrorAction Stop
    }
    Catch
    {
        Write-Warning $_
    }

    If($AdfsSrv.Status -eq 'Running')
    {
        $EnsureRslt = 'Present'
    }
    Else
    {
        $EnsureRslt = 'Absent'
    }


	<
	$returnValue = @{
		Name = $Name
		CertificateThumbprint = [System.String]
		GroupServiceAccountIdentifier = [System.String]
		OverwriteConfiguration = [System.Boolean]
		PrimaryComputerName = [System.String]
		PrimaryComputerPort = [System.Int32]
		ServiceAccountCredential = [System.Management.Automation.PSCredential]
		Ensure = $EnsureRslt
		SQLConnectionString = [System.String]
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

    If($Ensure -eq 'Present')
    {
        Try
        {
            Write-Verbose "Adding AdfsFarmNode"
            $AddNode = Add-AdfsFarmNode @PSBoundParameters

            If($AddNode.Status -eq 'Success')
            {
                Write-Verbose "$($AddNode.Message)"
            }
            Else
            {
                Write-Verbose "Installation failed"
                throw "$($AddNode.Message)"
            }
        }
        Catch
        {
            throw $_
        }
    }
    Else
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

    Try
    {
        $AdfsSrv  = Get-Service -Name 'adfssrv' -ErrorAction Stop
    }
    Catch
    {
        Write-Warning $_
    }

    If($Ensure -eq 'Present')
    {
        If($AdfsSrv -eq $null -or $AdfsSrv.Status -ne 'Running')
        {
            Write-Verbose "ADFS service is not installed or not running"
            return $false
        }                
    }
    
    If($AdfsSrv -ne $null -and $Ensure -eq 'Absent')
    {
        Write-Verbose "Ensure: Present. Expected Absent"
        return $false
    }

    #If code made it this far node is in a desired state
    return $true
}


Export-ModuleMember -Function *-TargetResource

