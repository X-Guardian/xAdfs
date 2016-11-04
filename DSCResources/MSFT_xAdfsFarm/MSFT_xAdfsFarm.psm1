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

		[System.String]
		$FederationServiceDisplayName,

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

    $adfsCert   = Get-AdfsCertificate
    $adfsProperties  = Get-AdfsProperties
    $adfsService = Get-CimInstance -ClassName Win32_Service -Filter "Name='adfssrv'"
                
    $returnValue = @{
        CertificateThumbprint = ($adfsCert | where CertificateType -eq 'Service-Communications').Thumbprint        
        DecryptionCertificateThumbprint = ($adfsCert | where CertificateType -eq "Token-Decrypting").Thumbprint
        FederationServiceDisplayName = $adfsProperties.DisplayName
        FederationServiceName = $adfsProperties.HostName
        ServiceAccountCredential = $adfsService.StartName
        SigningCertificateThumbprint = ($adfsCert | where CertificateType -eq "Token-Signing").Thumbprint
        SQLConnectionString = $adfsProperties.ArtifactDbConnection
        SSLPort = $adfsProperties.HttpsPort
        TlsClientPort = $adfsProperties.TlsClientPort
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
        if ($_.exception.message -match 'Microsoft.IdentityServer.Diagnostic')
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
        $adfsProperties = Get-AdfsProperties -ErrorAction Stop
    }
    catch
    {
        Write-Warning $_
    }

    if ($adfsProperties)
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
    try
    {
        $adfsProperties = Get-AdfsProperties -ErrorAction Stop
    }
    catch
    {
        Write-Warning $_
    }

    if ($adfsProperties)
    {
        Write-Verbose "ADFS Properties found."        
        return $true
    }
    else
    {
        Write-Verbose "ADFS properties not found"
        return $false
    }
}

Export-ModuleMember -Function *-TargetResource

