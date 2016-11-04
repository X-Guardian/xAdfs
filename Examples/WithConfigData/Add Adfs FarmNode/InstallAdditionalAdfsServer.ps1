Configuration AddAdfsNode
{
    param
    (
        [pscredential]$AdfsCred,
        [pscredential]$StsCertPW,
        [pscredential]$DecCertPW,
        [pscredential]$SigCertPW
    )

    Import-DscResource -ModuleName xAdfs,xPfxCertificate

    Node $AllNodes.Where{$_.Role -eq 'Additional ADFS Server'}.NodeName
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

        xAdfsFarmNode Add-Adfs2
        {
            Name = $node.NodeName
            CertificateThumbprint = $node.AdfsServiceCommsCert
            ServiceAccountCredential = $AdfsCred
            SQLConnectionString = $node.SqlConnectionString
            Ensure = 'Present'
            DependsOn = '[WindowsFeature]InstallAdfs','[xImportPfxCertificate]STS','[xImportPfxCertificate]DEC','[xImportPfxCertificate]SIG'
        }
    }
}


$StsCertPW  = Get-Credential -Message "Enter the password that is used to secure the certificate used for ADFS service communication"
$DecCertPW  = Get-Credential -Message "Enter the password that is used to secure the certificate used for ADFS decryption"
$SigCertPW  = Get-Credential -Message "Enter the password that is used to secure the certificate used for ADFS signing"
$AdfsCred   = Get-Credential -Message "Enter the credentials for the ADFS service account"
$ConfigData = "$PSScriptRoot\InstallAdditionalAdfsServer-ConfigData.psd1"
$OutPutPath = "C:\InstallAdfs"

AddAdfsNode -OutputPath $OutPutPath -ConfigurationData $ConfigData -AdfsCred $AdfsCred -StsCertPW $StsCertPW -DecCertPW $DecCertPW -SigCertPW $SigCertPW

Set-DscLocalConfigurationManager -Path $OutPutPath -Verbose 
Start-DscConfiguration -Path $OutPutPath -Wait -Verbose -Force

