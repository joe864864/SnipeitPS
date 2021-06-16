<#
.SYNOPSIS
Gets a list of Snipe-it Assets or specific asset

.PARAMETER search
A text string to search the assets data

.PARAMETER id
ID number of excact snipeit asset

.PARAMETER asset_tag
Exact asset tag to query

.PARAMETER asset_serial
Exact asset serialnumber to query

.PARAMETER audit_due
Retrieve a list of assets that are due for auditing soon.

.PARAMETER audit_overdue
Retrieve a list of assets that are overdue for auditing.

.PARAMETER order_number
Optionally restrict asset results to this order number

.PARAMETER model_id
Optionally restrict asset results to this asset model ID

.PARAMETER category_id
Optionally restrict asset results to this category ID

.PARAMETER manufacturer_id
Optionally restrict asset results to this manufacturer ID

.PARAMETER company_id
Optionally restrict asset results to this company ID

.PARAMETER location_id
Optionally restrict asset results to this location ID

.PARAMETER status
Optionally restrict asset results to one of these status types: RTD, Deployed, Undeployable, Deleted, Archived, Requestable

.PARAMETER status_id
Optionally restrict asset results to this status label ID

.PARAMETER sort
Specify the column name you wish to sort by

.PARAMETER order
Specify the order (asc or desc) you wish to order by on your sort column

.PARAMETER limit
Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

.PARAMETER offset
Offset to use

.PARAMETER all
A return all results, works with -offset and other parameters

.PARAMETER url
URL of Snipeit system, can be set using Set-SnipeitInfo command

.PARAMETER apiKey
Users API Key for Snipeit, can be set using Set-SnipeitInfo command

.EXAMPLE
Get-SnipeitAsset -url "https://assets.example.com"-token "token..."

.EXAMPLE
Get-SnipeitAsset -search "myMachine"-url "https://assets.example.com"-token "token..."

.EXAMPLE
Get-SnipeitAsset -search "myMachine"-url "https://assets.example.com"-token "token..."

.EXAMPLE
Get-SnipeitAsset -asset_tag "myAssetTag"-url "https://assets.example.com"-token "token..."
#>

function Get-SnipeitAsset() {
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    Param(
        [parameter(ParameterSetName='Search')]
        [string]$search,

        [parameter(ParameterSetName='Get with id')]
        [int]$id,

        [parameter(ParameterSetName='Get with asset tag')]
        [string]$asset_tag,

        [parameter(ParameterSetName='Get with serial')]
        [Alias('asset_serial')]
        [string]$serial,

        [parameter(ParameterSetName='Assets due auditing soon')]
        [switch]$audit_due,

        [parameter(ParameterSetName='Assets overdue for auditing')]
        [switch]$audit_overdue,

        [parameter(ParameterSetName='Search')]
        [string]$order_number,

        [parameter(ParameterSetName='Search')]
        [int]$model_id,

        [parameter(ParameterSetName='Search')]
        [int]$category_id,

        [parameter(ParameterSetName='Search')]
        [int]$manufacturer_id,

        [parameter(ParameterSetName='Search')]
        [int]$company_id,

        [parameter(ParameterSetName='Search')]
        [int]$location_id,

        [parameter(ParameterSetName='Search')]
        [int]$depreciation_id,

        [parameter(ParameterSetName='Search')]
        [bool]$requestable = $false,

        [parameter(ParameterSetName='Search')]
        [string]$status,

        [parameter(ParameterSetName='Search')]
        [int]$status_id,

        [parameter(ParameterSetName='Search')]
        [parameter(ParameterSetName='Assets due auditing soon')]
        [parameter(ParameterSetName='Assets overdue for auditing')]
        [ValidateSet('id','created_at','asset_tag','serial','order_number','model_id','category_id','manufacturer_id','company_id','location_id','status','status_id')]
        [string]$sort,

        [parameter(ParameterSetName='Search')]
        [parameter(ParameterSetName='Assets due auditing soon')]
        [parameter(ParameterSetName='Assets overdue for auditing')]
        [ValidateSet("asc", "desc")]
        [string]$order,

        [parameter(ParameterSetName='Search')]
        [parameter(ParameterSetName='Assets due auditing soon')]
        [parameter(ParameterSetName='Assets overdue for auditing')]
        [int]$limit = 50,

        [parameter(ParameterSetName='Search')]
        [parameter(ParameterSetName='Assets due auditing soon')]
        [parameter(ParameterSetName='Assets overdue for auditing')]
        [int]$offset,

        [parameter(ParameterSetName='Search')]
        [parameter(ParameterSetName='Assets due auditing soon')]
        [parameter(ParameterSetName='Assets overdue for auditing')]
        [switch]$all = $false,

        [parameter(mandatory = $true)]
        [string]$url,

        [parameter(mandatory = $true)]
        [string]$apiKey
    )

    Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

    $SearchParameter = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

    switch ($PsCmdlet.ParameterSetName) {
        'Search' { $apiurl = "$url/api/v1/hardware" }
        'Get with id'  {$apiurl= "$url/api/v1/hardware/$id"}
        'Get with asset tag' {$apiurl= "$url/api/v1/hardware/bytag/$asset_tag"}
        'Get with serial' { $apiurl= "$url/api/v1/hardware/byserial/$serial"}
        'Assets due auditing soon' {$apiurl = "$url/api/v1/hardware/audit/due"}
        'Assets overdue for auditing' {$apiurl = "$url/api/v1/hardware/audit/overdue"}
    }


    $Parameters = @{
        Uri           = $apiurl
        Method        = 'Get'
        GetParameters = $SearchParameter
        Token         = $apiKey
    }

    if ($all) {
        $offstart = $(if ($offset){$offset} Else {0})
        $callargs = $SearchParameter
        Write-Verbose "Callargs: $($callargs | convertto-json)"
        $callargs.Remove('all')

        while ($true) {
            $callargs['offset'] = $offstart
            $callargs['limit'] = $limit
            $res=Get-SnipeitAsset @callargs
            $res
            if ( $res.count -lt $limit) {
                break
            }
            $offstart = $offstart + $limit
        }
    } else {
        $result = Invoke-SnipeitMethod @Parameters
        $result
    }


}






