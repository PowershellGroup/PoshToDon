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
        Instance        = $Instance
        AppName         = $Name
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