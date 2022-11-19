# from here:
# https://github.com/glacasa/Mastonet/blob/main/Mastonet/MastodonClient.cs
# ...
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

# example
# Get-MastodonNotifications -Limit 300 -MaxId 87886 -ExcludeTypes favourite,mention | FT
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
    
    $queryParameters = Get-MastodonArrayQueryParameters @PSBoundParameters

    $query = @{
        exclude_types = $ExcludeTypes
    } | ConvertTo-QueryParameters -QueryParameters:$queryParameters | ConvertTo-Query

    Invoke-MastodonApiRequest -Session:$Session -Method:Get -Route:"api/v1/notifications$query"
}

# https://docs.joinmastodon.org/methods/statuses/
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

function Get-MastodonNotification {
    param(
        [long] $Id,
        [MastodonSession] $Session = $script:session
    )
    Invoke-MastodonApiRequest -Session:$Session -Method:Get -Route:"api/v1/notifications/$Id"
}

function Confirm-MastodonNotification {
    param(
        [long] $Id,
        [MastodonSession] $Session = $script:session
    )
    Invoke-MastodonApiRequest -Session:$Session -Method:Post -Route:"api/v1/notifications/dismiss" -Data @{ id = $Id }
}

function Get-MastodonCustomEmojis {
    param([MastodonSession] $Session = $script:session)
    Invoke-MastodonApiRequest -Session:$Session -Method:Get -Route:"api/v1/custom_emojis"
}

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

# not yet sure why i need this function, but its in the implementation this one is based on:
# https://github.com/glacasa/Mastonet/blob/main/Mastonet/AuthenticationClient.cs
function New-MastodonApplication {
    param(
        [string]$Name = "PoshToDon",

        [ValidateScript({ $_ -in $script:validScopes })]
        [string[]] $Scope = "read",
        
        [string] $Instance = $null,

        [string] $RedirectUri = "urn:ietf:wg:oauth:2.0:oob",

        [MastodonSession] $Session = $script:session,
        [switch] $PassThru
    )

    if ($Instance) {
        Set-MastodonInstance -Instance:$Instance
    }

    $body = @{
        "client_name"   = $Name
        "redirect_uris" = $RedirectUri
        "scopes"        = ($Scope | Join-String -Separator " ")
    };

    $session.AppRegistration = Invoke-MastodonApiRequest -Method:Post -Data:$body -Route "api/v1/apps"
    $session.Instance = $Instance
    $session.Scope = $Scope

    if ($PassThru) {
        $appRegistration
    }
}
