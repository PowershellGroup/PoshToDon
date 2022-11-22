# https://github.com/glacasa/Mastonet/blob/main/Mastonet/MastodonClient.cs
function Confirm-MastodonNotification {
    param(
        [long] $Id,
        [MastodonSession] $Session = $script:session
    )
    Invoke-MastodonApiRequest -Session:$Session -Method:Post -Route:"api/v1/notifications/dismiss" -Data @{ id = $Id }
}
