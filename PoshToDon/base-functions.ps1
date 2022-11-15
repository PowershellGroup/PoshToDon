function Set-MastodonAppRegistration {
    param(
        $ClientId, 
        $ClientSecret, 
        $Instance,
        $RedirectUri = "urn:ietf:wg:oauth:2.0:oob",
        $Name = "PoshToDon",
        $VapidKey,
        [ValidateScript({ $_ -in $script:validScopes })]
        [string[]] $Scope = "read"
    )

    if ($Instance) {
        Set-MastodonInstance -Instance:$Instance
    }

    $script:appRegistration = [AppRegistration]@{
        client_id     = $ClientId
        client_secret = $ClientSecret
        instance      = $Instance
        redirect_uri  = $RedirectUri
        name          = $Name
        vapid_key     = $VapidKey
        scope         = $Scope
    }
}

function Set-MastodonInstance {
    [Internal()]
    param([string]$Instance)
    $script:instance = $Instance
}

function Test-MastodonInstance {
    [Internal()]
    param()
    if (-not $script:instance) {
        Write-Host "Use Set-MastodonInstance first"
        return $false
    }

    return $true
}

function Get-MastodonUri {
    [Internal()]
    param([string]$Route)

    # route should exclude leading /
    if (Test-MastodonInstance) {
        "https://$script:instance/$route"
    } else {
        throw "Mastodon Instance not set"
    }
}

function Invoke-MastodonApiRequest {
    [Internal()]
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