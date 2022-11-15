#Requires -PSEdition Core

class InternalAttribute : System.Attribute {}

class AppRegistration {
    [string] $client_id
    [string] $client_secret
    [string] $instance
    [string] $redirect_uri
    [string] $name
    [string] $vapid_key
    [string[]] $scope
}

class MastodonSession {
    [string] $Instance
    [string] $AppName
    [AppRegistration] $AppRegistration
    [string] $AccessToken
}

# api specs
# https://docs.joinmastodon.org/methods/apps/

$script:validScopes = "read", "write", "write:statuses", "follow", "push", "crypto"

# https://github.com/glacasa/Mastonet/blob/main/Mastonet/Enums/NotificationType.cs
$script:notificationTypes = "follow", "favourite", "reblog", "mention", "poll"


[AppRegistration]$script:appRegistration = $null
[string]$script:instance = $null
$script:auth = $null


foreach ($_ in "base", "helper", "api") {
    . "$PSScriptRoot/$_-functions.ps1"
}

$toExport = Get-Command -Module $ExecutionContext.SessionState.Module 
| Where-Object { "Internal" -notin $_.ScriptBlock.Ast.Body.ParamBlock.Attributes.TypeName.FullName } 

#$toExport | Write-Host
$toExport | Export-ModuleMember
