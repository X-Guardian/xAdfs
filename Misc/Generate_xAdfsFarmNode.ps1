$Name = New-xDscResourceProperty -Name Name -Type String -Attribute Key -Description "A unique identifier to distinguish additional ADFS nodes."
$CertificateThumbprint = New-xDscResourceProperty -Name CertificateThumbprint -Type String -Attribute Write -Description "Specifies the value of the certificate thumbprint of the certificate that should be used in the SSL binding of the Default Web Site in IIS. This value should match the thumbprint of a valid certificate in the Local Computer certificate store."
$GroupServiceAccountIdentifier = New-xDscResourceProperty -Name GroupServiceAccountIdentifier -Type String -Attribute Write -Description "Specifies the Group Managed Service Account under which the Active Directory Federation Services (AD FS) service runs."
$OverwriteConfiguration = New-xDscResourceProperty -Name OverwriteConfiguration -Type Boolean -Attribute Write -Description "This parameter must be used to remove an existing AD FS configuration database and overwrite it with a new database."
$PrimaryComputerName = New-xDscResourceProperty -Name PrimaryComputerName -Type String -Attribute Write -Description "Specifies the name of the primary in a farm. The cmdlet adds the computer to the farm that has the primary that you specify."
$PrimaryComputerPort = New-xDscResourceProperty -Name PrimaryComputerPort -Type Sint32 -Attribute Write -Description "Specifies the primary computer port. The computer uses the HTTP port that you specify to connect with the primary computer in order to synchronize configuration settings. Specify a value of 80 for this parameter, or specify an alternate value if the HTTP port on the primary computer is not 80. If this parameter is not specified, a default port value of 443 is assumed."
$ServiceAccountCredential = New-xDscResourceProperty -Name ServiceAccountCredential -Type PSCredential -Attribute Write -Description "Specifies the Active Directory account under which the AD FS service runs. All nodes in the farm must use the same service account."
$Ensure = New-xDscResourceProperty -Name Ensure -Type String -Attribute Required -ValidateSet 'Present','Absent' -Description "Specifies to either add (Present) or remove (Absent) the AdfsFarmNode"
$SqlConnStng = New-xDscResourceProperty -Name SQLConnectionString -Type String -Attribute Write -Description "Specifies the SQL Server database that will store the AD FS configuration settings. If not specified, AD FS uses Windows Internal Database to store configuration settings"

$AdfsFarmNodeParams = @{
    Name = 'MSFT_xAdfsFarmNode'
    Property = $Name,$CertificateThumbprint,$GroupServiceAccountIdentifier,$OverwriteConfiguration,$PrimaryComputerName,$PrimaryComputerPort,$ServiceAccountCredential,$Ensure,$SqlConnStng
    FriendlyName = 'xAdfsFarmNode'
    ModuleName = 'xAdfs'
    Path = 'C:\Program Files\WindowsPowerShell\Modules\'
}

New-xDscResource @AdfsFarmNodeParams