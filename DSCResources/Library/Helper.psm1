Function ArrayToString($Array)
{
    #This fucntion expands an array and displays it as a string 

    $StrArray = $null

    $array | % {[string]$StrArray += "$_, "}

    $StrLngth = $StrArray.Length
    $StrArray.Trim().Substring(0,($StrLngth - 2))
}

Function CompareArray
{
    [cmdletbinding()]
    param(
        [array]$ReferenceObject,

        [array]$DifferenceObject
    )
    
    $CompareResults = Compare-Object $ReferenceObject $DifferenceObject

    if($CompareResults)
    {
        return $false
    }
    Else
    {
        return $true
    }

}

Function CompareAdfsRules
{
    param
    (
        [string]$Current,
        [string]$FromParam
    )

    $CurrentIssAuth = ((($Current -split '\n' ).trim() | where {$_} ) -join '')
    $IssAuthParam = ((($FromParam -split '\n' ).trim() | where {$_} ) -join '')

    $CurrentIssAuth -eq $IssAuthParam

}