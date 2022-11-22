# https://github.com/glacasa/Mastonet/blob/main/Mastonet/MastodonClient.cs
function Get-MastodonNotification {
    param(
        [long] $Id,
        [MastodonSession] $Session = $script:session
    )
    Invoke-MastodonApiRequest -Session:$Session -Method:Get -Route:"api/v1/notifications/$Id"
}