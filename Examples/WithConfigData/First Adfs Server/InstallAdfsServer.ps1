Configuration InstallAdfsServer
{
    Param
    (
        [pscredential]$AdfsCred,
        [pscredential]$DomainCred,
        [pscredential]$StsCertPW,
        [pscredential]$DecCertPW,
        [pscredential]$SigCertPW
    )

    Import-DscResource -ModuleName xPfxCertificate,xAdfs
    Node $AllNodes.Where{$_.Role -eq 'First ADFS Server'}.NodeName
    {
        LocalConfigurationManager
        {
            CertificateId = $node.MofEncyptionCert
        }

        xImportPfxCertificate STS
        {
            Thumbprint = $node.AdfsServiceCommsCert
            FilePath = $node.adfsServiceCommsCertPath
            Exportable = $true
            Password = $StsCertPW
            CertStoreLocation = "Cert:\localmachine\My"
        }

        xImportPfxCertificate DEC
        {
            Thumbprint = $node.AdfsDecryptCert
            FilePath = $node.AdfsDecryptCertPath
            Exportable = $true
            Password = $DecCertPW
            CertStoreLocation = "Cert:\localmachine\My"
        }

        xImportPfxCertificate SIG
        {
            Thumbprint = $node.AdfsSigningCert
            FilePath = $node.AdfsSigningCertPath
            Exportable = $true
            Password = $SigCertPW
            CertStoreLocation = "Cert:\localmachine\My"
        }

        WindowsFeature InstallAdfs
        {
            Name = 'ADFS-Federation'
            Ensure = 'Present'            
        }

        xAdfsFarm FristAdfsServer
        {
            FederationServiceName = $node.FederationServiceName
            FederationServiceDisplayName = $node.FedServiceDisplayName
            CertificateThumbprint = $node.AdfsServiceCommsCert
            DecryptionCertificateThumbprint = $node.AdfsDecryptCert
            SigningCertificateThumbprint = $node.AdfsSigningCert
            SQLConnectionString = $node.SQLConnectionString
            ServiceAccountCredential = $AdfsCred
            Credential = $DomainCred
            DependsOn = '[WindowsFeature]InstallAdfs','[xImportPfxCertificate]STS','[xImportPfxCertificate]DEC','[xImportPfxCertificate]SIG'
        }   
    }

}



$StsCertPW  = Get-Credential -Message "Enter the password that is used to secure the certificate used for ADFS service communication"
$DecCertPW  = Get-Credential -Message "Enter the password that is used to secure the certificate used for ADFS decryption"
$SigCertPW  = Get-Credential -Message "Enter the password that is used to secure the certificate used for ADFS signing"
$AdfsCred   = Get-Credential -Message "Enter the credentials for the ADFS service account"
$DomainCred = Get-Credential -Message "Enter the credentials of a domain administrator"
$ConfigData = "$PSScriptRoot\InstallAdfsServer-ConfigData.psd1"
$OutPutPath = "C:\InstallAdfs"

InstallAdfsServer -StsCertPW $StsCertPW -DecCertPW $DecCertPW -SigCertPW $SigCertPW -AdfsCred $AdfsCred -DomainCred $DomainCred -ConfigurationData $ConfigData -OutputPath $OutPutPath
Set-DscLocalConfigurationManager -Path $OutPutPath -Verbose
Start-DscConfiguration -pat $OutPutPath -Wait -Verbose -Force