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

    if (-not $Session.Instance) {
        throw "Mastodon Instance not set"
    }

    $invokeSplat = @{
        Method  = $Method
        Headers = $Headers
        Uri     = "https://$($Session.Instance)/$route"
    }

    if ($Data) {
        $invokeSplat['Body'] = $Data | Compress
    }

    Invoke-RestMethod @invokeSplat
}
