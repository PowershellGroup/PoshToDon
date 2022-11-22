# https://github.com/glacasa/Mastonet/blob/main/Mastonet/MastodonClient.cs
function Get-MastodonInstance {
    param(
        [Parameter(ValueFromPipeline)]
        [MastodonSession[]] $Session = $script:session
    )
    process {
        foreach ($_ in $Session) {
            Invoke-MastodonApiRequest -Session:$_ -Method:Get -Route:"api/v1/instance"
        }
    }
}