function New-MastodonSession {
    param(
        [Parameter(Mandatory)]
        [string] $ClientId,

        [Parameter(Mandatory)]
        [string] $ClientSecret,

        [Parameter(Mandatory)]
        [string] $Instance,

        [string] $RedirectUri = "urn:ietf:wg:oauth:2.0:oob",

        [string] $Name = "PoshToDon",

        [ValidateScript({ $_ -in $script:validScopes })]
        [string[]] $Scope,

        [switch] $PassThru
    )

    $session = [MastodonSession]@{
        Instance = $Instance
        AppName  = $Name
        AppRegistration = [AppRegistration]@{
            client_id     = $ClientId
            client_secret = $ClientSecret
            redirect_uri  = $RedirectUri
            scope         = $Scope
        }
    }

    $script:session = $session

    if ($PassThru) {
        $session
    }
}

function Connect-MastodonApplication {
    param(
        [string] $Email,
        [securestring] $Password,
        [ValidateScript({ $_ -in $script:validScopes })]
        [string[]] $Scope,
        [MastodonSession] $Session = $script:session
    )

    if (-not $Session) {
        throw "No Session"
    }

    $data = @{
        username      = $Email
        grant_type    = 'password'
        client_id     = $session.AppRegistration.client_id
        client_secret = $session.AppRegistration.client_secret
        password      = ConvertFrom-SecureString $Password -AsPlainText
    }

    if ($Scope) {
        $data['scope'] = $Scope | Join-String -Separator:' '
    }

    $auth = Invoke-MastodonApiRequest -Session:$Session -Method:Post -Route:"oauth/token" -Data:$data 
    $Session.AccessToken = $auth.access_token
}

# basic api call handling access token, data compression, route building and so.
function Invoke-MastodonApiRequest {
    [Internal()]
    param(
        [Parameter(Mandatory)]
        [MastodonSession] $Session,

        [ValidateSet("Post", "Get")]
        [string] $Method,
        [string] $Route,
        [hashtable] $Data,
        [hashtable] $Headers = @{}
    )

    if ($Session.AccessToken -and (-not $Headers['Authorization'])) {
        $Headers['Authorization'] = "Bearer $($Session.AccessToken)"
    }

    # Invoke-RestMethod 
    #     -Method:"Post" 
    #     -Body:@{"client_name"="PoshToDon";"scopes"="read";"redirect_uris" = "urn:ietf:wg:oauth:2.0:oob"} 
    #     -Uri:"https://home.social/api/v1/apps"

    if (-not $Session.Instance) {
        throw "Mastodon Instance not set"
    }

    $invokeSplat = @{
        Method  = $Method
        Headers = $Headers
        Uri     = "https://$($Session.Instance)/$route"
    }

    if ($Data) {
        $invokeSplat['Body'] = $Data | Compress-MastodonPostData
    }

    Invoke-RestMethod @invokeSplat
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
