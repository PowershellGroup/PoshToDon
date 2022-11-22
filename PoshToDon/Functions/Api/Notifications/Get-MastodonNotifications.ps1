# example
# Get-MastodonNotifications -Limit 300 -MaxId 87886 -ExcludeTypes favourite,mention | FT
# https://github.com/glacasa/Mastonet/blob/main/Mastonet/MastodonClient.cs
function Get-MastodonNotifications {
    param(
        [System.Nullable[long]] $MaxId,
        [System.Nullable[long]] $SinceId,
        [System.Nullable[long]] $MinId,
        [System.Nullable[int]] $Limit,

        [ValidateScript({ $_ -in $script:notificationTypes })]
        [string[]] $ExcludeTypes,
        [MastodonSession] $Session = $script:session
    )
    
    ArrayQueryParameters @PSBoundParameters
    | AddData @{ exclude_types = $ExcludeTypes }
    | ToQuery

    Invoke-MastodonApiRequest -Session:$Session -Method:Get -Route:"api/v1/notifications$query"
}