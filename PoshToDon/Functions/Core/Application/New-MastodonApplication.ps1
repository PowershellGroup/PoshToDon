# not yet sure why i need this function, but its in the implementation this one is based on:
# https://github.com/glacasa/Mastonet/blob/main/Mastonet/AuthenticationClient.cs
# https://github.com/glacasa/Mastonet/blob/main/Mastonet/MastodonClient.cs
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
