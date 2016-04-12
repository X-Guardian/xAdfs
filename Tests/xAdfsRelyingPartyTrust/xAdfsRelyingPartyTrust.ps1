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

    $RPTrust = Get-AdfsRelyingPartyTrust -Name $Name

    If($RPTrust -eq $null)
    {
        Write-Warning "Adfs Relying Party Trust with name $Name was not found."
        $EnsureResult = "Absent"
    }
    Else
    {
        $EnsureResult = "Present"
    }

	
	$returnValue = @{
		AdditionalAuthenticationRules = $RPTrust.AdditionalAuthenticationRules
		AdditionalWSFedEndpoint = $RPTrust.AdditionalWSFedEndpoint
		AutoUpdateEnabled = $RPTrust.AutoUpdateEnabled
		ClaimAccepted = $RPTrust.ClaimsAccepted
		ClaimsProviderName = $RPTrust.ClaimsProviderName
		DelegationAuthorizationRules = $RPTrust.DelegationAuthorizationRules
		Enabled = $RPTrust.Enabled
		EnableJWT = $RPTrust.EnableJWT
		EncryptClaims = $RPTrust.EncryptClaims
		EncryptedNameIdRequired = $RPTrust.EncryptedNameIdRequired
		EncryptionCertificate = $RPTrust.EncryptionCertificate
		EncryptionCertificateRevocationCheck = $RPTrust.EncryptionCertificateRevocationCheck
		Identifier = $RPTrust.Identifier
		ImpersonationAuthorizationRules = $RPTrust.ImpersonationAuthorizationRules
		IssuanceAuthorizationRules = $RPTrust.IssuanceAuthorizationRules
		IssuanceTransformRules = $RPTrust.IssuanceTransformRules
		MetadataUrl = $RPTrust.MetadataUrl
		MonitoringEnabled = $RPTrust.MonitoringEnabled
		Name = $RPTrust.Name
		NotBeforeSkew = $RPTrust.NotBeforeSkew
		Notes = $RPTrust.Notes
		ProtocolProfile = $RPTrust.ProtocolProfile
		RequestSigningCertificate = $RPTrust.RequestSigningCertificate
		SamlEndpoint = $RPTrust.SamlEndpoints
		SamlResponseSignature = $RPTrust.SamlResponseSignature
		SignatureAlgorithm = $RPTrust.SignatureAlgorithm
		SignedSamlRequestsRequired = $RPTrust.SignedSamlRequestsRequired
		SigningCertificateRevocationCheck = $RPTrust.SigningCertificateRevocationCheck
		TokenLifetime = $RPTrust.TokenLifetime
		WSFedEndpoint = $RPTrust.WSFedEndpoint
        Ensure = $EnsureResult
	}

	$returnValue
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[System.String]
		$AdditionalAuthenticationRules,

		[System.String[]]
		$AdditionalWSFedEndpoint,

		[System.Boolean]
		$AutoUpdateEnabled,

		[System.String[]]
		$ClaimAccepted,

		[System.String[]]
		$ClaimsProviderName,

		[System.String]
		$DelegationAuthorizationRules,

		[System.Boolean]
		$Enabled,

		[System.Boolean]
		$EnableJWT,

		[System.Boolean]
		$EncryptClaims,

		[System.Boolean]
		$EncryptedNameIdRequired,

		[System.String]
		$EncryptionCertificate,

		[ValidateSet("None","CheckEndCert","CheckEndCertCacheOnly","CheckChain","CheckChainCacheOnly","CheckChainExcludingRoot","CheckChainExcludingRootCacheOnly")]
		[System.String]
		$EncryptionCertificateRevocationCheck,

		[System.String[]]
		$Identifier,

		[System.String]
		$ImpersonationAuthorizationRules,

		[System.String]
		$IssuanceAuthorizationRules,

		[System.String]
		$IssuanceTransformRules,

		[System.String]
		$MetadataUrl,

		[System.Boolean]
		$MonitoringEnabled,

		[parameter(Mandatory = $true)]
		[System.String]
		$Name,

		[System.Int32]
		$NotBeforeSkew,

		[System.String]
		$Notes,

		[ValidateSet("SAML","WsFederation","WsFed-SAML")]
		[System.String]
		$ProtocolProfile,

		[System.String[]]
		$RequestSigningCertificate,

		[System.String[]]
		$SamlEndpoint,

		[ValidateSet("AssertionOnly","MessageAndAssertion","MessageOnly")]
		[System.String]
		$SamlResponseSignature,

		[ValidateSet("http://www.w3.org/2000/09/xmldsig#rsa-sha1","http://www.w3.org/2001/04/xmldsig-more#rsa-sha256")]
		[System.String]
		$SignatureAlgorithm,

		[System.Boolean]
		$SignedSamlRequestsRequired,

		[ValidateSet("None","CheckEndCert","CheckEndCertCacheOnly","CheckChain","CheckChainCacheOnly","CheckChainExcludingRoot","CheckChainExcludingRootCacheOnly")]
		[System.String]
		$SigningCertificateRevocationCheck,

		[System.Int32]
		$TokenLifetime,

		[System.String]
		$WSFedEndpoint,

		[parameter(Mandatory = $true)]
		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure
	)

    #Remove Ensure from PSBoundParameter because it is not a parameter on the *AdfsRelyingPartyTrust cmdlets
    $PSBoundParameters.Remove('Ensure')
    $RPTrust = Get-AdfsRelyingPartyTrust -Name $Name
    
    If($RPTrust -eq $null -and $Ensure -eq 'Present')
    {
        Write-Verbose "Adfs Relying Party Trust with name $Name was not found. Ensure equals Present. Adding new Relying Party Trust."

        Add-AdfsRelyingPartyTrust @PSBoundParameters

    }
    ElseIf($RPTrust -ne $null -and $Ensure -eq 'Present')
    {
        Write-Verbose "Adfs Relying Party Trust with name $Name found. Ensure equals Present. Correcting configuration."
        $PSBoundParameters.Remove('Enabled')
        $PSBoundParameters.Add('TargetName',$Name)
        Set-AdfsRelyingPartyTrust @PSBoundParameters
    }
    ElseIf($RPTrust -ne $null -and $Ensure -eq 'Absent')
    {
        Write-Verbose "Adfs Relying Party Trust with name $Name was found. Ensure equals Absent. Removing Relying Party Trust"

        Remove-AdfsRelyingPartyTrust -TargetIdentifier $Name
        
    }

}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[System.String]
		$AdditionalAuthenticationRules,

		[System.String[]]
		$AdditionalWSFedEndpoint,

		[System.Boolean]
		$AutoUpdateEnabled,

		[System.String[]]
		$ClaimAccepted,

		[System.String[]]
		$ClaimsProviderName,

		[System.String]
		$DelegationAuthorizationRules,

		[System.Boolean]
		$Enabled,

		[System.Boolean]
		$EnableJWT,

		[System.Boolean]
		$EncryptClaims,

		[System.Boolean]
		$EncryptedNameIdRequired,

		[System.String]
		$EncryptionCertificate,

		[ValidateSet("None","CheckEndCert","CheckEndCertCacheOnly","CheckChain","CheckChainCacheOnly","CheckChainExcludingRoot","CheckChainExcludingRootCacheOnly")]
		[System.String]
		$EncryptionCertificateRevocationCheck,

		[System.String[]]
		$Identifier,

		[System.String]
		$ImpersonationAuthorizationRules,

		[System.String]
		$IssuanceAuthorizationRules,

		[System.String]
		$IssuanceTransformRules,

		[System.String]
		$MetadataUrl,

		[System.Boolean]
		$MonitoringEnabled,

		[parameter(Mandatory = $true)]
		[System.String]
		$Name,

		[System.Int32]
		$NotBeforeSkew,

		[System.String]
		$Notes,

		[ValidateSet("SAML","WsFederation","WsFed-SAML")]
		[System.String]
		$ProtocolProfile,

		[System.String[]]
		$RequestSigningCertificate,

		[System.String[]]
		$SamlEndpoint,

		[ValidateSet("AssertionOnly","MessageAndAssertion","MessageOnly")]
		[System.String]
		$SamlResponseSignature,

		[ValidateSet("http://www.w3.org/2000/09/xmldsig#rsa-sha1","http://www.w3.org/2001/04/xmldsig-more#rsa-sha256")]
		[System.String]
		$SignatureAlgorithm,

		[System.Boolean]
		$SignedSamlRequestsRequired,

		[ValidateSet("None","CheckEndCert","CheckEndCertCacheOnly","CheckChain","CheckChainCacheOnly","CheckChainExcludingRoot","CheckChainExcludingRootCacheOnly")]
		[System.String]
		$SigningCertificateRevocationCheck,

		[System.Int32]
		$TokenLifetime,

		[System.String]
		$WSFedEndpoint,

		[parameter(Mandatory = $true)]
		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure
	)

    Import-Module "$env:ProgramFiles\WindowsPowerShell\Modules\xAdfs\DSCResources\Library\Helper.psm1" -Verbose:0

    $RPTrust = Get-AdfsRelyingPartyTrust -Name $Name

    If($RPTrust -eq $null -and $Ensure -eq 'Present')
    {
        Write-Verbose "Adfs Relying Party Trust with name $Name was not found."
        return $false
    }
    If($RPTrust -ne $null -and $Ensure -eq 'Absent')
    {
        return $false
    }

    If($PSBoundParameters.AdditionalAuthenticationRules -and $PSBoundParameters.AdditionalAuthenticationRules -ne $RPTrust.AdditionalAuthenticationRules)
    {
        Write-Verbose "AdditionalAuthenticationRules not in desired state. Expected: $($PSBoundParameters.AdditionalAuthenticationRules) Actual: $($RPTrust.AdditionalAuthenticationRules)"
        return $false
    }
    If($PSBoundParameters.AdditionalWSFedEndpoint)
    {
        If(-not(CompareArray $PSBoundParameters.AdditionalWSFedEndpoint $RPTrust.AdditionalWSFedEndpoint))
        {
            Write-Verbose "AdditionalWSFedEndpoint not in desired state. Expected: $(ArrayToString $PSBoundParameters.AdditionalWSFedEndpoint) Actual: $(ArrayToString $RPTrust.AdditionalWSFedEndpoint)"
            return $false
        }

    }
    If($PSBoundParameters.AutoUpdateEnabled -and $PSBoundParameters.AutoUpdateEnabled -ne $RPTrust.AutoUpdateEnabled)
    {
        Write-Verbose "AutoUpdateEnabled not in desired state. Expect: $($PSBoundParameters.AutoUpdateEnabled) Actual: $($RPTrust.AutoUpdateEnabled)"
        return $false
    }
    If($PSBoundParameters.ClaimAccepted)
    {
        If(-not(CompareArray $PSBoundParameters.ClaimAccepted $RPTrust.ClaimsAccepted))
        {
            Write-Verbose "ClaimAccepted not in desired state. Expected: $(ArrayToString $PSBoundParameters.ClaimAccepted) Actual: $(ArrayToString $RPTrust.ClaimsAccepted)"
            return $false
        }
    }
    If($PSBoundParameters.ClaimsProviderName)
    {
        If(-not(CompareArray $PSBoundParameters.ClaimsProviderName $RPTrust.ClaimsProviderName))
        {
            Write-Verbose "ClaimsProviderName not in desired state. Expected: $(ArrayToString $PSBoundParameters.ClaimsProviderName) Actual: $(ArrayToString $RPTrust.ClaimsProviderName)"
            return $false
        }
    }
    If($PSBoundParameters.DelegationAuthorizationRules -and $PSBoundParameters.DelegationAuthorizationRules -ne $RPTrust.DelegationAuthorizationRules)
    {
        Write-Verbose "DelegationAuthorizationRules not in desired state. Expect: $($PSBoundParameters.DelegationAuthorizationRules) Actual: $($RPTrust.DelegationAuthorizationRules)"
        return $false
    }
    If($PSBoundParameters.Enabled -and $PSBoundParameters.Enabled -ne $RPTrust.Enabled)
    {
        Write-Verbose "Enabled not in desired state. Expect: $($PSBoundParameters.Enabled) Actual: $($RPTrust.Enabled)"
        return $false
    }
    If($PSBoundParameters.EnableJWT -and $PSBoundParameters.EnableJWT -ne $RPTrust.EnableJWT)
    {
        Write-Verbose "EnableJWT not in desired state. Expect: $($PSBoundParameters.EnableJWT) Actual: $($RPTrust.EnableJWT)"
        return $false
    }
    If($PSBoundParameters.EncryptClaims -and $PSBoundParameters.EncryptClaims -ne $RPTrust.EncryptClaims)
    {
        Write-Verbose "EncryptClaims not in desired state. Expect: $($PSBoundParameters.EncryptClaims) Actual: $($RPTrust.EncryptClaims)"
        return $false
    }
    If($PSBoundParameters.EncryptedNameIdRequired -and $PSBoundParameters.EncryptedNameIdRequired -ne $RPTrust.EncryptedNameIdRequired)
    {
        Write-Verbose "EncryptedNameIdRequired not in desired state. Expect: $($PSBoundParameters.EncryptedNameIdRequired) Actual: $($RPTrust.EncryptedNameIdRequired)"
        return $false
    }
    If($PSBoundParameters.EncryptionCertificate -and $PSBoundParameters.EncryptionCertificate -ne $RPTrust.EncryptionCertificate)
    {
        Write-Verbose "EncryptionCertificate not in desired state. Expect: $($PSBoundParameters.EncryptionCertificate) Actual: $($RPTrust.EncryptionCertificate)"
        return $false
    }
    If($PSBoundParameters.EncryptionCertificateRevocationCheck -and $PSBoundParameters.EncryptionCertificateRevocationCheck -ne $RPTrust.EncryptionCertificateRevocationCheck)
    {
        Write-Verbose "EncryptionCertificateRevocationCheck not in desired state. Expect: $($PSBoundParameters.EncryptionCertificateRevocationCheck) Actual: $($RPTrust.EncryptionCertificateRevocationCheck)"
        return $false
    }
    If($PSBoundParameters.Identifier)
    {
        If(-not(CompareArray $PSBoundParameters.Identifier $RPTrust.Identifier))
        {
            Write-Verbose "Identifier not in desired state. Expected: $(ArrayToString $PSBoundParameters.Identifier) Actual: $(ArrayToString $RPTrust.Identifier)"
            return $false
        }
    }
    If($PSBoundParameters.ImpersonationAuthorizationRules -and $PSBoundParameters.ImpersonationAuthorizationRules -ne $RPTrust.ImpersonationAuthorizationRules)
    {
        Write-Verbose "ImpersonationAuthorizationRules not in desired state. Expect: $($PSBoundParameters.ImpersonationAuthorizationRules) Actual: $($RPTrust.ImpersonationAuthorizationRules)"
        return $false
    }
    If($PSBoundParameters.ImpersonationAuthorizationRules) 
    {
        $CompareResultsImpersonationAuthorizationRules = CompareAdfsRules $PSBoundParameters.ImpersonationAuthorizationRules $RPTrust.ImpersonationAuthorizationRules

        If($CompareResultsImpersonationAuthorizationRules -eq $false)
        {
            Write-Verbose "ImpersonationAuthorizationRules not in desired state. Expected: $($PSBoundParameters.ImpersonationAuthorizationRules) Actual: $($RPTrust.ImpersonationAuthorizationRules)"
            return $false
        }
    }
    If($PSBoundParameters.IssuanceAuthorizationRules) 
    {
        $CompareResultsIssuanceAuthorizationRules = CompareAdfsRules $PSBoundParameters.ImpersonationAuthorizationRules $RPTrust.ImpersonationAuthorizationRules

        If($CompareResultsIssuanceAuthorizationRules -eq $false)
        {
            Write-Verbose "IssuanceAuthorizationRules not in desired state. Expected: $($PSBoundParameters.IssuanceAuthorizationRules) Actual: $($RPTrust.IssuanceAuthorizationRules)"
            return $false
        }
    }
    If($PSBoundParameters.IssuanceTransformRules)
    {
        $CompareResultsTransformRules = CompareAdfsRules $PSBoundParameters.IssuanceTransformRules $RPTrust.IssuanceTransformRules

        If($CompareResultsTransformRules -eq $false)
        {
            Write-Verbose "IssuanceAuthorizationRules not in desired state. Expected: $IssAuthParam Actual: $CurrentIssAuth"
            return $false
        }
    }

    If($PSBoundParameters.MetadataUrl -and $PSBoundParameters.MetadataUrl -ne $RPTrust.MetadataUrl)
    {
        Write-Verbose "MetadataUrl not in desired state. Expect: $($PSBoundParameters.MetadataUrl) Actual: $($RPTrust.MetadataUrl)"
        return $false
    }
    If($PSBoundParameters.MonitoringEnabled -and $PSBoundParameters.MonitoringEnabled -ne $RPTrust.MonitoringEnabled)
    {
        Write-Verbose "MonitoringEnabled not in desired state. Expect: $($PSBoundParameters.MonitoringEnabled) Actual: $($RPTrust.MonitoringEnabled)"
        return $false
    }
    If($PSBoundParameters.NotBeforeSkew -and $PSBoundParameters.NotBeforeSkew -ne $RPTrust.NotBeforeSkew)
    {
        Write-Verbose "NotBeforeSkew not in desired state. Expect: $($PSBoundParameters.NotBeforeSkew) Actual: $($RPTrust.NotBeforeSkew)"
        return $false
    }
    If($PSBoundParameters.Notes -and $PSBoundParameters.Notes -ne $RPTrust.Notes)
    {
        Write-Verbose "Notes not in desired state. Expect: $($PSBoundParameters.Notes) Actual: $($RPTrust.Notes)"
        return $false
    }
    If($PSBoundParameters.ProtocolProfile -and $PSBoundParameters.ProtocolProfile -ne $RPTrust.ProtocolProfile)
    {
        Write-Verbose "ProtocolProfile not in desired state. Expect: $($PSBoundParameters.ProtocolProfile) Actual: $($RPTrust.ProtocolProfile)"
        return $false
    }
    If($PSBoundParameters.RequestSigningCertificate)
    {
        If(-not(CompareArray $PSBoundParameters.RequestSigningCertificate $RPTrust.RequestSigningCertificate))
        {
            Write-Verbose "RequestSigningCertificate not in desired state. Expected: $(ArrayToString $PSBoundParameters.RequestSigningCertificate) Actual: $(ArrayToString $RPTrust.RequestSigningCertificate)"
            return $false
        }
    }
    If($PSBoundParameters.SamlEndpoint)
    {
        If(-not(CompareArray $PSBoundParameters.SamlEndpoint $RPTrust.SamlEndpoint))
        {
            Write-Verbose "SamlEndpoint not in desired state. Expected: $(ArrayToString $PSBoundParameters.SamlEndpoint) Actual: $(ArrayToString $RPTrust.SamlEndpoint)"
            return $false
        }
    }
    If($PSBoundParameters.SamlResponseSignature -and $PSBoundParameters.SamlResponseSignature -ne $RPTrust.SamlResponseSignature)
    {
        Write-Verbose "SamlResponseSignature not in desired state. Expect: $($PSBoundParameters.SamlResponseSignature) Actual: $($RPTrust.SamlResponseSignature)"
        return $false
    }
    If($PSBoundParameters.SignatureAlgorithm -and $PSBoundParameters.SignatureAlgorithm -ne $RPTrust.SignatureAlgorithm)
    {
        Write-Verbose "SignatureAlgorithm not in desired state. Expect: $($PSBoundParameters.SignatureAlgorithm) Actual: $($RPTrust.SignatureAlgorithm)"
        return $false
    }
    If($PSBoundParameters.SignedSamlRequestsRequired -and $PSBoundParameters.SignedSamlRequestsRequired -ne $RPTrust.SignedSamlRequestsRequired)
    {
        Write-Verbose "SignedSamlRequestsRequired not in desired state. Expect: $($PSBoundParameters.SignedSamlRequestsRequired) Actual: $($RPTrust.SignedSamlRequestsRequired)"
        return $false
    }
    If($PSBoundParameters.SigningCertificateRevocationCheck -and $PSBoundParameters.SigningCertificateRevocationCheck -ne $RPTrust.SigningCertificateRevocationCheck)
    {
        Write-Verbose "SigningCertificateRevocationCheck not in desired state. Expect: $($PSBoundParameters.SigningCertificateRevocationCheck) Actual: $($RPTrust.SigningCertificateRevocationCheck)"
        return $false
    }
    If($PSBoundParameters.TokenLifetime -and $PSBoundParameters.TokenLifetime -ne $RPTrust.TokenLifetime)
    {
        Write-Verbose "TokenLifetime not in desired state. Expect: $($PSBoundParameters.TokenLifetime) Actual: $($RPTrust.TokenLifetime)"
        return $false
    }
    If($PSBoundParameters.WSFedEndpoint -and $PSBoundParameters.WSFedEndpoint -ne $RPTrust.WSFedEndpoint)
    {
        Write-Verbose "WSFedEndpoint not in desired state. Expect: $($PSBoundParameters.WSFedEndpoint) Actual: $($RPTrust.WSFedEndpoint)"
        return $false
    }
    #If the code made it this far all settings must be in a desired state
    return $true
}


Export-ModuleMember -Function *-TargetResource

