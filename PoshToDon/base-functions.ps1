function New-MastodonSession {
    param(
        [Parameter(Mandatory)]
        [string] $ClientId,

        [Parameter(Mandatory)]
        [securestring] $ClientSecret,

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

    if ($PassThru) {
        $session
    } else {
        $script:session = $session
    }
}

function Get-MastodonAuthenticationCode {
    [Internal()]
    param(
        # A session, if you dont want to use the default session.
        [MastodonSession] $Session = $script:session,

        # Scopes that your user access token will be allowed to act on.
        [string[]] $Scope,

        # Shows the url to be opened in your browser,
        # instead of opening the browser for you
        [switch] $ShowUrl,

        # Forces re-authentication (for multiple user-accounts)
        [switch] $Force
    )

    if (-not $Session) {
        throw "No Session"
    }

    $data = @{
        client_id     = $session.AppRegistration.client_id
        response_type = 'code'
        redirect_uri  = 'urn:ietf:wg:oauth:2.0:oob'
        force_login   = $Force
    }

    if ($Scope) {
        $data['scope'] = $Scope | Join-String -Separator:' '
    }

    $query = $data | Compress-MastodonData | ConvertTo-QueryParameters | ConvertTo-Query

    $url = "https://$($Session.Instance)/oauth/authorize$query"
    if ($ShowUrl) { 
        Write-Host "Please open this link to log in:"
        Write-Host $url
    } else {
        Start-Process "https://$($Session.Instance)/oauth/authorize$query"
    }

    Read-Host "Please enter the code which is displayed in your Browser"
}

# Authenticate your user against the app-registry, so the client can fetch infomation in the name of your user.
function Connect-MastodonApplication {
    param(
        # Your user-account email to log in
        [Parameter(ParameterSetName = "Password", Mandatory)]
        [string] $Email,

        # Your user-account password to log in (securestring)
        [Parameter(ParameterSetName = "Password", Mandatory)]
        [securestring] $Password,

        # Credentials generated externally, to be used for logging you in.
        [Parameter(ParameterSetName = "Credential", Mandatory)]
        [pscredential] $Credential,

        [Parameter(ParameterSetName = "Code")]
        [switch] $ShowUrl,

        [ValidateScript({ $_ -in $script:validScopes })]
        [string[]] $Scope,

        [MastodonSession] $Session = $script:session,

        [switch] $Force
    )

    if (-not $Session) {
        throw 'No Session'
    }

    $data = @{
        client_id     = $session.AppRegistration.client_id
        client_secret = $session.AppRegistration.client_secret | ConvertFrom-SecureString -AsPlainText
    }

    if ($Email -and $Pasword) {
        $data['grant_type'] = 'password'
        $data['username'] = $Email
        $data['password'] = $Password | ConvertFrom-SecureString -AsPlainText
    } elseif ($Credential) {
        $data['grant_type'] = 'password'
        $data['username'] = $Credential.UserName
        $data['password'] = $Credential.Password | ConvertFrom-SecureString -AsPlainText
    } else {
        $data['code'] = Get-MastodonAuthenticationCode -Session:$Session -Scope:$Scope -ShowUrl:$ShowUrl
        $data['grant_type'] = 'authorization_code'
        $data['redirect_uri'] = 'urn:ietf:wg:oauth:2.0:oob'

        if (-not $data['code']) {
            throw "No Code"
        }
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
        $invokeSplat['Body'] = $Data | Compress-MastodonData
    }

    Invoke-RestMethod @invokeSplat
}
