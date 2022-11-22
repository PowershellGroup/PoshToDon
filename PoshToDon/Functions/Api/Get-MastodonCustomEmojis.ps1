
# https://github.com/glacasa/Mastonet/blob/main/Mastonet/MastodonClient.cs
function Get-MastodonCustomEmojis {
    param([MastodonSession] $Session = $script:session)
    Invoke-MastodonApiRequest -Session:$Session -Method:Get -Route:"api/v1/custom_emojis"
}