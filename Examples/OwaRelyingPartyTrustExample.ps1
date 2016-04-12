Configuration OwaRelyingPartyTrust
{

    Import-DscResource -Module xAdfs

    Node $AllNodes.Where{$_.Role -eq 'First ADFS Server'}.NodeName
    {
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
    }
}

$ConfigData = @{
    AllNodes = @(
       @{
            NodeName = 'Adfs1.fabrikam.com'
            Role = 'First ADFS Server'
            OwaUrl = "https://mail.fabrikam.com/owa"
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

OwaRelyingPartyTrust -OutputPath C:\DSC -ConfigurationData $ConfigData
Start-DscConfiguration -Path C:\DSC -Wait -Force -Verbose

