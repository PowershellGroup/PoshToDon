#Requires -PSEdition Core

$script:validScopes = "read", "write", "follow", "push", "crypto"

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
        $Method,
        $Route,
        $Data,
        [hashtable]$Headers = @{}
    )

    if ($script:auth -and (-not $Headers['Authorization'])) {
        $Headers['Authorization'] = "Bearer $($script:auth.access_token)"
    }

    # Invoke-RestMethod -Method:"Post" -Body:@{"client_name"="PoshToDon";"scopes"="read";"redirect_uris" = "urn:ietf:wg:oauth:2.0:oob"} -Uri:"https://home.social/api/v1/apps"
    Invoke-RestMethod -Method:$Method -Body:$Data -Uri:(Get-MastodonUri -Route:$Route) -Headers:$headers
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
        [Validateset({ $script:validScopes })]
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
    $queryArgs = [System.Collections.Generic.List[string]]::new()
    if ($null -ne $MaxId) { $queryArgs.Add("max_id=$MaxId") }
    if ($null -ne $SinceId) { $queryArgs.Add("since_id=$SinceId") }
    if ($null -ne $MinId) { $queryArgs.Add("min_id=$MinId") }
    if ($null -ne $Limit) { $queryArgs.Add("limit=$Limit") }
    if ($ExcludeTypes.Length) { $ExcludeTypes | ForEach-Object { $queryArgs.Add("exclude_types[]=$_") } }

    $query = ""
    if ($queryArgs.Length) {
        $query = "?" + ($queryArgs | Join-String -Separator '&')
    }

    Invoke-MastodonApiRequest -Method:Get -Route:"api/v1/notifications$query"
}

function Get-MastodonNotification {
    param([long] $Id)
    Invoke-MastodonApiRequest -Method:Get -Route:"api/v1/notifications/$Id"
}


# function Connect-MastodonInstance {
#     param([string] $Instance, [string] $Email, [string] $Password)
#     $script:instance = $Instance
# }