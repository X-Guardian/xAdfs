function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.Management.Automation.PSCredential]
		$Credential,

		[parameter(Mandatory = $true)]
		[System.String]
		$DecryptionCertificateThumbprint,

		[parameter(Mandatory = $true)]
		[System.String]
		$FederationServiceName,

		[parameter(Mandatory = $true)]
		[System.Management.Automation.PSCredential]
		$ServiceAccountCredential,

		[parameter(Mandatory = $true)]
		[System.String]
		$SigningCertificateThumbprint,

        [System.String]
		$CertificateThumbprint,
		
		[System.String]
		$SQLConnectionString
	)

    $AdfsCert   = Get-AdfsCertificate
    $AdfsProps  = Get-AdfsProperties
	$AdfsSrvCIM = Get-CimInstance -ClassName Win32_Service -Filter "Name='adfssrv'"
	
        	
	$returnValue = @{
		CertificateThumbprint = ($AdfsCert | where CertificateType -eq 'Service-Communications').Thumbprint		
		DecryptionCertificateThumbprint = ($AdfsCert | where CertificateType -eq "Token-Decrypting").Thumbprint
		FederationServiceDisplayName = $AdfsProps.DisplayName
		FederationServiceName = $AdfsProps.HostName
		ServiceAccountCredential = $AdfsSrvCIM.StartName
		SigningCertificateThumbprint = ($AdfsCert | where CertificateType -eq "Token-Signing").Thumbprint
		SQLConnectionString = $AdfsProps.ArtifactDbConnection
		SSLPort = $AdfsProps.HttpsPort
		TlsClientPort = $AdfsProps.TlsClientPort
	}

	$returnValue
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[System.String]
		$CertificateThumbprint,

		[parameter(Mandatory = $true)]
		[System.Management.Automation.PSCredential]
		$Credential,

		[parameter(Mandatory = $true)]
		[System.String]
		$DecryptionCertificateThumbprint,

		[System.String]
		$FederationServiceDisplayName,

		[parameter(Mandatory = $true)]
		[System.String]
		$FederationServiceName,

		[System.String]
		$GroupServiceAccountIdentifier,

		[System.Boolean]
		$OverwriteConfiguration,

		[parameter(Mandatory = $true)]
		[System.Management.Automation.PSCredential]
		$ServiceAccountCredential,

		[parameter(Mandatory = $true)]
		[System.String]
		$SigningCertificateThumbprint,

		[System.String]
		$SQLConnectionString,

		[System.Int32]
		$SSLPort,

		[System.Int32]
		$TlsClientPort
	)
    
    $PSBoundParameters.Add('ErrorAction','Stop')

    try
    {        
        Install-AdfsFarm @PSBoundParameters
    }
    catch
    {
        if($_.exception.message -match 'Microsoft.IdentityServer.Diagnostic')
        {            
            Write-Warning "Missing required ADFS assemblies. System requires reboot"            
            $global:DSCMachineStatus = 1;
		    return
        }
        else
        {
            throw $_
        }
    }

    #Verify ADFS installation is successful by retrieving ADFS properties
    try
    {
        Write-Verbose "Verifying Adfs installation"
        $AdfsProps = Get-AdfsProperties -ErrorAction Stop
    }
    catch
    {
        Write-Warning $_
    }

    if($AdfsProps)
    {
        Write-Verbose "ADFS Properties found. Installation Successful"        
    }
    else
    {
        throw "ADFS properties not found.  Install failed."        
    }
}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[System.String]
		$CertificateThumbprint,

		[parameter(Mandatory = $true)]
		[System.Management.Automation.PSCredential]
		$Credential,

		[parameter(Mandatory = $true)]
		[System.String]
		$DecryptionCertificateThumbprint,

		[System.String]
		$FederationServiceDisplayName,

		[parameter(Mandatory = $true)]
		[System.String]
		$FederationServiceName,

		[System.String]
		$GroupServiceAccountIdentifier,

		[System.Boolean]
		$OverwriteConfiguration,

		[parameter(Mandatory = $true)]
		[System.Management.Automation.PSCredential]
		$ServiceAccountCredential,

		[parameter(Mandatory = $true)]
		[System.String]
		$SigningCertificateThumbprint,

		[System.String]
		$SQLConnectionString,

		[System.Int32]
		$SSLPort,

		[System.Int32]
		$TlsClientPort
	)

    #Verify ADFS properties can be retrived.  If ADFS properties is found it is assumed ADFS is installed.
    Try
    {
        $AdfsProps = Get-AdfsProperties -ErrorAction Stop
    }
    Catch
    {
        Write-Warning $_
    }


    If($AdfsProps)
    {
        Write-Verbose "ADFS Properties found."        
        return $true
    }
    Else
    {
        Write-Verbose "ADFS properties not found"
        return $false
    }
}


Export-ModuleMember -Function *-TargetResource

