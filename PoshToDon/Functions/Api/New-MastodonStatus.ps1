# https://docs.joinmastodon.org/methods/statuses/
# https://github.com/glacasa/Mastonet/blob/main/Mastonet/MastodonClient.cs
function New-MastodonStatus {
    param(
        # optional if media ids are filled
        [string] $Status,
        [long[]] $MediaIds,
        [switch] $Sensitive,
        [string] $SpoilerText,

        [ValidateSet('public', 'unlisted', 'private', 'direct')]
        [string] $Visibility,

        [System.Nullable[DateTimeOffset]] $ScheduledAt,

        # ISO 639 Language Code; optional
        # 'de', 'en', ?!
        # https://en.wikipedia.org/wiki/ISO_639
        [string] $Language,

        [MastodonSession] $Session = $script:session
    )

    if ((-not $Status) -and (-not $MediaIds)) {
        throw 'Pass MediaIds or a Status'
    }

    $data = @{
        status       = $Status
        media_ids    = $MediaIds
        sensitive    = $Sensitive
        spoiler_text = $SpoilerText
        visibility   = $Visibility
        language     = $Language
    }

    $headers = @{
        "Idempotency-Key" = [Guid]::NewGuid()
    }

    if ($null -ne $ScheduledAt) {
        # convert dateTime into ISO 8601 DateTime
        # https://learn.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings#the-round-trip-o-o-format-specifier
        $data['scheduled_at'] = $ScheduledAt.ToString('o', [cultureinfo]::InvariantCulture)
    }

    Invoke-MastodonApiRequest -Session:$Session -Method:Post -Route:'api/v1/statuses' -Data:$data -Headers:$headers
}