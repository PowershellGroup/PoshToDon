# https://docs.joinmastodon.org/methods/media/
# https://github.com/glacasa/Mastonet/blob/main/Mastonet/MastodonClient.cs
function New-MastodonMedia {
    param(
        # optional if media ids are filled
        [string] $ImagePath,
        [string] $ThumbnailPath,
        [string] $Description,
        
        [MastodonSession] $Session = $script:session
    )

    # if ((-not $Status) -and (-not $MediaIds)) {
    #     throw 'Pass MediaIds or a Status'
    # }

    $formData = . {
        if ($ImagePath) {
            ConvertTo-MastodonFormMedia $ImagePath "file"
        }

        if ($ThumbnailPath) {
            ConvertTo-MastodonFormMedia $ThumbnailPath "thumbnail"
        }

        if ($Description) {
            ConvertTo-MastodonFormText $Description "description"
        }
    }

    Invoke-MastodonApiRequest -Session:$Session -Method:Post -Route:'api/v2/media' -FormData:$formData
}