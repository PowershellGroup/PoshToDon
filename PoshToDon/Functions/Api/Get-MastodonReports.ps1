# https://github.com/glacasa/Mastonet/blob/main/Mastonet/MastodonClient.cs
function Get-MastodonReports {
    param(
        [System.Nullable[long]] $MaxId,
        [System.Nullable[long]] $SinceId,
        [System.Nullable[long]] $MinId,
        [System.Nullable[int]] $Limit,
        [MastodonSession] $Session = $script:session
    )

    $query = Get-MastodonArrayQueryParameters @PSBoundParameters | ConvertTo-Query
    Invoke-MastodonApiRequest -Session:$Session -Method:Get -Route:"api/v1/reports$query"
}