function ConvertTo-String
{
    [CmdletBinding()]
    param
    (
        [array] $Array
    )
    #This fucntion expands an array and displays it as a string 

    $stringArray = $null

    $array | ForEach-Object {[string]$stringArray += "$_, "}

    $stringLength = $stringArray.Length
    $stringArray.Trim().Substring(0,($stringLength - 2))
}

function Compare-Array
{
    [CmdletBinding()]
    param(
        [array] $ReferenceObject,

        [array] $DifferenceObject
    )
    
    $compareResults = Compare-Object $ReferenceObject $DifferenceObject

    if ($compareResults)
    {
        return $false
    }
    else
    {
        return $true
    }

}

function Compare-AdfsRules
{
    [CmdletBinding()]
    param
    (
        [string] $Current,
        [string] $FromParam
    )

    $currentIssAuth = ((($Current -split '\n' ).trim() | where {$_} ) -join '')
    $issAuthParam = ((($FromParam -split '\n' ).trim() | where {$_} ) -join '')

    $currentIssAuth -eq $issAuthParam

}
