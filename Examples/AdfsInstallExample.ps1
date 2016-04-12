Configuration InstallAdfsServer
{
    Param
    (
        [pscredential]$AdfsCred,
        [pscredential]$DomainCred,
        [pscredential]$CertPassword
    )

    Import-DscResource -ModuleName xPfxCertificate,xCertificate,xAdfs
    Node $AllNodes.Where{$_.Role -eq 'First ADFS Server'}.NodeName
    {
        xImportPfxCertificate STS
        {
            Thumbprint = '933D8ACDD49CEF529EB159504C4095575E3496BB'
            FilePath = "C:\Certs\sts-fabrikam.pfx"
            Exportable = $true
            Password = $CertPassword
            CertStoreLocation = "Cert:\localmachine\My"
        }

        xImportPfxCertificate DEC
        {
            Thumbprint = '51776950E105D6B90C5D3FD1D0F78A8F3254A42A'
            FilePath = "C:\Certs\sts-dec-fabrikam.pfx"
            Exportable = $true
            Password = $CertPassword
            CertStoreLocation = "Cert:\localmachine\My"
        }

        xImportPfxCertificate SIG
        {
            Thumbprint = '25060B22188FD3CB4EFA771FF705998717E02281'
            FilePath = "C:\Certs\sts-sig-fabrikam.pfx"
            Exportable = $true
            Password = $CertPassword
            CertStoreLocation = "Cert:\localmachine\My"
        }
        xCertPrivateKeyPermission ApplyReadtoSts
        {
            Thumbprint = '933D8ACDD49CEF529EB159504C4095575E3496BB'
            Identity = 'fabrikam\adfs_svc'
            Rights = "Read"
            AccessControlType = 'Allow'
        }
        xCertPrivateKeyPermission ApplyReadtoDec
        {
            Thumbprint = '51776950E105D6B90C5D3FD1D0F78A8F3254A42A'
            Identity = 'fabrikam\adfs_svc'
            Rights = "Read"
            AccessControlType = 'Allow'
        }
        xCertPrivateKeyPermission ApplyReadtoSig
        {
            Thumbprint = '25060B22188FD3CB4EFA771FF705998717E02281'
            Identity = 'fabrikam\adfs_svc'
            Rights = "Read"
            AccessControlType = 'Allow'
        }
        WindowsFeature InstallAdfs
        {
            Name = 'ADFS-Federation'
            Ensure = 'Present'            
        }

        xAdfsFarm FristAdfsServer
        {
            FederationServiceName = 'sts.fabrikam.com'
            FederationServiceDisplayName = 'Fabrikam Users'
            CertificateThumbprint = '933D8ACDD49CEF529EB159504C4095575E3496BB'
            DecryptionCertificateThumbprint = '51776950E105D6B90C5D3FD1D0F78A8F3254A42A'
            SigningCertificateThumbprint = '25060B22188FD3CB4EFA771FF705998717E02281'
            SQLConnectionString = 'Data Source=Adfs1;Integrated Security=True'
            ServiceAccountCredential = $AdfsCred
            Credential = $DomainCred

        }
        xAdfsRelyingPartyTrust OwaInternal
        {
            Name = 'Outlook Web App'
            Ensure = 'Present'
            Enabled = $true           
            Notes = "This is a trust for $($node.owaURL)"
            WSFedEndpoint = $node.OwaUrl
            Identifier = $node.OwaUrl
            IssuanceTransformRules = $node.IssuanceTransformRules
            IssuanceAuthorizationRules  = $node.IssuanceAuthorizationRules            
        }
        xAdfsRelyingPartyTrust EcpInternal
        {
            Name = 'Exchange Admin Center (EAC)'
            Ensure = 'Present'
            Enabled = $true           
            Notes = "This is a trust for $($node.ecpURL)"
            WSFedEndpoint = $node.ecpURL
            Identifier = $node.ecpURL
            IssuanceTransformRules = $node.IssuanceTransformRules
            IssuanceAuthorizationRules  = $node.IssuanceAuthorizationRules            
        }    
    }

}


$Config = @{
        AllNodes = @(
        @{
            NodeName="*"
            PSDscAllowPlainTextPassword = $true            
         }
        @{
            NodeName = 'ADFS1.fabrikam.com'
            Role = 'First ADFS Server'
            OwaUrl = "https://mail.fabrikam.com/owa"
            EcpURL = "https://mail.fabrikam.com/ecp"
            IssuanceAuthorizationRules=@'
@RuleTemplate = "AllowAllAuthzRule"
 => issue(Type = "http://schemas.microsoft.com/authorization/claims/permit", Value = "true");
'@
            IssuanceTransformRules = @'
@RuleName = "ActiveDirectoryUserSID"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"]

=> issue(store = "Active Directory", types = ("http://schemas.microsoft.com/ws/2008/06/identity/claims/primarysid"), query = ";objectSID;{0}", param = c.Value); 

@RuleName = "ActiveDirectoryGroupSID"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"] 

=> issue(store = "Active Directory", types = ("http://schemas.microsoft.com/ws/2008/06/identity/claims/groupsid"), query = ";tokenGroups(SID);{0}", param = c.Value); 

@RuleName = "ActiveDirectoryUPN"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"] 

=> issue(store = "Active Directory", types = ("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn"), query = ";userPrincipalName;{0}", param = c.Value);
'@
            
         }
    )
}

$CertPassword = Get-Credential -Message "Enter the password that is used to secure the certificates"
$AdfsCred = Get-Credential -Message "Enter the credentials for the ADFS service account"
$DomainCred = Get-Credential -Message "Enter the credentials of a domain administrator"

InstallAdfsServer -CertPassword $CertPassword -AdfsCred $AdfsCred -DomainCred $DomainCred -ConfigurationData $Config -OutputPath C:\DSC
Start-DscConfiguration -pat c:\dsc -Wait -Verbose -Force