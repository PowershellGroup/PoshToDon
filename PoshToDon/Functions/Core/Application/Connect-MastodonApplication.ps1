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

    if ($Email -and $Password) {
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
