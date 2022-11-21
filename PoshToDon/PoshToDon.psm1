#Requires -PSEdition Core

class InternalAttribute : System.Attribute {}

class AppRegistration {
    [string] $client_id
    [securestring] $client_secret
    [string] $redirect_uri
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

$script:session = $null

# Load all functions
Get-ChildItem -Recurse -File -Filter "*.ps1" -Path ( Join-Path $PSScriptRoot 'functions' ) | ForEach-Object { . $_ }

$toExport = Get-Command -Module $ExecutionContext.SessionState.Module 
| Where-Object { "Internal" -notin $_.ScriptBlock.Ast.Body.ParamBlock.Attributes.TypeName.FullName } 

$toExport | Export-ModuleMember
