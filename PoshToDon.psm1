#Requires -PSEdition Core
# api specs
# https://docs.joinmastodon.org/methods/apps/

$script:validScopes = "read", "write", "write:statuses", "follow", "push", "crypto"

# https://github.com/glacasa/Mastonet/blob/main/Mastonet/Enums/NotificationType.cs
$script:notificationTypes = "follow", "favourite", "reblog", "mention", "poll"

class AppRegistration {
    [string] $client_id
    [string] $client_secret
    [string] $instance
    [string] $redirect_uri
    [string] $name
    [string] $vapid_key
    [string[]] $scope
}

[AppRegistration]$script:appRegistration = $null
[string]$script:instance = $null
$script:auth = $null


function Get-MastodonArrayQueryParameters {
    param(
        [System.Nullable[long]] $MaxId,

        [System.Nullable[long]] $SinceId,

        [System.Nullable[long]] $MinId,

        [System.Nullable[int]] $Limit
    )
    @{
        max_id        = $MaxId
        since_id      = $SinceId
        min_id        = $MinId
        limit         = $Limit
    } | ConvertTo-QueryParameters
}

# filters null elements form the data
# avoids checking every input for null in every method
function Compress-MastodonPostData {
    param(
        [Parameter(ValueFromPipeline)]
        [hashtable]$InputObject
    )

    $compressed = @{}
    $InputObject.Keys | ForEach-Object {
        if ($InputObject[$_]) {
            $compressed[$_] = $InputObject[$_]
        }
    }
    $compressed
}

function ConvertTo-QueryParameters {
    param(
        [Parameter(ValueFromPipeline)]
        [hashtable] $Data,

        [System.Collections.Generic.List[string]] $QueryParameters = [System.Collections.Generic.List[string]]::new()
    )

    $QueryParameters = [System.Collections.Generic.List[string]]::new()
    $data.keys | ForEach-Object {
        if ($null -eq $data[$_]) {
            return # end current foreach pass
        }

        if ($data[$_] -is [System.Collections.IEnumerable]) {
            foreach ($element in $data[$_]) {
                "$_[]=$element"
            }
        } else {
            "$_=$($data[$_])"
        }
    }
}

function ConvertTo-Query {
    begin {
        $argumentList = [System.Collections.Generic.List[string]]::new()
    }
    process {
        if ($_) {
            $argumentList.Add($_)
        } 
    }
    end {
        if ($argumentList.Length) {
            "?" + ( $argumentList | Join-String -Separator '&' )
        } 
    }
}

function Set-MastodonAppRegistration {
    param(
        $ClientId, 
        $ClientSecret, 
        $Instance,
        $RedirectUri = "urn:ietf:wg:oauth:2.0:oob",
        $Name = "PoshToDon",
        $VapidKey,
        [ValidateSet({ $script:validScopes })]
        [string[]] $Scope = "read"
    )

    if ($Instance) {
        Set-MastodonInstance -Instance:$Instance
    }

    $script:appRegistration = [AppRegistration]@{
        client_id = $ClientId
        client_secret = $ClientSecret
        instance = $Instance
        redirect_uri = $RedirectUri
        name = $Name
        vapid_key = $VapidKey
        scope = $Scope
    }
}

function Set-MastodonInstance {
    param([string]$Instance)
    $script:instance = $Instance
}

function Test-MastodonInstance {
    if (-not $script:instance) {
        Write-Host "Use Set-MastodonInstance first"
        return $false
    }

    return $true
}

function Get-MastodonUri {
    param([string]$Route)

    # route should exclude leading /
    if (Test-MastodonInstance) {
        "https://$script:instance/$route"
    } else {
        throw "Mastodon Instance not set"
    }
}

function Invoke-MastodonApiRequest {
    param(
        [ValidateSet("Post", "Get")]
        [string] $Method,
        [string] $Route,
        [hashtable] $Data,
        [hashtable] $Headers = @{}
    )

    if ($script:auth -and (-not $Headers['Authorization'])) {
        $Headers['Authorization'] = "Bearer $($script:auth.access_token)"
    }

    # Invoke-RestMethod 
    #     -Method:"Post" 
    #     -Body:@{"client_name"="PoshToDon";"scopes"="read";"redirect_uris" = "urn:ietf:wg:oauth:2.0:oob"} 
    #     -Uri:"https://home.social/api/v1/apps"

    $invokeSplat = @{
        Method  = $Method
        Uri     = Get-MastodonUri -Route:$Route
        Headers = $headers
    }

    if ($Data) {
        $invokeSplat['Body'] = $Data | Compress-MastodonPostData
    }

    Invoke-RestMethod @invokeSplat
}

# https://github.com/glacasa/Mastonet/blob/main/Mastonet/AuthenticationClient.cs
function New-MastodonApplication {
    param(
        [string]$Name = "PoshToDon",

        [ValidateSet({ $script:validScopes })]
        [string[]] $Scope = "read",
        
        [string] $Instance = $null
    )

    if ($Instance) {
        Set-MastodonInstance -Instance:$Instance
    }

    $body = @{
        "client_name" = $Name
        "scopes" = ($Scope | Join-String -Separator " ")
        "redirect_uris" = "urn:ietf:wg:oauth:2.0:oob"
    };

    [AppRegistration]$appRegistration = Invoke-MastodonApiRequest -Method:Post -Data:$body -Route "api/v1/apps"

    $appRegistration.instance = $Instance
    $appRegistration.scope =$Scope

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
        client_id = $script:appRegistration.client_id
        client_secret = $script:appRegistration.client_secret
        grant_type = 'password'
        username = $Email
        password = ConvertFrom-SecureString $Password -AsPlainText
    }

    if ($Scope) {
        $data['scope'] = $Scope | Join-String -Separator:' '
    }

    $auth = Invoke-MastodonApiRequest -Method:Post -Route:"oauth/token" -Data:$data

    $script:auth = $auth

    return $auth
}

# from here:
# https://github.com/glacasa/Mastonet/blob/main/Mastonet/MastodonClient.cs
# ...

function Get-MastodonInstance {
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

function GetMastodonReports {
    param(
        [System.Nullable[long]] $MaxId,
        [System.Nullable[long]] $SinceId,
        [System.Nullable[long]] $MinId,
        [System.Nullable[int]] $Limit
    )
    $query = Get-MastodonArrayQueryArguments @PSBoundParameters | ConvertTo-Query
    Invoke-MastodonApiRequest -Method:Get -Route:"api/v1/reports$query"
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