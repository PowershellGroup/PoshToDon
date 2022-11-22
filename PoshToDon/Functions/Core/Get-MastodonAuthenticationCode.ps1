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


    $query = $data | Compress | ToQuery

    $url = "https://$($Session.Instance)/oauth/authorize$query"
    if ($ShowUrl) { 
        Write-Host "Please open this link to log in:"
        Write-Host $url
    } else {
        Start-Process "https://$($Session.Instance)/oauth/authorize$query"
    }

    Read-Host "Please enter the code which is displayed in your Browser"
}