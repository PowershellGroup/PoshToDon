# example
# Get-MastodonNotification -Limit 300 -MaxId 87886 -ExcludeTypes favourite,mention | FT
# https://github.com/glacasa/Mastonet/blob/main/Mastonet/MastodonClient.cs
function Get-MastodonNotification {
    [CmdletBinding(DefaultParameterSetName="List")]
    param(
        [Parameter(ParameterSetName = "Id", Position = 0, ValueFromPipeline)]
        [System.Nullable[int]] $Id,

        [Parameter(ParameterSetName = "List")]
        [System.Nullable[long]] $MaxId,
        
        [Parameter(ParameterSetName = "List")]
        [System.Nullable[long]] $SinceId,
        
        [Parameter(ParameterSetName = "List")]
        [System.Nullable[long]] $MinId,

        [Parameter(ParameterSetName = "List")]
        [System.Nullable[int]] $Limit,

        [ValidateScript({ $_ -in $script:notificationTypes })]
        [string[]] $ExcludeTypes,
        [MastodonSession] $Session = $script:session
    )
    
    if ($null -ne $Id) {
        Invoke-MastodonApiRequest -Session:$Session -Method:Get -Route:"api/v1/notifications/$Id"
    } else {
        $query = ArrayQueryParameters @PSBoundParameters
        | AddData @{ exclude_types = $ExcludeTypes }
        | ToQuery

        Invoke-MastodonApiRequest -Session:$Session -Method:Get -Route:"api/v1/notifications$query"
    }
}
