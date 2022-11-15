# from here:
# https://github.com/glacasa/Mastonet/blob/main/Mastonet/MastodonClient.cs
# ...
function Get-MastodonInstance {
    param()
    Invoke-MastodonApiRequest -Method:Get -Route:"api/v1/instance"
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
        [string[]] $ExcludeTypes
    )
    # https://github.com/glacasa/Mastonet/blob/main/Mastonet/ArrayOptions.cs
    $queryParameters = Get-MastodonArrayQueryParameters @PSBoundParameters

    $query = @{
        exclude_types = $ExcludeTypes
    } | ConvertTo-QueryParameters -QueryParameters:$queryParameters | ConvertTo-Query

    Invoke-MastodonApiRequest -Method:Get -Route:"api/v1/notifications$query"
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
        [string] $Language
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

    Invoke-MastodonApiRequest -Method:Post -Route:'api/v1/statuses' -Data:$data -Headers:$headers
}

function Get-MastodonNotification {
    param([long] $Id)
    Invoke-MastodonApiRequest -Method:Get -Route:"api/v1/notifications/$Id"
}

function Confirm-MastodonNotification {
    param([long] $Id)
    Invoke-MastodonApiRequest -Method:Post -Route:"api/v1/notifications/dismiss" -Data @{ id = $Id }
}

function Get-MastodonCustomEmojis {
    Invoke-MastodonApiRequest -Method:Get -Route:"api/v1/custom_emojis"
}

function Get-MastodonReports {
    param(
        [System.Nullable[long]] $MaxId,
        [System.Nullable[long]] $SinceId,
        [System.Nullable[long]] $MinId,
        [System.Nullable[int]] $Limit
    )

    $query = Get-MastodonArrayQueryArguments @PSBoundParameters | ConvertTo-Query
    Invoke-MastodonApiRequest -Method:Get -Route:"api/v1/reports$query"
}

# https://github.com/glacasa/Mastonet/blob/main/Mastonet/AuthenticationClient.cs
function New-MastodonApplication {
    param(
        [string]$Name = "PoshToDon",

        [ValidateScript({ $_ -in $script:validScopes })]
        [string[]] $Scope = "read",
        
        [string] $Instance = $null
    )

    if ($Instance) {
        Set-MastodonInstance -Instance:$Instance
    }

    $body = @{
        "client_name"   = $Name
        "scopes"        = ($Scope | Join-String -Separator " ")
        "redirect_uris" = "urn:ietf:wg:oauth:2.0:oob"
    };

    [AppRegistration]$appRegistration = Invoke-MastodonApiRequest -Method:Post -Data:$body -Route "api/v1/apps"

    $appRegistration.instance = $Instance
    $appRegistration.scope = $Scope

    $script:appRegistration = $appRegistration;

    return $appRegistration;
}

function Connect-MastodonApplication {
    param(
        [string] $Email,
        [securestring] $Password,
        [ValidateScript({ $_ -in $script:validScopes })]
        [string[]] $Scope
    )

    if (-not $script:appRegistration) {
        throw "No AppRegistration"
    }

    $data = @{
        client_id     = $script:appRegistration.client_id
        client_secret = $script:appRegistration.client_secret
        grant_type    = 'password'
        username      = $Email
        password      = ConvertFrom-SecureString $Password -AsPlainText
    }

    if ($Scope) {
        $data['scope'] = $Scope | Join-String -Separator:' '
    }

    $auth = Invoke-MastodonApiRequest -Method:Post -Route:"oauth/token" -Data:$data

    $script:auth = $auth

    return $auth
}
