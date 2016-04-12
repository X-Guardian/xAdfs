Configuration AddAdfsNode
{
    param
    (
        [pscredential]$ServiceAccountCredential
    )

    Import-DscResource -ModuleName xAdfs

    Node $AllNodes.Where{$_.Role -eq 'Additional ADFS Server'}.NodeName
    {
        WindowsFeature InstallAdfs
        {
            Name = 'ADFS-Federation'
            Ensure = 'Present'
        }
        xAdfsFarmNode Add-Adfs2
        {
            Name = 'Add-Adfs2'
            CertificateThumbprint = '2C6A6926F05544C68B45EB75CD228D861320B46C'
            ServiceAccountCredential = $ServiceAccountCredential
            PrimaryComputerName = 'adfs1'
            OverwriteConfiguration = $true
            Ensure = 'Present'
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
            NodeName = 'ADFS2.fabrikam.com'
            Role = 'Additional ADFS Server'

         }
    )
}
If(!$fsCreds)
{
    $fsCreds = Get-Credential fabrikam\adfs_svc
}

AddAdfsNode -OutputPath C:\DSC -ConfigurationData $Config -ServiceAccountCredential $fsCreds

Start-DscConfiguration -Path C:\DSC -Wait -Verbose -Force

